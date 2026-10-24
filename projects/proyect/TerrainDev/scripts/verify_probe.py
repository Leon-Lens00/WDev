#!/usr/bin/env python3
"""Evaluate fresh engine logs against the laboratory's explicit expectations."""
from pathlib import Path
import json
import re
import sys


def evaluate(info, start, result):
    assert f'TERRAINDEV RUN {info["run"]} START' in start
    assert f'TERRAINDEV RUN {info["run"]} COMPLETE' in result
    values = {k:int(v) for k,v in re.findall(r'([A-Za-z]+)=(\d+)', result)}
    for key, expected in info['expected'].items():
        assert values.get(key) == expected, f'{key}: expected {expected}, got {values.get(key)}'
    for key, minimum in info['minimum'].items():
        assert values.get(key,0) >= minimum, f'{key}: no positive coverage'
    assert values['pooled']+values['overflow'] == values['dummies']
    return values


if __name__ == '__main__':
    manifest = Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]/'reports/latest-game-test.json'
    info = json.loads(manifest.read_text())
    d = Path(info['directory'])
    launch = json.loads((d/'launch-time.json').read_text())
    logs = {}
    for stage, name in info['logs'].items():
        p = Path(name)
        assert p.stat().st_mtime_ns >= launch['time_ns'], f'Stale {stage} log'
        logs[stage] = p.read_text(errors='replace')
        (d/f'engine-{stage}.txt').write_bytes(p.read_bytes())
    values = evaluate(info, logs['start'], logs['result'])
    # The evaluator must reject nonzero failures, omitted work and a stale run.
    negative_controls = [logs['result'].replace('failures=0','failures=1'),
                         logs['result'].replace('created=90','created=0'),
                         logs['result'].replace(info['run'],'wrong-run')]
    for bad in negative_controls:
        try:
            evaluate(info,logs['start'],bad)
        except AssertionError:
            continue
        raise AssertionError('Evaluator accepted a negative control')
    out = {'passed':True,'values':values,'negative_controls_rejected':3,
           'scope':'Local Warcraft III 1.27b laboratory; multiplayer and future spell effects untested'}
    (d/'result.json').write_text(json.dumps(out,indent=2))
    print(json.dumps(out,indent=2))
