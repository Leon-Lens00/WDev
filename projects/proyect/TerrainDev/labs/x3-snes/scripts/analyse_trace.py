"""Compare complete-game observations with the earlier isolated ROM motion traces."""
from pathlib import Path
import csv,json,hashlib,collections
LAB=Path(__file__).resolve().parents[1]
CASES=['final-original','final-mod','final-original-left','final-mod-left','final-original-gap20','final-mod-gap20']

def load_csv(path):
    with path.open() as f:return list(csv.DictReader(f))

def analyse_case(name,expected):
    root=LAB/'runs'/name
    process=json.loads((root/'process-result.json').read_text())
    assert process['returncode']==0 and process['own_process_closed'] and (root/'complete.txt').is_file()
    events=load_csv(root/'events.csv');frames=load_csv(root/'frames.csv')
    variant='original' if process['rom_sha256'].startswith('65b03268') else 'zero-project-v4.1'
    direction=-1 if 'left' in name else 1
    merge=[r for r in events if r['event']=='merge_detected']
    emit=[r for r in events if r['event']=='emit_combined']
    init=[r for r in events if r['event']=='combined_init_end' and r['id'] in ('31','32')]
    result={'case':name,'variant':variant,'direction':direction,'gap':20 if 'gap20' in name else 12,'frame_rows':len(frames),'event_rows':len(events),'merges':len(merge),'emissions':len(emit),'combined_bodies':len(init),'motion_comparisons':0,'mismatches':[],'bodies':[]}
    assert len(merge)==1 and len(emit)==1 and len(init)==5,(name,len(merge),len(emit),len(init))
    result['formation_frames']=int(emit[0]['native_frame'])-int(merge[0]['native_frame'])
    checks=[r for r in events if r['event'] in ('merge_check','helix_entry') and r['frame']==merge[0]['frame'] and r['dp']==merge[0]['dp']]
    before=checks[-1];result['merge_relocation_x_px']=float(merge[0]['x_px'])-float(before['x_px'])
    a,b=frames[9],frames[-1];result['fps']=21477270*(int(b['native_frame'])-int(a['native_frame']))/(int(b['master_clock'])-int(a['master_clock']))
    result['formation_seconds']=result['formation_frames']/result['fps']
    for r in init:
        body=int(r['subtype']);x0=float(r['x_px']);y0=float(r['y_px'])
        moves=[e for e in events if e['event']=='combined_after' and e['dp']==r['dp'] and e['id']==r['id'] and int(e['master_clock'])>int(r['master_clock'])]
        minimum=0;turn=None
        for tick,e in enumerate(moves,1):
            exp=expected[(variant,body,direction,tick)]
            observed={'x_px':float(e['x_px'])-x0,'y_px':float(e['y_px'])-y0,'vx_px_tick':float(e['vx']),'vy_up_px_tick':float(e['vy_up'])}
            for field,v in observed.items():
                result['motion_comparisons']+=1
                if abs(v-float(exp[field]))>1e-7:result['mismatches'].append({'body':body,'tick':tick,'field':field,'actual':v,'expected':float(exp[field])})
            advance=direction*observed['x_px'];minimum=min(minimum,advance)
            if turn is None and direction*float(e['vx'])>=0:turn=tick
        result['bodies'].append({'subtype':body,'dp':int(r['dp']),'moves_observed':len(moves),'first_nonnegative_forward_tick':turn,'minimum_forward_position_px':minimum,'initial_vx':float(r['vx']),'first_move_native_frame':int(moves[0]['native_frame']) if moves else None})
    result['first_move_after_merge_frames']=min(b['first_move_native_frame'] for b in result['bodies'])-int(merge[0]['native_frame'])
    pulse=[r for r in events if r['event']=='pulse_after']
    result['pulse_flight_updates_seen']=len(pulse)
    result['relevant_active_at_end']=sum(1 for r in events if r['event']=='frame' and r['frame']=='640' and r['id'] in ('3','29','31','32'))
    assert result['relevant_active_at_end']==0
    identity=json.loads((root/'process.json').read_text())
    result['scenario_sha256']=identity['scenario_sha256']
    assert hashlib.sha256((root/'scenario.lua').read_bytes()).hexdigest()==identity['scenario_sha256']
    result['precursor_children_subtypes']=sorted(set(int(r['subtype']) for r in events if r['event']=='helix_child_after'))
    return result

def main():
    rows=load_csv(LAB/'analysis/static-20261023-134543/motion-isolated.csv')
    expected={(r['variant'],int(r['body']),int(r['direction']),int(r['tick'])):r for r in rows}
    cases=[analyse_case(name,expected) for name in CASES]
    out={'scope':'complete SNES ROM executed by MesenCE2.2.1; compare observed combined-flight values with isolated ROM blocks','cases':cases,'total_comparisons':sum(x['motion_comparisons'] for x in cases),'total_mismatches':sum(len(x['mismatches']) for x in cases),'limits':['single intro-stage scene, X with buster equipment flag set once; no hardware SNES or exhaustive gameplay validation','object motion evaluated only while observed and alive, not 120 steps forced past screen removal','charge was real controller holding; scene/equipment preparation is documented separately']}
    target=LAB/'analysis/native-comparison.json';target.write_text(json.dumps(out,indent=2))
    print(json.dumps(out,indent=2))
    return 1 if out['total_mismatches'] else 0

if __name__=='__main__':raise SystemExit(main())
