#!/usr/bin/env python3
"""Reject stale, incomplete or failed Rapid Fire engine runs, including zero coverage."""
from pathlib import Path
import json,re


def evaluate(info, raw):
    assert f'RAPID {info["run"]} COMPLETE' in raw
    assert '"FAIL ' not in raw
    m=re.search(r'checks=(\d+) failures=(\d+) observed=(\d+) minimum=([\d.]+) emitted=(\d+) live=(\d+) pairs=(\d+)',raw)
    assert m is not None
    values=dict(zip(['checks','failures','observed','minimum','emitted','live','pairs'],map(float,m.groups())))
    assert values['checks']==44 and values['failures']==0
    assert len(re.findall(r'call Preload\( "PASS ',raw))==44
    assert values['observed']>=40 and values['emitted']>=50
    assert .249<=values['minimum']<=.282
    assert values['live']==0 and values['pairs']==2
    initial=[float(v) for v in re.findall(r'SHOT stage=1 time=([\d.]+)',raw)]
    assert len(initial)==6 and all(abs(b-a-.25)<.002 for a,b in zip(initial,initial[1:]))
    window=re.search(r'WINDOW first=([\d.]+) end=([\d.]+)',raw)
    assert window and abs(float(window[2])-float(window[1])-1.5)<.032
    move=re.search(r'MOVE distance=([\d.]+) seconds=([\d.]+)',raw)
    assert move and abs(float(move[1])-350*float(move[2]))<15
    assert 'CLIFF from=' in raw and 'levels=4,3' in raw and 'RAMP heights=' in raw
    return values


if __name__=='__main__':
    root=Path(__file__).resolve().parents[1]
    info=json.loads((root/'reports/current-rapid-test.json').read_text());d=Path(info['directory'])
    log=Path(info['log']);launch=json.loads((d/'launch-time.json').read_text())
    assert log.stat().st_mtime_ns>=launch['time_ns']
    raw=log.read_text(errors='replace');(d/'engine-result.txt').write_bytes(log.read_bytes())
    values=evaluate(info,raw)
    bad=[raw.replace('failures=0','failures=1'),raw.replace(info['run'],'wrong-run'),
         raw.replace('observed=47','observed=0'),raw.replace('minimum=0.250','minimum=0.010'),
         raw.replace('PASS native point cast accepted','OMITTED native point cast accepted')]
    for altered in bad:
        assert altered!=raw
        try:evaluate(info,altered)
        except AssertionError:continue
        raise AssertionError('Evaluator accepted a negative control')
    result={'passed':True,'values':values,'negative_controls_rejected':len(bad),
            'production_sha256':info['production_sha256'],'map_sha256':info['map_sha256'],
            'scope':'Local Classic 1.27b; runtime mechanics and authored terrain samples, not multiplayer or arbitrary models'}
    (d/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
