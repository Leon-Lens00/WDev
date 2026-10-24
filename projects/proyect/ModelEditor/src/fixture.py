"""Build an isolated visual arena. No production map/library changes.

The generated JASS is compiled separately against the installed Classic APIs;
CodeGraph indexes this Python generator, not JASS semantics inside strings.
"""
from pathlib import Path
import struct
import json
import subprocess
import shutil
import hashlib
import sys

ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT.parent
BUILD=ROOT/'build'/('visual-'+(sys.argv[1] if len(sys.argv)>1 else '20261022b'))
BUILD.mkdir(parents=True,exist_ok=True)
WC3='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py'
NODE='/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/runtime-linux/node-v22.14.0-linux-x64/bin/node'
def call(*args):
    r=subprocess.run(list(args),capture_output=True,text=True)
    with (BUILD/'commands.log').open('a') as f:f.write(' '.join(args)+'\n'+r.stdout+r.stderr+'\n')
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    return r.stdout

palette=json.loads((ROOT/'assets/palette.json').read_text())
imports=[]
for p in (ROOT/'exports/shots-vol-i-jugadores/ShotsTeam').glob('*'):
    if p.suffix in ['.blp','.mdx']:imports.append(('ShotsTeam\\'+p.name,p))
for name in ['Blue','Red']:
    for double in [False,True]:
        filename='Shot '+name+(' Double' if double else '')+'.mdx'
        imports.append(('Original\\'+filename,PROJECT/'descargas/warcraft3/misiles/vinz/shots-vol-i/originales/Shots Vol. I'/filename))
        imports.append(('Anchored\\'+filename,ROOT/'exports/shots-vol-i-anclaje'/filename))

# Native teamcolor prototype: retain valid particle texture references; add a
# replaceable texture for mesh layers. PE2 ReplaceableId substitutes its mask.
prototype=BUILD/'NativeTeam.mdx'
script="""
const c=require('./ModelEditor/src/model.cjs');
const m=c.read('ModelEditor/exports/shots-vol-i-anclaje/Shot Blue.mdx');
const Texture=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/texture').default;
const t=new Texture();t.replaceableId=2;m.textures.push(t);
for(const material of m.materials)for(const layer of material.layers){layer.textureId=m.textures.length-1;}
for(const g of m.geosetAnimations)g.color.fill(1);
for(const e of m.particleEmitters2){e.replaceableId=2;for(const color of e.segmentColors)color.fill(1);}
m.name='NativeTeam_Prototype';
c.save(m,process.argv[1]);
"""
call(NODE,'-e',script,str(prototype))
imports.append(('Probe\\NativeTeam.mdx',prototype))

models=[]
for double in [False,True]:
    for color in palette:
        filename=f"Shot_{color['index']:02}_{color['name']}"+('_Double' if double else '')+'.mdx'
        models.append(('ShotsTeam\\'+filename,color['name']+(' Double' if double else ''),color['index']))
models += [('Original\\Shot Blue.mdx','Original Blue',0),('Original\\Shot Red.mdx','Original Red',0),('Anchored\\Shot Blue.mdx','Anchor Blue',0),('Anchored\\Shot Red.mdx','Anchor Red',0),('Probe\\NativeTeam.mdx','Native owner RED',0),('Probe\\NativeTeam.mdx','Native owner BLUE',1)]
def packstring(s):return s.encode()+b'\0'
def mod(field,kind,value):return field.encode()+struct.pack('<i',kind)+(packstring(value) if kind==3 else struct.pack('<f' if kind in (1,2) else '<i',value))+b'\0'*4
objects=[]
for i,(model,label,color) in enumerate(models):
    fields=[mod('umdl',3,model),mod('unam',3,label),mod('umvs',0,0),mod('umvt',3,'fly'),mod('ushd',3,''),mod('ucol',2,0),mod('uabi',3,'Aloc'),mod('usca',2,1)]
    objects.append(b'hfoo'+f'z{i:03}'.encode()+struct.pack('<i',len(fields))+b''.join(fields))
(BUILD/'war3map.w3u').write_bytes(struct.pack('<iii',1,0,len(objects))+b''.join(objects))
(BUILD/'war3map.imp').write_bytes(struct.pack('<ii',1,len(imports))+b''.join(b'\r'+packstring(name) for name,p in imports))

header='''globals
    unit array gallery
    integer sceneTick = 0
    real galleryScale = 1.5
endglobals

function Label takes string label, real x, real y returns nothing
    local texttag tag = CreateTextTag()
    local location p = Location(x, y)
    call SetTextTagText(tag, label, 0.018)
    call SetTextTagPos(tag, x - 110., y - 85., 550. - GetLocationZ(p))
    call SetTextTagPermanent(tag, true)
    call SetTextTagColor(tag, 255, 255, 255, 255)
    call RemoveLocation(p)
    set p = null
    set tag = null
endfunction

function Phase takes nothing returns nothing
    local integer i = 0
    set sceneTick = sceneTick + 1
    loop
        exitwhen i >= 30
        if ModuloInteger(sceneTick, 8) == 5 then
            call SetUnitAnimation(gallery[i], "death")
        elseif ModuloInteger(sceneTick, 8) == 7 then
            call SetUnitAnimation(gallery[i], "birth")
        elseif ModuloInteger(sceneTick, 8) == 0 then
            call SetUnitAnimation(gallery[i], "stand")
        endif
        set i = i + 1
    endloop
endfunction

function Chat takes nothing returns nothing
    local integer i = 0
    local string s = GetEventPlayerChatString()
    if s == "-scale" then
        if galleryScale < 2. then
            set galleryScale = 3.
        else
            set galleryScale = 0.5
        endif
        loop
            exitwhen i >= 30
            call SetUnitScale(gallery[i], galleryScale, galleryScale, galleryScale)
            set i = i + 1
        endloop
    elseif s == "-pause" then
        call PauseTimer(bj_lastStartedTimer)
    elseif s == "-resume" then
        call ResumeTimer(bj_lastStartedTimer)
    elseif s == "-impact" or s == "-stand" or s == "-birth" then
        call PauseTimer(bj_lastStartedTimer)
        loop
            exitwhen i >= 30
            if s == "-impact" then
                call SetUnitAnimation(gallery[i], "death")
            elseif s == "-birth" then
                call SetUnitAnimation(gallery[i], "birth")
            else
                call SetUnitAnimation(gallery[i], "stand")
            endif
            set i = i + 1
        endloop
    endif
endfunction

function InitGallery takes nothing returns nothing
    local integer i = 0
    local integer j = 0
    local real x
    local real y
    local location loc
    local trigger t = CreateTrigger()
    local rect arena = Rect(-5500., 1000., -2500., 4000.)
    call EnumDestructablesInRect(arena, null, function ClearScenery)
    call RemoveRect(arena)
    set arena = null
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 2700., 0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 290., 0.)
    call SetCameraField(CAMERA_FIELD_ZOFFSET, 450., 0.)
    call SetCameraPosition(-4000., 2500.)
    call PanCameraToTimed(-4000., 2500., 0.)
'''
# Native SetTimeOfDay does not exist; use the Classic game state setter above.
header=header.replace('    call SetTimeOfDay(12.)\n','')
header=header.replace('function InitGallery takes', 'function ClearScenery takes nothing returns nothing\n    call RemoveDestructable(GetEnumDestructable())\nendfunction\n\nfunction InitGallery takes')
body=[]
for i,(model,label,color) in enumerate(models):
    x=-4000+(i%6-2.5)*350
    y=2500+(2-i//6)*300
    body.append(f'''    set loc = Location({x}, {y})
    set gallery[{i}] = CreateUnit(Player({color}), 'z{i:03}', {x}, {y}, 0.)
    call SetUnitFlyHeight(gallery[{i}], 600. - GetLocationZ(loc), 0.)
    call SetUnitScale(gallery[{i}], galleryScale, galleryScale, galleryScale)
    call SetUnitInvulnerable(gallery[{i}], true)
    call SetUnitColor(gallery[{i}], ConvertPlayerColor({color}))
    call SetUnitAnimation(gallery[{i}], "stand")
    call RemoveLocation(loc)
    call Label("{label}", {x}, {y})
''')
footer='''    set bj_lastStartedTimer = CreateTimer()
    call TimerStart(bj_lastStartedTimer, 1., true, function Phase)
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-", false)
    call TriggerAddAction(t, function Chat)
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "SHOTS LAB 1.27b | 12 simple + 12 double | bottom: original/anchor/native | -pause / -scale")
    set loc = null
    set t = null
endfunction

function main takes nothing returns nothing
    call SetCameraBounds(-27000., -27000., 6000., 6000., -27000., 6000., 6000., -27000.)
    call SetDayNightModels("Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronTerrain\\\\DNCLordaeronTerrain.mdl", "Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronUnit\\\\DNCLordaeronUnit.mdl")
    call InitBlizzard()
    call TimerStart(CreateTimer(), 0.1, false, function InitGallery)
endfunction

function config takes nothing returns nothing
    local integer i = 0
    call SetMapName("Shots Lab 1.27b")
    call SetMapDescription("Isolated model visual comparison")
    call SetPlayers(12)
    call SetTeams(1)
    loop
        exitwhen i >= 12
        call DefineStartLocation(i, -4000., 2500.)
        call SetPlayerStartLocation(Player(i), i)
        call SetPlayerColor(Player(i), ConvertPlayerColor(i))
        call SetPlayerTeam(Player(i), 0)
        call SetPlayerRacePreference(Player(i), RACE_PREF_HUMAN)
        if i == 0 then
            call SetPlayerController(Player(i), MAP_CONTROL_USER)
        else
            call SetPlayerController(Player(i), MAP_CONTROL_COMPUTER)
        endif
        set i = i + 1
    endloop
endfunction
'''
generated_source=header+''.join(body)+footer
old_source=(BUILD/'source.j').read_text() if (BUILD/'source.j').exists() else None
(BUILD/'source.j').write_text(generated_source)
compiled=BUILD/'compiled.j'
if not compiled.exists():call('python',WC3,'vjass',str(BUILD/'source.j'),str(compiled))
elif old_source==generated_source:call('python',WC3,'pjass',str(compiled))
else:raise RuntimeError('Source changed: choose a new fixture directory before compiling')
base=PROJECT/'TerrainDev/maps/originals/TerrainDev.w3x'
out=BUILD/'ShotsLab.w3x'
shutil.copy2(base,out)
changes=[('war3map.j',compiled),('war3map.w3u',BUILD/'war3map.w3u'),('war3map.imp',BUILD/'war3map.imp')]+imports
current=out
for i,(name,p) in enumerate(changes):
    stage=BUILD/f'stage-{i}.w3x'
    call('python',WC3,'wc3ctl','file','set',str(current),name,str(p),'--out',str(stage),'--json')
    current=stage
shutil.copy2(current,out)
for i,(name,p) in enumerate(changes):
    check=BUILD/f'reextract-{i}.bin'
    call('python',WC3,'wc3ctl','extract',str(out),name,'-o',str(check),'--json')
    assert check.read_bytes()==p.read_bytes(),name
(BUILD/'fixture.json').write_text(json.dumps({'map':str(out),'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'baseSha256':hashlib.sha256(base.read_bytes()).hexdigest(),'membersVerified':len(changes),'models':len(models),'imports':[name for name,p in imports]},indent=2)+'\n')
print(out)
