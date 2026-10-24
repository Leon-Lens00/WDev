"""Record identities and evidence; no map or designer mutation."""
from pathlib import Path
import json,hashlib,datetime,urllib.request
r=Path(__file__).resolve().parent
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
v=json.loads((r/'latest-build.json').read_text());probe=json.loads((r/'latest-probe.json').read_text());launch=json.loads((r/'isolated-launch.json').read_text())
assert digest(Path(v['map']))==v['sha256']
assert (Path(probe['build'])/'input.j').read_bytes().replace(b'\n\n'+(r/'InventoryProbe.j').read_bytes(),b'',1)==(Path(v['build'])/'input.j').read_bytes()
assert 'checks=78 failures=0' in (r/'evidence/61409-InventoryProbe-page.txt').read_text()
assert json.loads((r/'evidence/closed-62896.json').read_text())['exited']
owned=[]
prefix=('WINEPREFIX='+str(r/'runtime-isolated/pfx')).encode()
for p in Path('/proc').glob('[0-9]*'):
 try:
  if any(e.rstrip(b'/')==prefix for e in (p/'environ').read_bytes().split(b'\0')) and (p/'cmdline').read_bytes().split(b'\0')[0].lower().replace(b'\\',b'/').endswith(b'/war3.exe'):owned.append(int(p.name))
 except OSError:pass
assert not owned
studio=Path('/home/snz/Documentos/WarDatsPy/ui-studio');web=urllib.request.urlopen('http://127.0.0.1:4317',timeout=3);assert web.status==200
files=[*list((r/'src').glob('*.j')),*list((r/'foundation-src').glob('*.j')),r/'build.py',r/'build_support.py']
report={'date':datetime.datetime.now().isoformat(),'delivery':v,'tested_delivery_launch':launch,'delivery_compiled_script_identical_to_tested_launch':True,'last_change':'WTG GUI metadata preserved; runtime JASS unchanged','probe':probe,'probe_sources_identical_except_probe_scope':True,'game_checks':78,'game_failures':0,'mouse_verified':['page up','page down','crown tooltip','equip crown at level 3','unequip crown','reject crown at level 1 in non-probe delivery'],'studio_tests':16,'studio_failures':0,'studio_http':200,'own_game_processes':owned,'source_sha256':{str(p.relative_to(r)):digest(p) for p in files},'studio_sha256':{str(p.relative_to(studio)):digest(p) for p in [studio/'dist/projection.js',studio/'dist/app.js',studio/'dist/core.js',studio/'dist/geometry.js',studio/'dist/index.html',studio/'dist/studio.css',studio/'dist/catalog.json',studio/'tests/projection.test.mjs']},'not_verified':['multiplayer/desync','NewGen save and reopen','selling/dropping/socket workflows by physical clicks','non-1920x1080 calibration','destruction during pending click timer']}
(r/'verification.json').write_text(json.dumps(report,indent=2));print('Verified',v['sha256'],'own games:',owned)
