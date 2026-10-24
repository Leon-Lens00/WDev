"""Isolated Classic visual fixture; generated JASS is compiled, not graph-expanded."""
from pathlib import Path
import json, struct, subprocess, hashlib, shutil, datetime

ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT.parent
BUILD=ROOT/'build'/('vol-ii-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))
BUILD.mkdir(parents=True,exist_ok=False)
WC3='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py'
def call(*args):
    r=subprocess.run(args,capture_output=True,text=True)
    with (BUILD/'commands.log').open('a') as f:f.write(' '.join(args)+'\n'+r.stdout+r.stderr+'\n')
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    return r.stdout

manifest=json.loads((ROOT/'evidence/vol-ii/build-manifest.json').read_text())
palette=json.loads((ROOT/'assets/palette.json').read_text())
imports={}
models=[]
for e in manifest['entries']:
    if e['pack']!='players':continue
    p=ROOT/e['path'];internal='ShotsVolII\\'+p.name
    imports[internal]=p;models.append((internal,palette[e['color']]['name'],e['color']))
for p in (ROOT/'exports/shots-vol-ii-jugadores/ShotsVolII').glob('*.blp'):imports['ShotsVolII\\'+p.name]=p
for pack,prefix in [('originales','Original'),('anclaje','Anclaje')]:
    base=PROJECT/'descargas/warcraft3/misiles/vinz/shots-vol-ii/originales/Shots Vol. II' if pack=='originales' else ROOT/'exports/shots-vol-ii-anclaje'
    for p in sorted(base.glob('*.mdx')):
        internal=prefix+'\\'+p.name;imports[internal]=p;models.append((internal,prefix+' '+p.stem.removeprefix('Shot II '),0))
assert len(models)==24
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
    real modelScale = 1.
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
            exitwhen i == 24
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
    if s == "-move" then
        set moving = not moving
        set moveTime = 0.
    elseif s == "-scale" then
        if modelScale < 2. then
            set modelScale = 3.
        else
            set modelScale = 0.5
        endif
        loop
            exitwhen i == 24
            call SetUnitScale(modelUnit[i], modelScale, modelScale, modelScale)
            set i = i + 1
        endloop
    elseif s == "-stand" or s == "-birth" or s == "-impact" then
        loop
            exitwhen i == 24
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

function Gallery takes nothing returns nothing
    local trigger chat = CreateTrigger()
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
    y=2500+(1.5-i//6)*350
    body.append(f'''    set baseX[{i}] = {x}
    set baseY[{i}] = {y}
    set modelUnit[{i}] = CreateUnit(Player(0), 'q{i:03}', baseX[{i}], baseY[{i}], 0.)
    call SetUnitFlyHeight(modelUnit[{i}], 100., 0.)
    call SetUnitInvulnerable(modelUnit[{i}], true)
    call SetUnitScale(modelUnit[{i}], modelScale, modelScale, modelScale)
    call SetUnitAnimation(modelUnit[{i}], "stand")
    call Tags({i}, "{label}")
''')
tail='''    call TriggerRegisterPlayerChatEvent(chat, Player(0), "-", false)
    call TriggerAddAction(chat, function Chat)
    call TimerStart(CreateTimer(), 0.03, true, function Move)
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "SHOTS VOL II | first 2 rows: player colors | row 3: originals | row 4: anchored | + origin | -stand -birth -impact -scale -move")
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
out=BUILD/'ShotsII.w3x'
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
(ROOT/'evidence/vol-ii/fixture.json').write_text(json.dumps(metadata,indent=2)+'\n')
print(json.dumps(metadata))
