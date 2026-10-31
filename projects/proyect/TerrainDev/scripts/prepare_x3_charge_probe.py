#!/usr/bin/env python3
"""Compile the engine labs plus X3ChargeProbe against a candidate build, not the delivery."""
from pathlib import Path
import argparse,datetime,json
from zoneinfo import ZoneInfo
import build
import x3_native_oracle

r=build.ROOT
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('candidate_result',help='reports/<stamp>/result.json written by build.py --output')
candidate=json.loads(Path(parser.parse_args().candidate_result).read_text())
assert candidate['candidate']
stamp=datetime.datetime.now(ZoneInfo('America/Lima')).strftime('%Y%m%d-%H%M%S')
d=r/'reports/x3-charge-20261024'/stamp;d.mkdir(parents=True)
source_map=Path(candidate['map'])
assert build.digest(source_map.read_bytes())==candidate['sha256']
names=candidate['libraries']
for n in names:assert build.digest((r/f'src/libraries/{n}.j').read_bytes())==candidate['library_sha256'][n]
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
s+='\n'+(r/'scripts/X3ChargeProbe.j').read_text().replace('@RUN@',stamp)
s+='\n'+build.map_script(Path(candidate['build_directory'])/'base/war3map.j').decode()
(d/'input.j').write_text(s)
build.run(['vjass',d/'input.j',d/'compiled.j'],d/'compile.json')
target=r/f'maps/work/TerrainDev-x3-charge-{stamp}.w3x'
build.run(['wc3ctl','file','set',source_map,'war3map.j',d/'compiled.j','-o',target,'--json'],d/'pack.json')
build.run(['wc3ctl','extract',target,'war3map.j','--out',d/'reextracted.j','--json'],d/'extract.json')
assert (d/'compiled.j').read_bytes()==(d/'reextracted.j').read_bytes()
build.run(['pjass',d/'reextracted.j'],d/'pjass.json')
prefix=r/'build/x3-runtime/pfx'
stages=[['x3','-x3test',65],['colors','-testcolors',20],['rapid','-rapid',45],['native','-native',60],['charge','-charge',75]]
info={'run':stamp,'directory':str(d),'map':str(target),'sha256':build.digest(target.read_bytes()),
      'candidate_result':str(Path(candidate['report_directory'])/'result.json'),'candidate_sha256':candidate['sha256'],
      'production_sha256':build.digest((r/'TerrainDev.w3x').read_bytes()),'prefix':str(prefix),
      'log_directory':str(prefix/'drive_c/WarcraftIII/CustomMapData/Logs'),'stages':stages}
for tag,_,_ in stages:assert not (Path(info['log_directory'])/f'TerrainDev-{stamp}-{tag}.txt').exists()
(d/'fixture.json').write_text(json.dumps(info,indent=2))
(r/'reports/current-x3-charge-test.json').write_text(json.dumps(info,indent=2))
print(d)
