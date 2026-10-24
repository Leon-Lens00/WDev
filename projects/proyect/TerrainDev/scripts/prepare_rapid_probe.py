#!/usr/bin/env python3
from pathlib import Path
import datetime,json,sys
import build
r=build.ROOT
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
d=r/'reports/rapid-fire'/stamp;d.mkdir(parents=True)
names=json.loads((r/'libraries.json').read_text())['order']
latest=json.loads((r/'reports/latest-build.json').read_text())
assert build.digest((r/'TerrainDev.w3x').read_bytes())==latest['sha256']
for n in names:
    assert build.digest((r/f'src/libraries/{n}.j').read_bytes())==latest['library_sha256'][n]
source='\n'.join((r/f'src/libraries/{n}.j').read_text() for n in names)
source+='\n'+(r/'scripts/RapidFireProbe.j').read_text().replace('@RUN@',stamp)
source+='\n'+build.map_script(Path(latest['build_directory'])/'base/war3map.j').decode()
(d/'input.j').write_text(source)
build.run(['vjass',d/'input.j',d/'compiled.j'],d/'compile.json')
target=r/f'maps/work/TerrainDev-rapid-{stamp}.w3x'
build.run(['wc3ctl','file','set',r/'TerrainDev.w3x','war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'extract.json')
assert (d/'reextracted.j').read_bytes()==(d/'compiled.j').read_bytes()
prefix=Path('/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx')
info={'run':stamp,'directory':str(d),'map':str(target),'map_sha256':build.digest(target.read_bytes()),
      'production_sha256':latest['sha256'],'log':str(prefix/f'drive_c/WarcraftIII/CustomMapData/Logs/TerrainDev-{stamp}-rapid.txt')}
assert not Path(info['log']).exists()
(d/'manifest.json').write_text(json.dumps(info,indent=2));(r/'reports/current-rapid-test.json').write_text(json.dumps(info,indent=2))
print(d)
