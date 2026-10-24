#!/usr/bin/env python3
"""Prepare a separate laboratory map; never writes the delivery map."""
from pathlib import Path
import datetime
import json
import argparse
import build

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--diagnostics',action='store_true',help='Include multiboard controls and independent telemetry assertions')
args = parser.parse_args()
r = build.ROOT
run = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
d = r/'reports/game-test'/run
d.mkdir(parents=True)
template = (r/'scripts/IntegrationProbe.j').read_text().replace('@RUN@',run)
if args.diagnostics:
    template += '\n\n'+(r/'scripts/DiagnosticsProbe.j').read_text().replace('@RUN@',run)
names = json.loads((r/'libraries.json').read_text())['order']
latest = json.loads((r/'reports/latest-build.json').read_text())
for name in names:
    assert build.digest((r/'src/libraries'/f'{name}.j').read_bytes()) == latest['library_sha256'][name]
production = r/'TerrainDev.w3x'
assert build.digest(production.read_bytes()) == latest['sha256']
source = d/'input.j'
source.write_text('\n\n'.join((r/'src/libraries'/f'{n}.j').read_text() for n in names)+'\n\n'+
                  template+'\n\n'+build.map_script(Path(latest['build_directory'])/'base/war3map.j').decode())
build.run(['vjass',source,d/'compiled.j'],d/'compile.json')
target = r/'maps/work'/f'TerrainDev-probe-{run}.w3x'
build.run(['wc3ctl','file','set',production,'war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'reextract.json')
assert (d/'reextracted.j').read_bytes() == (d/'compiled.j').read_bytes()
prefix = Path('/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx')
logroot = prefix/'drive_c/WarcraftIII/CustomMapData/Logs'
info = {'directory':str(d),'run':run,'map':str(target),'map_sha256':build.digest(target.read_bytes()),
        'production_map_sha256':latest['sha256'],'source_sha256':build.digest(source.read_bytes()),
        'logs':{s:str(logroot/f'TerrainDev-{run}-{s}.txt') for s in ('start','result')},
        'expected':{'created':90,'removed':90,'finished':70,'collided':10,'cancelled':10,
                    'liveUnpooled':0,'casters':1,'timerChecks':1,'failures':0},
        'minimum':{'pooled':1,'reused':1,'callbacks':1,'dummies':1}}
if args.diagnostics:
    info['diagnostics_logs'] = {s:str(logroot/f'TerrainDev-{run}-diagnostics-{s}.txt') for s in
                               ('idle','normal','deferred','deferred-done','overdue','recovered','hidden','visible','invalid')}
assert all(not Path(p).exists() for p in info['logs'].values())
(d/'manifest.json').write_text(json.dumps(info,indent=2))
(r/'reports/latest-game-test.json').write_text(json.dumps(info,indent=2))
print(d)
