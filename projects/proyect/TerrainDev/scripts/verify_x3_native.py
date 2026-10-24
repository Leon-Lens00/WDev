#!/usr/bin/env python3
"""Validate fresh native-profile engine receipts against the exact compiled map."""
from pathlib import Path
import json,hashlib,re
from verify_x3_probe import values,reject_controls
ROOT=Path(__file__).resolve().parents[1]
def evaluate(info,raw,expected_count):
    assert f'NATIVE {info["run"]} COMPLETE' in raw and '"FAIL ' not in raw
    labels=re.findall(r'call Preload\( "PASS ([^"]+)"',raw)
    assert len(labels)==len(set(labels))==expected_count
    for label in ['5259 ROM CSV values match vJASS within 0.012 world units',
                  'USA emits core plus four satellites exactly once',
                  'Zero Project four curved trajectories rotate correctly to left',
                  'cancelling formation releases its timer without delayed emission or flash leak',
                  'dead source during formation cannot emit delayed bodies',
                  'simultaneous USA and mod casts keep separate pairs and formation timers',
                  'native R selects Zero Project without conflicting with E or Rapid Fire',
                  'native retreating satellites sweep enemies behind union point']:
        assert label in labels
    v=values(raw,['checks','failures','oracle','oracleFailures','maxError','casts','live','created','retired','flashes'])
    assert v['checks']==expected_count and v['oracle']==5259
    assert v['failures']==v['oracleFailures']==v['casts']==v['live']==v['flashes']==0
    assert v['maxError']<=.012 and v['created']==v['retired'] and v['created']>70
    return v
if __name__=='__main__':
    info=json.loads((ROOT/'reports/current-x3-test.json').read_text());d=Path(info['directory'])
    latest=json.loads((ROOT/'reports/latest-build.json').read_text())
    assert info['production_sha256']==latest['sha256']
    for p,h in [(Path(info['map']),info['sha256']),(ROOT/'TerrainDev.w3x',latest['sha256'])]:assert hashlib.sha256(p.read_bytes()).hexdigest()==h
    for n,h in latest['library_sha256'].items():assert hashlib.sha256((ROOT/f'src/libraries/{n}.j').read_bytes()).hexdigest()==h
    provenance=json.loads((d/'oracle-provenance.json').read_text())
    for p in provenance['inputs']:assert hashlib.sha256((ROOT/p['file']).read_bytes()).hexdigest()==p['sha256']
    count=len(re.findall(r'call Check\(', (ROOT/'scripts/X3NativeProbe.j').read_text()))-1 # timeout is a failure-only path
    raw=(d/'native-engine.txt').read_text();v=evaluate(info,raw,count)
    negatives=reject_controls(lambda s:evaluate(info,s,count),raw,[raw.replace(info['run'],'stale'),raw.replace('COMPLETE','PROGRESS'),raw.replace('oracle=5259','oracle=0'),raw.replace('oracleFailures=0','oracleFailures=1'),raw.replace('failures=0','failures=1'),re.sub(r'retired=\d+','retired=0',raw),raw.replace('PASS dead source','OMITTED dead source')])
    result={'passed':True,'production_sha256':latest['sha256'],'fixture_sha256':info['sha256'],'values':v,'negative_controls_rejected':negatives,'oracle_provenance':str(d/'oracle-provenance.json'),'limits':['single client Classic1.27b','2 Warcraft units per native pixel','native mathematical flight; map-specific collision and damage','no multiplayer certification']}
    (d/'native-validated.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
