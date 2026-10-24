"""Isolated Classic visual fixture; generated JASS is compiled, not graph-expanded."""
from pathlib import Path
import json, struct, subprocess, hashlib, shutil, datetime

ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT.parent
BUILD=ROOT/'build'/('galeria-gradiente-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))
BUILD.mkdir(parents=True,exist_ok=False)
WC3='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py'
def call(*args):
    r=subprocess.run(args,capture_output=True,text=True)
    with (BUILD/'commands.log').open('a') as f:f.write(' '.join(args)+'\n'+r.stdout+r.stderr+'\n')
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    return r.stdout

manifest=json.loads((ROOT/'evidence/brillo/gradient-build.json').read_text())
palette=json.loads((ROOT/'assets/palette.json').read_text())
imports={};models=[]
for e in manifest['entries']:
    p=ROOT/e['path'];prefix='ShotsTeam' if e['volume']=='I' else 'ShotsVolII'
    internal=prefix+'\\'+p.name;imports[internal]=p
    models.append((internal,palette[e['color']]['label'],e['color']))
    for t in p.parent.glob('*.blp'):imports[prefix+'\\'+t.name]=t
assert len(models)==36
def string(s):return s.encode()+b'\0'
def mod(key,kind,value):return key.encode()+struct.pack('<i',kind)+(string(value) if kind==3 else struct.pack('<f' if kind in [1,2] else '<i',value))+b'\0'*4
objects=[]
for i,(path,label,color) in enumerate(models):
    fields=[mod('umdl',3,path),mod('unam',3,label),mod('umvs',0,0),mod('umvt',3,'fly'),mod('ushd',3,''),mod('uabi',3,'Aloc'),mod('ucol',2,0),mod('usca',2,1)]
    objects.append(b'hfoo'+f'q{i:03}'.encode()+struct.pack('<i',len(fields))+b''.join(fields))
(BUILD/'war3map.w3u').write_bytes(struct.pack('<iii',1,0,len(objects))+b''.join(objects))
(BUILD/'war3map.imp').write_bytes(struct.pack('<ii',1,len(imports))+b''.join(b'\r'+string(p) for p in imports))

head='''globals
    unit array modelUnit
    texttag array labelTag
    texttag array originTag
    real array baseX
    real array baseY
    real modelScale = 1.5
    integer galleryGroup = 0
    real moveTime = 0.
    boolean moving = false
endglobals

function Tags takes integer i, string name returns nothing
    set labelTag[i] = CreateTextTag()
    call SetTextTagText(labelTag[i], name, 0.016)
    call SetTextTagColor(labelTag[i], 255, 255, 255, 255)
    call SetTextTagPermanent(labelTag[i], true)
    call SetTextTagPosUnit(labelTag[i], modelUnit[i], 60.)
    set originTag[i] = CreateTextTag()
    call SetTextTagText(originTag[i], "+", 0.02)
    call SetTextTagColor(originTag[i], 255, 220, 80, 255)
    call SetTextTagPermanent(originTag[i], true)
    call SetTextTagPosUnit(originTag[i], modelUnit[i], 0.)
endfunction

function Move takes nothing returns nothing
    local integer i = 0
    if moving then
        set moveTime = moveTime + 0.03
        if moveTime > 2. then
            set moveTime = 0.
        endif
        loop
            exitwhen i == 36
            call SetUnitX(modelUnit[i], baseX[i] - 180. + 180. * moveTime)
            call SetTextTagPosUnit(labelTag[i], modelUnit[i], 60.)
            call SetTextTagPosUnit(originTag[i], modelUnit[i], 0.)
            set i = i + 1
        endloop
    endif
endfunction

function Chat takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer i = 0
    if s == "-group" then
        set galleryGroup = ModuloInteger(galleryGroup + 1, 3)
        loop
            exitwhen i == 36
            call ShowUnit(modelUnit[i], i / 12 == galleryGroup)
            call SetTextTagVisibility(labelTag[i], i / 12 == galleryGroup)
            call SetTextTagVisibility(originTag[i], i / 12 == galleryGroup)
            set i = i + 1
        endloop
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 5., "GROUP " + I2S(galleryGroup) + " | 0=Vol I simple, 1=Vol I doble, 2=Vol II simple")
    elseif s == "-move" then
        set moving = not moving
        set moveTime = 0.
    elseif s == "-scale" then
        if modelScale < 2. then
            set modelScale = 3.
        else
            set modelScale = 0.5
        endif
        loop
            exitwhen i == 36
            call SetUnitScale(modelUnit[i], modelScale, modelScale, modelScale)
            set i = i + 1
        endloop
    elseif s == "-stand" or s == "-birth" or s == "-impact" then
        loop
            exitwhen i == 36
            if s == "-impact" then
                call SetUnitAnimation(modelUnit[i], "death")
            elseif s == "-birth" then
                call SetUnitAnimation(modelUnit[i], "birth")
            else
                call SetUnitAnimation(modelUnit[i], "stand")
            endif
            set i = i + 1
        endloop
    endif
endfunction

function ClearTree takes nothing returns nothing
    call RemoveDestructable(GetEnumDestructable())
endfunction

function Gallery takes nothing returns nothing
    local trigger chat = CreateTrigger()
    call EnumDestructablesInRect(GetWorldBounds(), null, function ClearTree)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 2900., 0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 290., 0.)
    call SetCameraField(CAMERA_FIELD_ZOFFSET, 200., 0.)
    call SetCameraPosition(-4000., 2500.)
    call PanCameraToTimed(-4000., 2500., 0.)
'''
body=[]
for i,(path,label,color) in enumerate(models):
    x=-4000+(i%6-2.5)*420
    y=2500+(0.5-(i%12)//6)*440
    body.append(f'''    set baseX[{i}] = {x}
    set baseY[{i}] = {y}
    set modelUnit[{i}] = CreateUnit(Player(0), 'q{i:03}', baseX[{i}], baseY[{i}], 0.)
    call SetUnitFlyHeight(modelUnit[{i}], 100., 0.)
    call SetUnitInvulnerable(modelUnit[{i}], true)
    call SetUnitScale(modelUnit[{i}], modelScale, modelScale, modelScale)
    call SetUnitAnimation(modelUnit[{i}], "stand")
    call Tags({i}, "{label}")
    call ShowUnit(modelUnit[{i}], {str(i<12).lower()})
    call SetTextTagVisibility(labelTag[{i}], {str(i<12).lower()})
    call SetTextTagVisibility(originTag[{i}], {str(i<12).lower()})
''')
tail='''    call TriggerRegisterPlayerChatEvent(chat, Player(0), "-", false)
    call TriggerAddAction(chat, function Chat)
    call TimerStart(CreateTimer(), 0.03, true, function Move)
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "SHOTS GRADIENT | -group: I simple / I double / II simple | -stand -birth -impact -scale -move")
    set chat = null
endfunction

function main takes nothing returns nothing
    call SetCameraBounds(-27000., -27000., 6000., 6000., -27000., 6000., 6000., -27000.)
    call SetDayNightModels("Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronTerrain\\\\DNCLordaeronTerrain.mdl", "Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronUnit\\\\DNCLordaeronUnit.mdl")
    call InitBlizzard()
    call TimerStart(CreateTimer(), 0.1, false, function Gallery)
endfunction

function config takes nothing returns nothing
    call SetMapName("Shots Vol II Lab")
    call SetMapDescription("Classic 1.27b model comparison")
    call SetPlayers(1)
    call SetTeams(1)
    call DefineStartLocation(0, -4000., 2500.)
    call SetPlayerStartLocation(Player(0), 0)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)
    call SetPlayerColor(Player(0), PLAYER_COLOR_RED)
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
endfunction
'''
(BUILD/'source.j').write_text(head+''.join(body)+tail)
call('python',WC3,'vjass',str(BUILD/'source.j'),str(BUILD/'compiled.j'))
base=PROJECT/'TerrainDev/maps/originals/TerrainDev.w3x'
out=BUILD/'ShotsBrillo.w3x'
shutil.copy2(base,out)
changes=[('war3map.j',BUILD/'compiled.j'),('war3map.w3u',BUILD/'war3map.w3u'),('war3map.imp',BUILD/'war3map.imp')]+list(imports.items())
current=out
for i,(name,p) in enumerate(changes):
    stage=BUILD/f'stage-{i}.w3x'
    call('python',WC3,'wc3ctl','file','set',str(current),name,str(p),'--out',str(stage),'--json')
    current=stage
shutil.copy2(current,out)
for i,(name,p) in enumerate(changes):
    target=BUILD/f'verified-{i}.bin'
    call('python',WC3,'wc3ctl','extract',str(out),name,'-o',str(target),'--json')
    assert target.read_bytes()==p.read_bytes(),name
metadata={'map':str(out),'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'baseSha256':hashlib.sha256(base.read_bytes()).hexdigest(),'membersVerified':len(changes),'models':len(models),'compiled':'PASS','reextraction':'PASS'}
(BUILD/'fixture.json').write_text(json.dumps(metadata,indent=2)+'\n')
(ROOT/'evidence/brillo/gallery-fixture.json').write_text(json.dumps(metadata,indent=2)+'\n')
print(json.dumps(metadata))
