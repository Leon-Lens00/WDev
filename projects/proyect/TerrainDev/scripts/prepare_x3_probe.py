#!/usr/bin/env python3
"""Compile engine labs against the exact delivered sources and asset revision."""
from pathlib import Path
import datetime,json
from zoneinfo import ZoneInfo
import build
import x3_native_oracle

r=build.ROOT
d=Path(json.loads((r/'reports/current-x3.json').read_text())['directory'])
stamp=datetime.datetime.now(ZoneInfo('America/Lima')).strftime('%Y%m%d-%H%M%S')
d=d/stamp;d.mkdir()
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
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-rapid",true)
    call TriggerAddAction(t,function Queue)
    set t = null
endfunction'''
assert old in legacy
s+='\n'+legacy.replace(old,new)
s+='\n'+(r/'scripts/X3Probe.j').read_text().replace('@RUN@',stamp)
s+='\n'+x3_native_oracle.render(d)
s+='\n'+(r/'scripts/X3NativeProbe.j').read_text().replace('@RUN@',stamp)
s+='\n'+build.map_script(Path(latest['build_directory'])/'base/war3map.j').decode()
(d/'input.j').write_text(s)
build.run(['vjass',d/'input.j',d/'compiled.j'],d/'compile.json')
target=r/f'maps/work/TerrainDev-x3-{stamp}.w3x'
build.run(['wc3ctl','file','set',r/'TerrainDev.w3x','war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'extract.json')
assert (d/'compiled.j').read_bytes()==(d/'reextracted.j').read_bytes()
prefix=r/'build/x3-runtime/pfx'
info={'run':stamp,'directory':str(d),'map':str(target),'sha256':build.digest(target.read_bytes()),'production_sha256':latest['sha256'],'prefix':str(prefix),'log_directory':str(prefix/'drive_c/WarcraftIII/CustomMapData/Logs')}
for tag in ['x3','colors','rapid','native']:assert not (Path(info['log_directory'])/f'TerrainDev-{stamp}-{tag}.txt').exists()
(d/'fixture.json').write_text(json.dumps(info,indent=2))
(r/'reports/current-x3-test.json').write_text(json.dumps(info,indent=2))
print(d)
