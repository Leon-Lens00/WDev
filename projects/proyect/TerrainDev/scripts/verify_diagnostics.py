#!/usr/bin/env python3
"""Compare the panel's real engine counters with independent fixture stages."""
from pathlib import Path
import json
import re
import sys

manifest = Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]/'reports/latest-game-test.json'
info = json.loads(manifest.read_text())
d = Path(info['directory'])
launch = json.loads((d/'launch-time.json').read_text())
cases = {
    'idle': {'active':0,'tracked':96,'pooled':96,'preloaded':96,'alarms':0},
    'normal': {'active':0,'peak':60,'created':90,'retired':90,'tracked':96,'pooled':96,'new':66,'reused':24,'disposed':66,'alarms':0},
    'deferred': {'active':0,'deferred':1,'pooled':95,'alarms':0},
    'deferred-done': {'active':0,'deferred':0,'pooled':96,'alarms':0},
    'overdue': {'tracked':97,'pooled':96,'pending':1,'overdue':1,'alarms':1,'adopted':1},
    'recovered': {'tracked':96,'pooled':96,'pending':0,'overdue':0,'disposed':67,'alarms':1},
    'hidden': {'tracked':96,'pooled':96,'alarms':1},
    'visible': {'tracked':96,'pooled':96,'alarms':1},
    'invalid': {'invalid':1,'alarms':2,'tracked':96,'pooled':96},
}
results = {}
for stage, expected in cases.items():
    path = Path(info['diagnostics_logs'][stage])
    assert path.stat().st_mtime_ns >= launch['time_ns'],f'Stale log: {stage}'
    raw = path.read_text(errors='replace')
    assert f'DIAGNOSTICS {info["run"]} {stage}' in raw, f'Wrong run: {stage}'
    values = {k:int(v) for k,v in re.findall(r'([A-Za-z]+)=(\d+)',raw)}
    for name in ('probeFailures','errors','lost','omitted','inconsistent'):
        assert values.get(name)==0,f'{stage}: {name}={values.get(name)}'
    for name, value in expected.items():
        assert values.get(name)==value,f'{stage}: expected {name}={value}, got {values.get(name)}'
    (d/f'engine-diagnostics-{stage}.txt').write_bytes(path.read_bytes())
    results[stage] = values
out = {'passed':True,'stages':results,'negative_case_detected':True,'alarm_history_persisted':True,
       'visibility_toggle_tested':True,'scope':'Local 1.27b, bounded fixture; no multiplayer or performance certification'}
(d/'diagnostics-result.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
