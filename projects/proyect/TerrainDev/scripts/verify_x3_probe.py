#!/usr/bin/env python3
"""Check real engine evidence and ensure stale/failed/empty logs are rejected."""
from pathlib import Path
import hashlib,json,re
from verify_rapid_probe import evaluate as rapid_evaluate

ROOT=Path(__file__).resolve().parents[1]


def values(raw, keys):
    return {k:float(re.search(r'\b'+k+r'=([\d.]+)',raw)[1]) for k in keys}


# expected/w_labels default to the delivered discrete W; candidates with X3Charge pass theirs.
def x3_evaluate(info, raw, expected=69, w_labels=('native W spell event creates charged physics',)):
    assert f'X3 {info["run"]} COMPLETE' in raw and '"FAIL ' not in raw
    passes=re.findall(r'call Preload\( "PASS ([^"]+)"',raw)
    assert len(passes)==len(set(passes))==expected
    for label in [*w_labels,'two bodies orbit independently in XY',
                  'catching pulse produces exactly one fusion',
                  'missing orb prevents fusion',
                  'enemy impact before union prevents fusion',
                  'obstacle before union prevents fusion',
                  'simultaneous casts fuse only their own components',
                  'concurrent cast limit rejects overflow',
                  'native E spell event completes cross-shot sequence',
                  'fusion precedes later enemy impact inside the same tick',
                  'green satellite really travels backwards after union',
                  'orange satellite really travels backwards after union',
                  'satellite turns around and accelerates forwards',
                  'core accelerates after formation',
                  'green satellite reaches its sustained speed limit',
                  'orange satellite reaches its sustained speed limit',
                  'retreating satellite sweeps its real path and damages once']:
        assert label in passes
    v=values(raw,['checks','failures','casts','live','created','retired','fusions','flashes'])
    assert v['checks']==expected and v['failures']==v['casts']==v['live']==v['flashes']==0
    # Baseline190 + one extra eight-body cast to test a retrograde collision.
    assert v['created']==v['retired']==198 and v['fusions']==7
    return v


def color_evaluate(info, raw):
    assert f'COLOR {info["run"]} COMPLETE' in raw and '"FAIL ' not in raw
    passes=re.findall(r'call Preload\( "PASS ([^"]+)"',raw)
    assert len(passes)==len(set(passes))==40
    for i in range(12):
        assert f'model for owner color {i}' in passes and f'scale for owner color {i}' in passes
    v=values(raw,['checks','failures','live','created','retired','scale'])
    assert v['checks']==40 and v['failures']==v['live']==0
    assert v['created']==v['retired']==221 and abs(v['scale']-16/5.832)<.001
    return v


def reject_controls(check, raw, controls):
    for altered in controls:
        assert altered!=raw
        try:check(altered)
        except AssertionError:continue
        raise AssertionError('Evaluator accepted corrupted evidence')
    return len(controls)


if __name__=='__main__':
    final=json.loads((ROOT/'reports/current-x3-test.json').read_text())
    regression=final
    latest=json.loads((ROOT/'reports/latest-build.json').read_text())
    d=Path(final['directory']);rd=Path(regression['directory'])
    for info in [final,regression]:
        assert info['production_sha256']==latest['sha256']
        assert hashlib.sha256(Path(info['map']).read_bytes()).hexdigest()==info['sha256']
    assert hashlib.sha256((ROOT/'TerrainDev.w3x').read_bytes()).hexdigest()==latest['sha256']
    for n,h in latest['library_sha256'].items():
        assert hashlib.sha256((ROOT/f'src/libraries/{n}.j').read_bytes()).hexdigest()==h
    logs=[d/'x3-engine.txt',rd/'colors-engine.txt',rd/'rapid-engine.txt']
    missing=[str(p) for p in logs if not p.is_file()]
    if missing:
        raise SystemExit('Laboratory incomplete; wait for COMPLETE before validating: '+', '.join(missing))
    xraw,craw,rraw=[p.read_text() for p in logs]
    x=x3_evaluate(final,xraw);c=color_evaluate(regression,craw);r=rapid_evaluate(regression,rraw)
    negative=reject_controls(lambda s:x3_evaluate(final,s),xraw,[
        xraw.replace('failures=0','failures=1'),xraw.replace(final['run'],'old-run'),
        xraw.replace('retired=198','retired=197'),xraw.replace('fusions=7','fusions=0'),
        xraw.replace('PASS native E spell event','OMITTED native E spell event'),
        xraw.replace('PASS green satellite really travels backwards','OMITTED green satellite really travels backwards')])
    negative+=reject_controls(lambda s:color_evaluate(regression,s),craw,[
        craw.replace('failures=0','failures=1'),craw.replace(regression['run'],'old-run'),
        craw.replace('retired=221','retired=220'),craw.replace('PASS model for owner color 0','OMITTED model for owner color 0')])
    negative+=reject_controls(lambda s:rapid_evaluate(regression,s),rraw,[
        rraw.replace('failures=0','failures=1'),rraw.replace(regression['run'],'old-run'),
        re.sub(r'observed=\d+','observed=0',rraw),rraw.replace('minimum=0.250','minimum=0.010'),
        rraw.replace('PASS native point cast accepted','OMITTED native point cast accepted')])
    result={'passed':True,'production_sha256':latest['sha256'],'x3':x,'colors':c,'rapid_fire':r,
            'checks_total':153,'negative_controls_rejected':negative,
            'x3_fixture':str(d/'fixture.json'),'regression_fixture':str(rd/'fixture.json')}
    (d/'validated-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
