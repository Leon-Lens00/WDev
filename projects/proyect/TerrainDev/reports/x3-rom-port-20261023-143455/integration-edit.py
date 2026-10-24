from pathlib import Path
import json,hashlib
r=Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev')
p=r/'src/libraries/X3BusterDemo.j'
s=p.read_text().replace('private function Cast', '''// Compatibility fixtures may opt into GIF; delivered W/E use the USA profile.
struct X3Demo extends array
    static integer profile = X3Buster.ORIGINAL
endstruct
private function Cast''',1).replace('local integer mode = 0','local integer mode = 0\n    local integer profile = X3Demo.profile').replace("if GetSpellAbilityId() == 'Ax3s' then", "if GetSpellAbilityId() == 'Ax3s' or GetSpellAbilityId() == 'Ax3z' then").replace('set shot = X3Buster.fire(pair.actor,GetSpellTargetX(),GetSpellTargetY(),mode)', '''if GetSpellAbilityId() == 'Ax3z' then
            set profile = X3Buster.ZERO_PROJECT
        endif
        set shot = X3Buster.fireProfile(pair.actor,GetSpellTargetX(),GetSpellTargetY(),mode,profile)''').replace("call RegisterSpellEffectEvent('Ax3s',function Cast)","call RegisterSpellEffectEvent('Ax3s',function Cast)\n    call RegisterSpellEffectEvent('Ax3z',function Cast)")
p.write_text(s)
p=r/'src/Main.j';s=p.read_text().replace('//! import "libraries/X3Buster.j"','//! import "libraries/X3Kinematics.j"\n//! import "libraries/X3Buster.j"');p.write_text(s)
p=r/'scripts/build.py';s=p.read_text().replace('Arpf,Ax3c,Ax3s,Avul','Arpf,Ax3c,Ax3s,Ax3z,Avul').replace("'Arpf','Ax3c','Ax3s')","'Arpf','Ax3c','Ax3s','Ax3z')");p.write_text(s)
p=r/'scripts/x3_objects.py';s=p.read_text().replace('Two Classic Channel abilities','Three Classic Channel abilities').replace("'Cross Buster', 'E'","'Cross Buster USA', 'E'").replace("'Orbes giratorios, pulso posterior y fusion por alcance. Cuatro satelites tras la union.')","'Tres componentes, pulso posterior y fusion USA. Nucleo y cuatro satelites tras la formacion.'),\n        ('Ax3z', 'Cross Buster Zero Project', 'R', 'breathoffire', 3,\n         'Variante Zero Project 4.1: formacion rapida y trayectorias curvadas de cuatro satelites.')");p.write_text(s)
p=r/'scripts/X3Probe.j';s=p.read_text().replace('private function Init takes nothing returns nothing\n    local trigger t = CreateTrigger()','''function X3ProbeLaneX takes nothing returns real
    return sx
endfunction
function X3ProbeLaneY takes nothing returns real
    return sy
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    set X3Demo.profile = X3Buster.GIF''');p.write_text(s)
p=r/'src/libraries/X3Buster.j';s=p.read_text().replace('readonly integer state // 0 charged; 1 orbit/pulse; 2 fused; 3 cancelled','readonly integer state // 0 charged; 1 orbit/pulse; 2 fused; 3 cancelled; 4 forming');p.write_text(s)
p=r/'libraries.json';d=json.loads(p.read_text());i=d['order'].index('X3Buster');d['order'].insert(i,'X3Kinematics');d['libraries'].append({'name':'X3Kinematics','version':'1.0.0-local','local_file':'src/libraries/X3Kinematics.j','source':'Local mathematical port measured against X3 USA / Zero Project 4.1 SNES traces; labs/x3-snes','dependencies':[]})
for l in d['libraries']:
 if l['name']=='X3Buster':
  l.update(version='0.3.0-rom-profiles',source='Local Warcraft adaptation with USA and Zero Project 4.1 profiles, 2026-10-23');l['dependencies'].append('X3Kinematics')
 if l['name']=='X3BusterDemo':l.update(version='0.2.0-local',source='Local demonstration: W/E USA, R Zero Project 4.1, 2026-10-23')
 l['local_sha256']=hashlib.sha256((r/l['local_file']).read_bytes()).hexdigest()
p.write_text(json.dumps(d,indent=2)+'\n')
