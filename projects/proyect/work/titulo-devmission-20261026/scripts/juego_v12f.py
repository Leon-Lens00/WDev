"""Dev Mission title v12f (30/10/2026): from the presentation to the play zone, for the multiplayer tests.

- Melee data out of the script: initialization, TurtleNet and start locations in the melee area (time of day kept).
- Each playing user gets the chosen character (base 'otau' or 'Ocbh'; Tauren if nothing valid was chosen) in the low
  ground of the bottom-right zone, allied with the others, with a camera of its own. The character belongs to an unused
  slot and that slot shares control, so the native hero icon does not appear.
- HealthBars per player: each player has its own bars, placed from its own camera and seen only by that player
  (local alpha and local texttags: visual only). The icon is the one of the character. The enemy bar only exists
  while HealthBarsTarget has a target, which nothing sets until a boss fight exists.
- Title_Exit removes everything the entry created: units of the dummy owner that were not there at Title_Init,
  texttags, timers, the plane effect. Trackables cannot be removed; their triggers are disabled.
- Boss selection: clicking a "?" shows the band, as in hero selection, with the error sound.

Usage: juego_v12f.py IN_J OUT_J
"""
from pathlib import Path
import math
import re
import sys

import puente_v12 as base

ZONE_X, ZONE_Y, RING = 1408, -23168, 220
SPOTS = [(round(ZONE_X + RING * math.cos(math.radians(22.5 + 45 * i))),
          round(ZONE_Y + RING * math.sin(math.radians(22.5 + 45 * i)))) for i in range(8)]

GLOBALS = '''group Title_Keep = null
boolean array Game_On
unit array Game_Hero
integer array Game_Cam
integer Game_First = -1
integer Game_NextOwner = 8
boolean array HealthBars__Bound
unit array HealthBars__Heroes
unit array HealthBars__HeroBars
unit array HealthBars__EnemyBars
integer array HealthBars__Cams
integer array HealthBars__HeroValues
integer array HealthBars__EnemyValues
integer array HealthBars__HeroPcts
integer array HealthBars__EnemyPcts
'''

DUMMY = '''function HealthBars__Dummy takes integer rawcode,integer p returns unit
    local unit u= CreateUnit(CAMERA_DUMMY_PLAYER, rawcode, 0, 0, 270)
    local integer alpha= 0
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call SetUnitInvulnerable(u, true)
    call SetUnitBlendTime(u, 0.)
    // v12f: every client has every bar, near that player's camera; only its owner sees it.
    if GetLocalPlayer() == Player(p) then
        set alpha=255
    endif
    call SetUnitVertexColor(u, 255, 255, 255, alpha)
    return u
endfunction
'''

TARGET = '''function HealthBarsTarget takes unit u returns boolean
    local integer kind= 0
    local boolean supported= true
    local integer p= 0
    if u != null and GetUnitTypeId(u) == 'otau' then
        set kind='hbet'
    elseif u != null and GetUnitTypeId(u) == 'Hpal' then
        set kind='hbep'
    elseif u != null then
        // Unregistered unit: hide instead of displaying the wrong native icon.
        set supported=false
        set u=null
    endif
    loop
        exitwhen p > 11
        if kind != HealthBars__EnemyType and HealthBars__EnemyBars[p] != null then
            call RemoveUnit(HealthBars__EnemyBars[p])
            set HealthBars__EnemyBars[p]=null
        endif
        if kind != HealthBars__EnemyType and kind != 0 and HealthBars__Bound[p] then
            set HealthBars__EnemyBars[p]=HealthBars__Dummy(kind , p)
        endif
        set HealthBars__EnemyPcts[p]=- 1
        set p=p + 1
    endloop
    set HealthBars__EnemyType=kind
    set HealthBars__Target=u
    return supported
endfunction
'''

VISIBLE = '''function HealthBarsSetVisible takes boolean flag returns nothing
    local integer p= 0
    set HealthBars__Visible=flag
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            call ShowUnit(HealthBars__HeroBars[p], flag)
            call s__UIText_show(HealthBars__HeroValues[p],flag , HealthBars__Cams[p])
            if HealthBars__EnemyBars[p] != null then
                call ShowUnit(HealthBars__EnemyBars[p], flag)
            endif
            call s__UIText_show(HealthBars__EnemyValues[p],flag and HealthBars__Target != null , HealthBars__Cams[p])
        endif
        set p=p + 1
    endloop
endfunction
'''

UPDATE = '''function HealthBarsUpdate takes nothing returns nothing
    local integer p= 0
    local integer pct
    local integer cam
    local string label
    local boolean shown
    local boolean poll
    if not HealthBars__Ready then
        return
    endif
    set HealthBars__PollTime=HealthBars__PollTime + 0.01
    set poll=HealthBars__PollTime >= 0.05
    if poll then
        set HealthBars__PollTime=0
    endif
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            set cam=HealthBars__Cams[p]
            set shown=HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0
            call ShowUnit(HealthBars__HeroBars[p], shown)
            call s__UIText_show(HealthBars__HeroValues[p],shown , cam)
            if shown then
                call HealthBars__Place(HealthBars__HeroBars[p] , cam , 24. , 48.6)
            endif
            set shown=HealthBars__Visible and HealthBars__Target != null and GetUnitTypeId(HealthBars__Target) != 0
            if HealthBars__EnemyBars[p] != null then
                call HealthBars__Place(HealthBars__EnemyBars[p] , cam , 1358.4 , 48.6)
                call ShowUnit(HealthBars__EnemyBars[p], shown)
            endif
            call s__UIText_show(HealthBars__EnemyValues[p],shown , cam)
            if poll then
                set pct=HealthBars__Percent(HealthBars__Heroes[p])
                if pct != HealthBars__HeroPcts[p] then
                    set HealthBars__HeroPcts[p]=pct
                    call SetUnitAnimationByIndex(HealthBars__HeroBars[p], pct)
                    set label=I2S(pct) + "%"
HEROPOS
                    call SetTextTagText(s__UIText_text[HealthBars__HeroValues[p]], label, 0.017)
                endif
                if HealthBars__EnemyBars[p] != null then
                    set pct=HealthBars__Percent(HealthBars__Target)
                    if pct != HealthBars__EnemyPcts[p] then
                        set HealthBars__EnemyPcts[p]=pct
                        call SetUnitAnimationByIndex(HealthBars__EnemyBars[p], pct)
                        set label=I2S(pct) + "%"
ENEMYPOS
                        call SetTextTagText(s__UIText_text[HealthBars__EnemyValues[p]], label, 0.017)
                    endif
                endif
            endif
        endif
        set p=p + 1
    endloop
endfunction
'''

BIND = '''// v12f: player p's panel, tied to its camera and character; kind is the bar unit of that character.
function HealthBarsBindPlayer takes integer p,integer cam,unit hero,integer kind returns nothing
    set HealthBars__Cams[p]=cam
    set HealthBars__Heroes[p]=hero
    set HealthBars__HeroBars[p]=HealthBars__Dummy(kind , p)
    // UIText has its own measured client fit, as in the dialogue editor.
    set HealthBars__HeroValues[p]=s__UIText_createEx(Player(p) , ( 328. - 960. ) / 728. , ( 420. - 88. ) / 390. , 1.)
    set HealthBars__EnemyValues[p]=s__UIText_createEx(Player(p) , ( 1824. - 960. ) / 728. , ( 420. - 151. ) / 390. , 1.)
    call SetTextTagPermanent(s__UIText_text[HealthBars__HeroValues[p]], true)
    call SetTextTagPermanent(s__UIText_text[HealthBars__EnemyValues[p]], true)
    call SetTextTagColor(s__UIText_text[HealthBars__HeroValues[p]], 199, 247, 255, 255)
    call SetTextTagColor(s__UIText_text[HealthBars__EnemyValues[p]], 199, 247, 255, 255)
    set HealthBars__HeroPcts[p]=- 1
    set HealthBars__EnemyPcts[p]=- 1
    set HealthBars__Bound[p]=true
    set HealthBars__Ready=true
    call HealthBarsSetVisible(true)
    call MultiboardDisplay(s__MissileStats_board, false)
endfunction
'''

LIFE = '''function HealthBarsDemoLife takes boolean hero,integer percent returns nothing
    local unit u= HealthBars__Target
    if hero then
        set u=HealthBars__Heroes[GetPlayerId(GetTriggerPlayer())]
    endif
    if u != null then
        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE) * I2R(IMaxBJ(0, IMinBJ(100, percent))) / 100.)
    endif
    set u=null
endfunction
'''

INIT = '''function HealthBars__Init takes nothing returns nothing
    local trigger chat= CreateTrigger()
    call TriggerRegisterPlayerChatEvent(chat, Player(0), "-misiles", true)
    call TriggerAddAction(chat, function HealthBars__Diagnostics)
endfunction
'''

FOLLOW = '''// Same owner -> Camera -> Interface order as native Inventory.onDisplay.
// v12f: one logical camera per player, all computed on every client because the bars depend on them.
function ConversationUI___FollowCamera takes nothing returns nothing
    local integer p= 0
    local integer cam
    local unit u
    local real x
    local real y
    local real z
    loop
        exitwhen p > 11
        if Game_On[p] then
            set cam=Game_Cam[p]
            set u=Game_Hero[p]
            if GetUnitTypeId(u) != 0 then
                set x=GetUnitX(u)
                set y=GetUnitY(u)
                set z=UserInterface_GetTerrainZ(x , y) + GetUnitFlyHeight(u)
                call s__Camera_setPosition(cam,x , y , z)
                // Absolute reconstruction in this fixed-orientation adapter only.
                // Camera's original setPosition, axes and projection remain unchanged.
                set s__VECTOR3_x[s__Camera_eye[cam]]=x + ConversationUI___EyeOffsetX
                set s__VECTOR3_y[s__Camera_eye[cam]]=y + ConversationUI___EyeOffsetY
                set s__VECTOR3_z[s__Camera_eye[cam]]=z + ConversationUI___EyeOffsetZ
            endif
            call s__Camera_applyCameraForPlayer(cam,Player(p) , true)
        endif
        set p=p + 1
    endloop
    set u=null
endfunction
'''

CALIBRATE = '''function ConversationUI___CalibrateCamera takes nothing returns nothing
    local integer p= 0
    loop
        exitwhen p > 11
        if Game_On[p] then
            call s__Camera_calibrateHeightForPlayer(Game_Cam[p],Player(p))
        endif
        set p=p + 1
    endloop
    call ConversationUI___FollowCamera()
    // The native "control granted" line of the owners set up in Game_Enter.
    call ClearTextMessages()
    call DestroyTimer(GetExpiredTimer())
endfunction
'''

START = '''// v12f: a hero the player owns gets the native icon at the top left. As the Paladin demo did, each character belongs
// to a slot nobody plays and its owner shares basic control. Slots 8-11 first, then user slots left empty; with 7 or 8
// players there are not enough, so some share an owner and Game_Selected keeps each one off the other's hero.
function Game_Owner takes nothing returns player
    local integer i
    loop
        exitwhen Game_NextOwner > 11
        set i = Game_NextOwner
        set Game_NextOwner = Game_NextOwner + 1
        return Player(i)
    endloop
    loop
        exitwhen Game_NextOwner > 19
        set i = Game_NextOwner - 12
        set Game_NextOwner = Game_NextOwner + 1
        if GetPlayerSlotState(Player(i)) != PLAYER_SLOT_STATE_PLAYING then
            return Player(i)
        endif
    endloop
    set i = 8 + ModuloInteger(Game_NextOwner, 4)
    set Game_NextOwner = Game_NextOwner + 1
    return Player(i)
endfunction

function Game_Selected takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local player me = GetTriggerPlayer()
    local integer q = 0
    loop
        exitwhen q > 11
        if Game_On[q] and Game_Hero[q] == u and Player(q) != me and GetLocalPlayer() == me then
            call SelectUnit(u, false)
        endif
        set q = q + 1
    endloop
    set u = null
    set me = null
endfunction

// v12f: player p enters the play zone with the chosen character, base unit for now.
function Game_Enter takes integer p returns nothing
    local integer k= Hero_Choice[p]
    local integer id= 'otau'
    local integer kind= 'hbh0'
    local location start= GetStartLocationLoc(GetPlayerStartLocation(Player(p)))
    local player owner= Game_Owner()
    local trigger t= CreateTrigger()
    if k == 1 then
        set id='Ocbh'
        set kind='hbh1'
    endif
    set Game_Cam[p]=s__Camera_create()
    call SetPlayerAlliance(owner, Player(p), ALLIANCE_PASSIVE, true)
    call SetPlayerAlliance(Player(p), owner, ALLIANCE_PASSIVE, true)
    call SetPlayerAlliance(owner, Player(p), ALLIANCE_SHARED_VISION, true)
    call SetPlayerAlliance(Player(p), owner, ALLIANCE_SHARED_VISION, true)
    call SetPlayerAlliance(owner, Player(p), ALLIANCE_SHARED_CONTROL, true)
    call SetPlayerAlliance(owner, Player(p), ALLIANCE_SHARED_ADVANCED_CONTROL, false)
    call SetPlayerName(owner, GetPlayerName(Player(p)))
    set Game_Hero[p]=CreateUnit(owner, id, GetLocationX(start), GetLocationY(start), 270)
    call SetUnitColor(Game_Hero[p], GetPlayerColor(Player(p)))
    call TriggerRegisterPlayerUnitEvent(t, Player(p), EVENT_PLAYER_UNIT_SELECTED, null)
    call TriggerAddAction(t, function Game_Selected)
    set t=null
    set owner=null
    set Game_On[p]=true
    if Game_First < 0 then
        set Game_First=p
    endif
    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , kind)
    call RemoveLocation(start)
    set start=null
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Game_Hero[p], true)
    endif
endfunction

function ConversationUI___Start takes nothing returns nothing
    local integer i= 0
    local integer j
    local integer eye
    loop
        exitwhen i > 11
        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(i), bj_ALLIANCE_ALLIED_VISION)
        call SetPlayerAllianceStateBJ(Player(i), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
        set j=0
        loop
            exitwhen j > 11
            if i != j then
                call SetPlayerAllianceStateBJ(Player(i), Player(j), bj_ALLIANCE_ALLIED_VISION)
            endif
            set j=j + 1
        endloop
        set i=i + 1
    endloop
    set i=0
    loop
        exitwhen i > 7
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            call Game_Enter(i)
        endif
        set i=i + 1
    endloop
    if Game_First < 0 then
        call DestroyTimer(GetExpiredTimer())
        return
    endif
    // The dialogue still has one camera and one owner: the first player.
    set ConversationUI___Cam=Game_Cam[Game_First]
    set ConversationUI___FollowUnit=Game_Hero[Game_First]
    set eye=ConversationUI___Cam
    set ConversationUI___EyeOffsetX=s__VECTOR3_x[s__Camera_eye[eye]] - s__VECTOR3_x[s__Camera_at[eye]]
    set ConversationUI___EyeOffsetY=s__VECTOR3_y[s__Camera_eye[eye]] - s__VECTOR3_y[s__Camera_at[eye]]
    set ConversationUI___EyeOffsetZ=s__VECTOR3_z[s__Camera_eye[eye]] - s__VECTOR3_z[s__Camera_at[eye]]
    call ConversationUI___FollowCamera()
FRAME
    call TimerStart(ConversationUI___Clock, 0.01, true, function ConversationUI___Tick)
    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)
    call DestroyTimer(GetExpiredTimer())
endfunction
'''

CLEANUP = '''// v12f: everything the entry created goes away with it. Trackables cannot be removed: their triggers are disabled.
function Title_Cleanup takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer i = 0
    call DisableTrigger(Title_HitTrig)
    call DisableTrigger(Title_TrackTrig)
    call PauseTimer(Mode_Timer)
    call PauseTimer(Boss_Timer)
    call PauseTimer(Pres_T)
    call PauseTimer(Entry_Timer)
    if Tx_Timer != null then
        call PauseTimer(Tx_Timer)
        call DestroyTimer(Tx_Timer)
        set Tx_Timer = null
    endif
    loop
        exitwhen i >= Tx_N
        call DestroyTextTag(Tx_T[i])
        set Tx_T[i] = null
        set i = i + 1
    endloop
    set Tx_N = 0
    set i = 0
    loop
        exitwhen i > 11
        if i < 4 then
            call DestroyTextTag(Strat_Tag[i])
            set Strat_Tag[i] = null
        endif
        if Hero_TalkTimer[i] != null then
            call PauseTimer(Hero_TalkTimer[i])
        endif
        call StopSound(Hero_Voice[i], false, false)
        set i = i + 1
    endloop
    if Clock_Tag != null then
        call DestroyTextTag(Clock_Tag)
        set Clock_Tag = null
    endif
    if Title_Plane != null then
        call DestroyEffect(Title_Plane)
        set Title_Plane = null
    endif
    call GroupEnumUnitsOfPlayer(g, CAMERA_DUMMY_PLAYER, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if not IsUnitInGroup(u, Title_Keep) then
            call RemoveUnit(u)
        endif
    endloop
    call DestroyGroup(g)
    call DestroyGroup(Title_Keep)
    set Title_Keep = null
    set g = null
endfunction

'''


def crlf(text):
    return text.replace('\n', base.N)


def function(s, name):
    m = re.search(r'function ' + re.escape(name) + r' takes .*?\r\n\s*endfunction\r\n', s, re.S)
    assert m, name
    assert m.group(0).count('endfunction') == 1, name
    return m


def replace(s, name, new):
    m = function(s, name)
    return s[:m.start()] + crlf(new) + s[m.end():]


def cut(s, start, end):
    """Removes from start up to (not including) end; each must appear once."""
    assert s.count(start) == 1, start
    i = s.index(start)
    j = s.index(end, i)
    return s[:i] + s[j:]


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

    # --- 1. Melee data. MeleeStartingVisibility only set the time of day; the title's light depends on it.
    s = base.once(s, 'trigger gg_trg_Melee_Initialization= null\n', '')
    s = base.once(s, 'trigger gg_trg_TurtleNet= null\n', '')
    s = cut(s, '//===========================================================================' + base.N +
            '// Trigger: Melee Initialization', '//===========================================================================' +
            base.N + 'function InitCustomTriggers takes')
    s = base.once(s, '    call InitTrig_Melee_Initialization()\n    call InitTrig_TurtleNet()\n', '')
    s = base.once(s, '    call ConditionalTriggerExecute(gg_trg_Melee_Initialization)\nendfunction\n', 'endfunction\n')
    s = base.once(s, '    call ConditionalTriggerExecute(gg_trg_Melee_Initialization) // INLINED!!\n',
                  '    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, bj_MELEE_STARTING_TOD)\n')
    for i, (x, y) in enumerate(SPOTS):
        s, n = re.subn(r'call DefineStartLocation\(%d, [^\r]*\)' % i,
                       'call DefineStartLocation(%d, %.1f, %.1f)' % (i, x, y), s)
        assert n == 1, i

    # --- 2. Boss "?": band and error, as Hero_OnHit.
    s = base.once(s, '''    if b >= 0 and b <= 39 and Boss_Icon[b] == 0 then
        call UI_Error(p)
        return
    endif
    if b < 0 or b > 39 or Boss_Choice[p] == b then
        return
    endif
    set Boss_Choice[p] = b
    call UI_Click(p)
''', '''    if b < 0 or b > 39 then
        return
    endif
    if Boss_Choice[p] == b then
        if Boss_Icon[b] == 0 then
            call UI_Error(p)
        endif
        return
    endif
    set Boss_Choice[p] = b
    if Boss_Icon[b] == 0 then
        call UI_Error(p)
    else
        call UI_Click(p)
    endif
''')
    # The strategy panel only has places for bosses that exist; a "?" band goes away there.
    s = base.once(s, '''        if Boss_Choice[k] >= 0 then
            call Hero_Put(Hero_Glow[k], Strat_BX[Boss_Choice[k]], Strat_BY[Boss_Choice[k]])
        endif
''', '''        if Boss_Choice[k] >= 0 and Boss_Icon[Boss_Choice[k]] != 0 then
            call Hero_Put(Hero_Glow[k], Strat_BX[Boss_Choice[k]], Strat_BY[Boss_Choice[k]])
        else
            call Title_Show(Hero_Glow[k], false)
        endif
''')

    # --- 3. HealthBars per player.
    place = function(s, 'HealthBars__Place').group(0)
    new = place.replace('takes unit u,real px,real py', 'takes unit u,integer cam,real px,real py')
    new = new.replace('s__Camera_win2World(HealthBars__BarCamera,', 's__Camera_win2World(cam,')
    assert new.count('cam') >= 2 and 'BarCamera' not in new
    s = s.replace(place, new)
    update = function(s, 'HealthBarsUpdate').group(0)
    hero = next(l for l in update.split(base.N) if 's__UIText_setPosition(HealthBars__HeroValue' in l)
    enemy = next(l for l in update.split(base.N) if 's__UIText_setPosition(HealthBars__EnemyValue' in l)
    hero = ' ' * 20 + hero.strip().replace('HealthBars__HeroValue', 'HealthBars__HeroValues[p]')
    enemy = ' ' * 24 + enemy.strip().replace('HealthBars__EnemyValue', 'HealthBars__EnemyValues[p]')
    s = replace(s, 'HealthBars__Dummy', DUMMY)
    s = replace(s, 'HealthBarsTarget', TARGET)
    s = replace(s, 'HealthBarsSetVisible', VISIBLE)
    s = replace(s, 'HealthBarsUpdate', UPDATE.replace('HEROPOS', hero).replace('ENEMYPOS', enemy))
    s = replace(s, 'HealthBarsBind', BIND)
    s = replace(s, 'HealthBarsDemoLife', LIFE)
    m = function(s, 'HealthBars__Selected')
    s = s[:m.start()] + s[m.end():]
    s = replace(s, 'HealthBars__Init', INIT)

    # --- 4. Game start.
    m = function(s, 'ConversationUI___Start')
    old = m.group(0)
    i = old.index('    // Native UI dummy settings')
    j = old.index('    set ConversationUI___HealthEnemy=CreateUnit')
    frame = old[i:j].replace('x, y, 270', '0, 0, 270')
    assert ' x,' not in frame and ' y,' not in frame
    s = s[:m.start()] + crlf(START).replace('FRAME' + base.N, frame) + s[m.end():]
    s = replace(s, 'ConversationUI___CalibrateCamera', CALIBRATE)
    i = s.index('// Same owner -> Camera -> Interface order as native Inventory.onDisplay.')
    j = s.index('// Public integration point')
    s = s[:i] + crlf(FOLLOW) + base.N + s[j:]
    s = base.once(s, '''unit ConversationUI___ReferenceTauren= null
unit ConversationUI___HealthEnemy= null
''', '')
    s = base.once(s, '''    if s == "-controlbasico" then
        call SetPlayerAlliance(Player(10), Player(0), ALLIANCE_SHARED_ADVANCED_CONTROL, false)
    elseif s == "-controlavanzado" then
        call SetPlayerAlliance(Player(10), Player(0), ALLIANCE_SHARED_ADVANCED_CONTROL, true)
    elseif SubString(s, 0, 11) == "-vidaheroe " then
''', '''    if SubString(s, 0, 11) == "-vidaheroe " then
''')
    s = base.once(s, '''    elseif s == "-barrasobjetivopaladin" then
        call HealthBarsTarget(ConversationUI___FollowUnit)
    elseif s == "-barrasobjetivotauren" then
        call HealthBarsTarget(ConversationUI___HealthEnemy)
''', '')
    s = cut(s, '    elseif s == "-taurenhud" then' + base.N, '    elseif s == "-caminardialogo" then')

    s = s.replace('ConversationUI___ReferenceTauren', 'ConversationUI___FollowUnit')  # only the debug dump is left

    # --- 5. Title exit.
    s = base.once(s, 'function Title_Exit takes nothing returns nothing\n', CLEANUP + 'function Title_Exit takes nothing returns nothing\n')
    s = base.once(s, '''    set Title_Clock = null
    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
''', '''    set Title_Clock = null
    call Title_Cleanup()
    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
''')
    s = base.once(s, '    set Title_HT = InitHashtable()\n    set Title_GZ = GetLocationZ(l)\n',
                  '    set Title_HT = InitHashtable()\n    set Title_Keep = CreateGroup()\n'
                  '    call GroupEnumUnitsOfPlayer(Title_Keep, CAMERA_DUMMY_PLAYER, null)\n    set Title_GZ = GetLocationZ(l)\n')

    for line in ['integer HealthBars__BarCamera= 0', 'unit HealthBars__Hero= null', 'unit HealthBars__HeroBar= null',
                 'unit HealthBars__EnemyBar= null', 'integer HealthBars__HeroPercent= - 1',
                 'integer HealthBars__EnemyPercent= - 1', 'integer HealthBars__HeroValue', 'integer HealthBars__EnemyValue',
                 'unit gg_unit_ntrd_0023= null']:
        s = base.once(s, line + '\n', '')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + crlf(GLOBALS) + s[i:]
    for gone in ['HealthBars__Hero,', 'HealthBars__BarCamera,', 'gg_trg_', 'ConversationUI___HealthEnemy',
                 'ConversationUI___ReferenceTauren', 'Player(10)']:
        assert gone not in s, gone
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s), SPOTS)
