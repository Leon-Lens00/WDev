#!/usr/bin/env python3
"""Compile a new recording/QA copy; production libraries and models unchanged."""
from pathlib import Path
import datetime,json
import build
r=build.ROOT
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
d=r/'reports/shot-colors-20261022'/stamp;d.mkdir(parents=True)
latest=json.loads((r/'reports/latest-build.json').read_text())
assert build.digest((r/'TerrainDev.w3x').read_bytes())==latest['sha256']
names=latest['libraries']
for n in names:assert build.digest((r/f'src/libraries/{n}.j').read_bytes())==latest['library_sha256'][n]
s='\n'.join((r/f'src/libraries/{n}.j').read_text() for n in names)
s+='\n'+(r/'scripts/ShotColorProbe.j').read_text().replace('@RUN@',stamp)
legacy=(r/'scripts/RapidFireProbe.j').read_text().replace('@RUN@',stamp)
old='private function Init takes nothing returns nothing\n    call TimerStart(CreateTimer(),2.,false,function Begin)\nendfunction'
new='''private function Queue takes nothing returns nothing
    call TimerStart(CreateTimer(),0.03125,false,function Begin)
endfunction
private function Init takes nothing returns nothing
    local trigger start = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(start,Player(0),"-rapid",true)
    call TriggerAddAction(start,function Queue)
    set start = null
endfunction'''
assert old in legacy
s+='\n'+legacy.replace(old,new)
s+='\n'+build.map_script(Path(latest['build_directory'])/'base/war3map.j').decode()
(d/'input.j').write_text(s)
build.run(['vjass',d/'input.j',d/'compiled.j'],d/'compile.json')
target=r/f'maps/work/TerrainDev-colors-{stamp}.w3x'
build.run(['wc3ctl','file','set',r/'TerrainDev.w3x','war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'extract.json')
assert (d/'compiled.j').read_bytes()==(d/'reextracted.j').read_bytes()
info={'run':stamp,'directory':str(d),'map':str(target),'map_sha256':build.digest(target.read_bytes()),'production_sha256':latest['sha256'],'log':f'/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs/TerrainDev-{stamp}-colors.txt'}
assert not Path(info['log']).exists()
(d/'manifest.json').write_text(json.dumps(info,indent=2));(r/'reports/current-color-test.json').write_text(json.dumps(info,indent=2));print(d)
