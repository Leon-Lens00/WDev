#!/usr/bin/env python3
"""Validate fresh candidate receipts: X3 (charged W), colors, Rapid Fire, native and X3Charge."""
from pathlib import Path
import hashlib,json,re,sys
from verify_x3_probe import values,reject_controls,x3_evaluate,color_evaluate
from verify_rapid_probe import evaluate as rapid_evaluate
from verify_x3_native import evaluate as native_evaluate

ROOT=Path(__file__).resolve().parents[1]
W_LABELS=('native W first press begins charge without bodies','native W second press at level 8 accepted',
          'native W release at level 8 creates charged physics')
X3_CHECKS=71


def check_count(probe):
    # The timeout Check is a failure-only path.
    return len(re.findall(r'call Check\(',(ROOT/'scripts'/probe).read_text()))-1


def charge_evaluate(info, raw, expected):
    assert f'CHARGE {info["run"]} COMPLETE' in raw and '"FAIL ' not in raw
    passes=re.findall(r'call Preload\( "PASS ([^"]+)"',raw)
    assert len(passes)==len(set(passes))==expected
    for label in ['levelAt matches the 1/21/81/141/201 native frame thresholds',
                  'release below level 8 fires nothing',
                  'level 8 release fires one charged pulse',
                  'level 10 release stores the second pulse',
                  'stored pulse fuses with its helix into five bodies',
                  'repeated second release is rejected',
                  'pulse stored past the cast lifetime is dropped and the press begins a new charge',
                  'release keeps the profile chosen at begin',
                  'dead actor cannot fire or begin',
                  'recycled pair slot does not inherit a charge',
                  'two simultaneous sequences fuse separately',
                  'Rapid Fire during charge keeps the charge',
                  'native R releases the level 8 charge begun with W',
                  'all charge casts retire to a balanced zero-active state']:
        assert label in passes
    v=values(raw,['checks','failures','casts','live','created','retired','flashes','begins','charged','full','empty','seconds'])
    assert v['checks']==expected and v['failures']==v['casts']==v['live']==v['flashes']==0
    assert v['created']==v['retired']>0 and v['full']>=4 and v['seconds']>=4 and v['charged']>=2 and v['empty']>=1
    return v


if __name__=='__main__':
    fixture=Path(sys.argv[1]) if len(sys.argv)>1 else ROOT/'reports/current-x3-charge-test.json'
    info=json.loads(fixture.read_text());d=Path(info['directory'])
    candidate=json.loads(Path(info['candidate_result']).read_text())
    assert candidate['candidate'] and candidate['sha256']==info['candidate_sha256']
    assert hashlib.sha256(Path(info['map']).read_bytes()).hexdigest()==info['sha256']
    assert hashlib.sha256(Path(candidate['map']).read_bytes()).hexdigest()==candidate['sha256']
    for n,h in candidate['library_sha256'].items():
        assert hashlib.sha256((ROOT/f'src/libraries/{n}.j').read_bytes()).hexdigest()==h
    # The delivery must be untouched by candidate work.
    production=hashlib.sha256((ROOT/'TerrainDev.w3x').read_bytes()).hexdigest()
    assert production==info['production_sha256']==json.loads((ROOT/'reports/latest-build.json').read_text())['sha256']
    provenance=json.loads((d/'oracle-provenance.json').read_text())
    for p in provenance['inputs']:assert hashlib.sha256((ROOT/p['file']).read_bytes()).hexdigest()==p['sha256']
    logs={tag:d/f'{tag}-engine.txt' for tag in ['x3','colors','rapid','native','charge']}
    missing=[str(p) for p in logs.values() if not p.is_file()]
    if missing:raise SystemExit('Laboratory incomplete: '+', '.join(missing))
    raw={tag:p.read_text() for tag,p in logs.items()}
    native_count=check_count('X3NativeProbe.j');charge_count=check_count('X3ChargeProbe.j')
    X=lambda s:x3_evaluate(info,s,X3_CHECKS,W_LABELS)
    N=lambda s:native_evaluate(info,s,native_count)
    C=lambda s:charge_evaluate(info,s,charge_count)
    result={'x3':X(raw['x3']),'colors':color_evaluate(info,raw['colors']),'rapid_fire':rapid_evaluate(info,raw['rapid']),
            'native':N(raw['native']),'charge':C(raw['charge'])}
    x,c,n=raw['x3'],raw['charge'],raw['native']
    negatives=reject_controls(X,x,[x.replace(info['run'],'stale'),x.replace('failures=0','failures=1'),
        x.replace('PASS native W release at level 8','OMITTED native W release at level 8')])
    negatives+=reject_controls(N,n,[n.replace(info['run'],'stale'),n.replace('PASS native R full release','OMITTED native R full release')])
    negatives+=reject_controls(C,c,[c.replace(info['run'],'stale'),c.replace('COMPLETE','PROGRESS'),c.replace('failures=0','failures=1'),
        re.sub(r'retired=\d+','retired=0',c),c.replace('PASS release below level 8','FAIL release below level 8'),
        c.replace('PASS recycled pair slot','OMITTED recycled pair slot'),re.sub(r'seconds=\d+','seconds=0',c)])
    checks=X3_CHECKS+40+44+native_count+charge_count
    out={'passed':True,'status':'Tested in map (candidate)','candidate_sha256':info['candidate_sha256'],'fixture_sha256':info['sha256'],
         'production_sha256':production,'checks_total':checks,'checks':{'x3':X3_CHECKS,'colors':40,'rapid_fire':44,'native':native_count,'charge':charge_count},
         'values':result,'negative_controls_rejected':negatives,
         'limits':['single client Classic 1.27b','toggle adapter only, no key-up input','level 8 shot is an unmeasured assumption','no multiplayer, editor save or performance claim']}
    (d/'validated-result.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
