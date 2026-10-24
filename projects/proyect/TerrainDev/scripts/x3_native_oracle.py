"""Render vJASS assertions from frozen native CSVs, without reimplementing motion."""
from pathlib import Path
import csv, json, hashlib

ROOT=Path(__file__).resolve().parents[1]

def render(out):
    checks=[]; provenance=[]; totals={'combined_updates':0,'helix_updates':0,'orb_updates':0,'pulse_updates':0}
    def rows(case):
        path=ROOT/'labs/x3-snes/runs'/case/'events.csv'
        provenance.append({'file':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
        return list(csv.DictReader(path.open()))
    def f(row,key):return float(row[key])
    for case in ['final-original','final-mod','final-original-left','final-mod-left','final-original-gap20','final-mod-gap20']:
        rr=rows(case); direction=-1 if 'left' in case else 1;p=2 if 'mod' in case else 1
        init={r['dp']:r for r in rr if r['event']=='combined_init_end'}
        count={dp:0 for dp in init}
        for r in rr:
            if r['event']!='combined_after':continue
            b=init[r['dp']];count[r['dp']]+=1;n=count[r['dp']]
            form={0:4,1:5,2:8,3:6,4:7}[int(r['subtype'])]
            x=direction*2*(f(r,'x_px')-f(b,'x_px'));y=-2*(f(r,'y_px')-f(b,'y_px'))
            checks.append(f'call Combined({p},{form},{n},{x:.8f},{y:.8f},{direction*2*f(r,"vx"):.8f},{2*f(r,"vy_up"):.8f})')
            totals['combined_updates']+=1
    rr=rows('trace-original-fullcharge')
    base=next(r for r in rr if r['event']=='helix_entry' and r['subtype']=='0' and r['state']=='2')
    n=0
    for r in rr:
        if r['event']=='helix_after':
            n+=1;checks.append(f'call Scalar(X3Kinematics.forward(1,1,I2R({n})/X3Kinematics.FPS),{2*(f(r,"x_px")-f(base,"x_px")):.8f})');totals['helix_updates']+=1
        elif r['event']=='helix_child_after':
            form={1:1,2:2,3:9}[int(r['subtype'])]
            # The children update after their parent in each native frame.
            checks.append(f'call Orb({form},{n},{2*(f(r,"x_px")-f(base,"x_px")):.8f},{-2*(f(r,"y_px")-f(base,"y_px")):.8f})');totals['orb_updates']+=1
    pb=next(r for r in rr if r['event']=='pulse_before');n=4
    for r in rr:
        if r['event']=='pulse_after':
            n+=1;checks.append(f'call Scalar(X3Kinematics.forward(1,3,I2R({n})/X3Kinematics.FPS),{2*(f(r,"x_px")-f(pb,"x_px")):.8f})');totals['pulse_updates']+=1
    assert totals=={'combined_updates':1220,'helix_updates':52,'orb_updates':153,'pulse_updates':21},totals
    code='''library X3Oracle requires X3Kinematics
struct X3Oracle extends array
    static integer valueChecks = 0
    static integer valueFailures = 0
    static real maxError = 0.
    static boolean done = false
    private static integer batch = 0
    private static method Scalar takes real actual, real expected returns nothing
        local real error = RAbsBJ(actual-expected)
        set valueChecks = valueChecks+1
        set maxError = RMaxBJ(maxError,error)
        if error > 0.012 then
            set valueFailures = valueFailures+1
            if valueFailures < 8 then
                call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"ORACLE FAIL "+I2S(valueChecks)+" actual "+R2S(actual)+" expected "+R2S(expected))
            endif
        endif
    endmethod
    private static method Combined takes integer p, integer form, integer n, real x, real y, real vx, real vy returns nothing
        local real t = I2R(n)/X3Kinematics.FPS
        local real previous = I2R(n-1)/X3Kinematics.FPS
        call Scalar(X3Kinematics.forward(p,form,t),x)
        call Scalar(X3Kinematics.side(p,form,t),y)
        call Scalar(X3Kinematics.forward(p,form,t)-X3Kinematics.forward(p,form,previous),vx)
        call Scalar(X3Kinematics.side(p,form,t)-X3Kinematics.side(p,form,previous),vy)
    endmethod
    private static method Orb takes integer form, integer n, real x, real y returns nothing
        call Scalar(X3Kinematics.orbitForward(form,I2R(n)/X3Kinematics.FPS),x)
        call Scalar(X3Kinematics.side(1,form,I2R(n)/X3Kinematics.FPS),y)
    endmethod
'''
    batches=[checks[i:i+20] for i in range(0,len(checks),20)]
    for i,body in enumerate(batches):code+=f'    private static method Batch{i} takes nothing returns nothing\n        '+'\n        '.join(body)+'\n    endmethod\n'
    code+='    static method step takes nothing returns nothing\n'
    for i in range(len(batches)):code+=('        if' if i==0 else '        elseif')+f' batch == {i} then\n            call Batch{i}()\n'
    code+='        else\n            set done = true\n        endif\n        set batch = batch+1\n    endmethod\nendstruct\nendlibrary\n'
    expected=totals['combined_updates']*4+totals['helix_updates']+totals['orb_updates']*2+totals['pulse_updates']
    (out/'X3Oracle.j').write_text(code)
    (out/'oracle-provenance.json').write_text(json.dumps({'inputs':provenance,'totals':totals,'expected_values':expected,'tolerance_world_units':0.012,'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},indent=2)+'\n')
    return code
