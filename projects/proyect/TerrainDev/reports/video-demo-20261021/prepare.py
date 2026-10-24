import sys,json,hashlib
from pathlib import Path
r=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(r/'scripts'))
import build
d=Path(__file__).resolve().parent
info=json.loads((r/'reports/latest-build.json').read_text())
assert build.digest((r/'TerrainDev.w3x').read_bytes())==info['sha256']
names=json.loads((r/'libraries.json').read_text())['order']
for n in names:
    assert build.digest((r/f'src/libraries/{n}.j').read_bytes())==info['library_sha256'][n]
source='\n'.join((r/f'src/libraries/{n}.j').read_text() for n in names)
source+='\n'+(d/'VideoDemo.j').read_text()
source+='\n'+build.map_script(Path(info['build_directory'])/'base/war3map.j').decode()
(d/'input.j').write_text(source)
build.run(['vjass',d/'input.j',d/'compiled.j'],d/'compile.json')
build.run(['pjass',d/'compiled.j'],d/'pjass.json')
target=r/'maps/work/TerrainDev-video-demo-20261021.w3x'
build.run(['wc3ctl','file','set',r/'TerrainDev.w3x','war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'extract.json')
assert (d/'compiled.j').read_bytes()==(d/'reextracted.j').read_bytes()
manifest={'map':str(target),'sha256':build.digest(target.read_bytes()),'production_sha256':info['sha256'],'production_libraries':info['library_sha256'],'purpose':'Video-only scripted input driver; unchanged production libraries. Actor enlarged 1.3x for visibility.'}
(d/'manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps(manifest,indent=2))
