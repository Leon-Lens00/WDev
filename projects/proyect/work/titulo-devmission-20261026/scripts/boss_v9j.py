"""Boss select v9j (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9i (CRLF kept).

When the hero select's time is up the screen becomes the boss select of the user's mockup:
- the hero background goes, so the Start screen's animated one shows (as the user asked), with the mockup's
  title, "Tiempo de seleccion" and the name's ornaments as pictures (texturas_boss.py); hero pieces (glows, Lock in, portrait, the slots'
  hero buttons, the cells' hero buttons) go; every cell is the "?" square under its frame again;
- the 40 cells fly (0.9 s each, smoothstep, a random start within 0.4 s) to the boss layout, growing from 96 to
  100 px: the hero grid's right 3 x 5 to the left block, its left 3 x 5 to the right block, the middle 2 x 5 to
  the bottom row, each group in a random order (GetRandomInt, run for everybody). Columns and the bottom row are
  133 px apart (the mockup had 159 and 133; the user asked for one spacing), rows 105;
- the centre is Dev Us Dimensional v0.76a's boss display (Trig_IntoSelecInLoop_Actions), reworked: one
  periodic timer instead of a 0.05 s trigger and a pile of udg_ units. Each pick: SecodIntoEfect.mp3 from the
  start, the Ubershield Azure sphere ('ubs0', kept) replays "birth", Soul Beam Blue ('ubs1', x2 speed) and
  Flamestrike Mystic II ('ubs2', x0.85) for 2 s, Electric Spark ('ubs3', x1.5) from 0.6 s for 2 s. Dev Us's
  scales (5.5, 5, 2, 5; card 2 x 350) are kept in proportion: the sphere is 440 px wide at depth 560, the boss
  card (BossNereus) 356 px at 561, behind the sphere's centre so the hexagons go over it. The name picture
  (BossName) goes under it. The first display plays as the cells land;
- the cells are trackables 200-239 (BossHitCell.mdx, z 40, above the hero ones at z 26 where they overlap).
  Hovering a cell plays Dev Us's cursor sound and puts its neon frame ('ubs4') on it, for that player only;
  clicking a cell with a boss picks it: the player's cell glow goes there, the player's slot shows its button
  and the centre plays the pick. For now only cell 0 has a boss (Nereus, Dev Us's hydra, BTNHydra);
- 0:30 on the clock; everybody registered picked -> at most 3 s; at 0 the picks stay.
Hero_Reset also ends the boss select and puts the cells back.

Usage: boss_v9j.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def L(s):
    return s.replace('\n', N)


def once(s, old, new):
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


GLOBALS = L('''boolean Boss_Active= false
boolean Boss_Ready= false
boolean Boss_Built= false
boolean Boss_Tracked= false
boolean Boss_Landed= false
boolean Boss_SparkDone= false
unit array Boss_Bg
integer array Boss_Icon
unit array Boss_CellIcon
integer array Boss_Of
integer array Boss_Cell
real array Boss_Delay
real array Boss_BaseScale
integer array Boss_Choice
integer array Boss_Hover
unit array Boss_SlotIcon
unit array Boss_Neon
unit Boss_Card= null
unit Boss_Name= null
unit Boss_Shield= null
unit Boss_Beam= null
unit Boss_Flame= null
unit Boss_Spark= null
real Boss_Time= 0
real Boss_FxTime= -1
integer Boss_Left= 0
integer Boss_Ticks= 0
timer Boss_Timer= null
sound Boss_PickSnd= null
sound Boss_CursorSnd= null
''')

BOSS = L('''// v9j: the boss select (scripts/boss_v9j.py). Boss cell b: 0-14 the left block (3 x 5), 15-29 the right one,
// 30-39 the bottom row; columns and the bottom row 133 px apart, rows 105.
function Boss_CellX takes integer b returns real
    if b < 15 then
        return 153.0 + 133.0 * ModuloInteger(b, 3)
    elseif b < 30 then
        return 1514.0 + 133.0 * ModuloInteger(b - 15, 3)
    endif
    return 368.5 + 133.0 * (b - 30)
endfunction

function Boss_CellY takes integer b returns real
    if b < 30 then
        return 278.0 + 105.0 * (ModuloInteger(b, 15) / 3)
    endif
    return 810.0
endfunction

// A Dev Us effect at the centre, depth below the eye, Dev Us's time scale; unselectable like the pictures.
function Boss_Fx takes integer id, real depth, real scale, real speed returns unit
    local unit u = CreateUnit(CAMERA_DUMMY_PLAYER, id, Title_WX(417, depth), Title_WY(968, depth), 270)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(u, Title_D() + Title_Eye - depth, 0)
    call SetUnitScale(u, scale, scale, scale)
    call SetUnitTimeScale(u, speed)
    return u
endfunction

function Boss_Remove takes unit u returns nothing
    if u != null then
        call RemoveUnit(u)
    endif
endfunction

function Boss_Build takes nothing returns nothing
    local integer i = 0
    set Boss_Built = true
    // The Start screen's animated background stays under the boss select (the user's choice): only the mockup's
    // lettering is drawn, as pictures at 1:1 (texturas_boss.py PIECES, mockup centre + 80, 15).
    set Boss_Bg[0] = Title_Pic('uidb', 781.5, 67, 512, 128, 404, 'DT2S')
    set Boss_Bg[1] = Title_Pic('uidb', 1174, 67, 512, 128, 404, 'DT2T')
    set Boss_Bg[2] = Title_Pic('uidb', 967, 176, 256, 32, 404, 'DT2U')
    set Boss_Bg[3] = Title_Pic('uidb', 662, 685, 256, 64, 404, 'DT2V')
    set Boss_Bg[4] = Title_Pic('uidb', 1278, 685, 256, 64, 404, 'DT2W')
    loop
        exitwhen i > 4
        call Title_Show(Boss_Bg[i], false)
        set i = i + 1
    endloop
    // The bosses so far: Nereus, Dev Us's hydra.
    set i = 0
    loop
        exitwhen i > 39
        set Boss_Icon[i] = 0
        set i = i + 1
    endloop
    set Boss_Icon[0] = 'DT31'
    set i = 0
    loop
        exitwhen i > 39
        if Boss_Icon[i] != 0 then
            set Boss_CellIcon[i] = Title_Pic('uidb', Boss_CellX(i), Boss_CellY(i), 64, 64, 402, 'DT32')
            call Title_Show(Boss_CellIcon[i], false)
        endif
        set i = i + 1
    endloop
    set Boss_Card = Title_Pic('uidb', 968, 417, 356, 356, 561, 'DT31')
    call Title_Show(Boss_Card, false)
    set Boss_Name = Title_Pic('uidb', 970, 678, 256, 128, 403, 'DT30')
    call Title_Show(Boss_Name, false)
    set i = 0
    loop
        exitwhen i > 11
        // neon_sprite100 is 141 wide: 112 px at depth 400.
        set Boss_Neon[i] = CreateUnit(CAMERA_DUMMY_PLAYER, 'ubs4', Title_WX(417, 400), Title_WY(968, 400), 270)
        call UnitAddAbility(Boss_Neon[i], s__Interface_DESTROYER_FORM_ID)
        call UnitRemoveAbility(Boss_Neon[i], s__Interface_DESTROYER_FORM_ID)
        call UnitAddAbility(Boss_Neon[i], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(Boss_Neon[i], s__Interface_LOCUST_ID)
        call SetUnitFlyHeight(Boss_Neon[i], Title_D() + Title_Eye - 400, 0)
        call SetUnitScale(Boss_Neon[i], 0, 0, 0)
        call SaveReal(Title_HT, GetHandleId(Boss_Neon[i]), 1, 112 * (0.544 / 718.18930543) * 400 / 141)
        call SaveReal(Title_HT, GetHandleId(Boss_Neon[i]), 2, 400)
        set i = i + 1
    endloop
    set Boss_PickSnd = CreateSound("war3mapImported\\\\SecodIntoEfect.mp3", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Boss_PickSnd, 2808)
    call SetSoundChannel(Boss_PickSnd, 0)
    call SetSoundVolume(Boss_PickSnd, 95)
    set Boss_CursorSnd = CreateSound("war3mapImported\\\\XC_LU_CURSOR_MOVES.mp3", false, false, false, 10, 10, "")
    call SetSoundDuration(Boss_CursorSnd, 408)
    call SetSoundChannel(Boss_CursorSnd, 0)
    call SetSoundVolume(Boss_CursorSnd, 127)
endfunction

function Boss_Tracks takes nothing returns nothing
    local integer p = 0
    local integer b
    local real depth = Title_D() + Title_Eye - 40
    set Boss_Tracked = true
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set b = 0
            loop
                exitwhen b > 39
                call Title_Track(p, "war3mapImported\\\\BossHitCell.mdx", Title_WX(Boss_CellY(b), depth), Title_WY(Boss_CellX(b), depth), 200 + b)
                set b = b + 1
            endloop
        endif
        set p = p + 1
    endloop
endfunction

// The centre shows boss cell b: Dev Us's pick (sound, sphere birth, beam and flamestrike now, sparks at 0.6 s).
function Boss_Display takes integer b returns nothing
    local real k = 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    call StopSound(Boss_PickSnd, false, false)
    call StartSound(Boss_PickSnd)
    call Title_Show(Boss_Card, true)
    call Title_Show(Boss_Name, true)
    if Boss_Shield == null then
        set Boss_Shield = Boss_Fx('ubs0', 560, 5.5 * k, 1)
    endif
    call SetUnitAnimation(Boss_Shield, "birth")
    call QueueUnitAnimation(Boss_Shield, "stand")
    call Boss_Remove(Boss_Beam)
    call Boss_Remove(Boss_Flame)
    call Boss_Remove(Boss_Spark)
    set Boss_Spark = null
    set Boss_Beam = Boss_Fx('ubs1', 560, 5 * k, 2)
    set Boss_Flame = Boss_Fx('ubs2', 560, 2 * k, 0.85)
    set Boss_SparkDone = false
    set Boss_FxTime = 0
endfunction

function Boss_Fly takes nothing returns nothing
    local integer k = 0
    local real t
    local real s
    local integer b
    loop
        exitwhen k > 39
        set t = RMinBJ(RMaxBJ((Boss_Time - Boss_Delay[k]) / 0.9, 0), 1)
        set t = t * t * (3 - 2 * t)
        set b = Boss_Of[k]
        call Hero_Put(Hero_CellQ[k], Hero_CellX(k) + (Boss_CellX(b) - Hero_CellX(k)) * t, Hero_CellY(k) + (Boss_CellY(b) - Hero_CellY(k)) * t)
        call Hero_Put(Hero_CellFrame[k], Hero_CellX(k) + (Boss_CellX(b) - Hero_CellX(k)) * t, Hero_CellY(k) + (Boss_CellY(b) - Hero_CellY(k)) * t)
        set s = Boss_BaseScale[k] * (1 + (100.0 / 96 - 1) * t)
        call SaveReal(Title_HT, GetHandleId(Hero_CellQ[k]), 1, s)
        call SaveReal(Title_HT, GetHandleId(Hero_CellFrame[k]), 1, s)
        call Title_Show(Hero_CellQ[k], Boss_Icon[b] == 0 or t < 1)
        call Title_Show(Hero_CellFrame[k], true)
        set k = k + 1
    endloop
endfunction

function Boss_Land takes nothing returns nothing
    local integer b = 0
    set Boss_Landed = true
    loop
        exitwhen b > 39
        if Boss_Icon[b] != 0 then
            call Title_Show(Boss_CellIcon[b], true)
        endif
        set b = b + 1
    endloop
    if not Boss_Tracked then
        call Boss_Tracks()
    endif
    set Boss_Left = 30
    set Boss_Ticks = 0
    set Boss_Ready = true
    call Hero_ClockShow(30)
    call Boss_Display(0)
endfunction

function Boss_Tick takes nothing returns nothing
    local integer i = 0
    set Boss_Time = Boss_Time + 0.02
    if not Boss_Landed then
        call Boss_Fly()
        if Boss_Time >= 1.3 then
            call Boss_Land()
        endif
    endif
    if Boss_FxTime >= 0 then
        set Boss_FxTime = Boss_FxTime + 0.02
        if Boss_FxTime >= 0.6 and not Boss_SparkDone then
            set Boss_SparkDone = true
            set Boss_Spark = Boss_Fx('ubs3', 560, 5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5), 1.5)
        endif
        if Boss_FxTime >= 2 and Boss_Beam != null then
            call RemoveUnit(Boss_Beam)
            call RemoveUnit(Boss_Flame)
            set Boss_Beam = null
            set Boss_Flame = null
        endif
        if Boss_FxTime >= 2.6 then
            call Boss_Remove(Boss_Spark)
            set Boss_Spark = null
            set Boss_FxTime = -1
        endif
    endif
    if Boss_Ready then
        set Boss_Ticks = Boss_Ticks + 1
        if Boss_Ticks >= 50 then
            set Boss_Ticks = 0
            set Boss_Left = Boss_Left - 1
            call Hero_ClockShow(Boss_Left)
            if Boss_Left <= 0 then
                set Boss_Ready = false
                loop
                    exitwhen i > 11
                    call SetUnitScale(Boss_Neon[i], 0, 0, 0)
                    set i = i + 1
                endloop
            endif
        endif
    endif
endfunction

// Fisher-Yates over the boss cells first .. first + n - 1, given to the hero cells of columns c0 .. c0 + w - 1.
function Boss_Deal takes integer c0, integer w, integer first returns nothing
    local integer array to
    local integer n = 5 * w
    local integer i = 0
    local integer j
    local integer x
    local integer k
    loop
        exitwhen i >= n
        set to[i] = first + i
        set i = i + 1
    endloop
    set i = n - 1
    loop
        exitwhen i < 1
        set j = GetRandomInt(0, i)
        set x = to[i]
        set to[i] = to[j]
        set to[j] = x
        set i = i - 1
    endloop
    set i = 0
    loop
        exitwhen i >= n
        set k = 8 * (i / w) + c0 + ModuloInteger(i, w)
        set Boss_Of[k] = to[i]
        set Boss_Cell[to[i]] = k
        set Boss_Delay[k] = GetRandomReal(0, 0.4)
        set i = i + 1
    endloop
endfunction

function Boss_Start takes nothing returns nothing
    local integer i = 0
    call DestroyTimer(GetExpiredTimer())
    if Title_Exited or not Hero_Active or Boss_Active then
        return
    endif
    if not Boss_Built then
        call Boss_Build()
    endif
    set Boss_Active = true
    set Boss_Landed = false
    set Boss_Time = 0
    call Hero_ClockShow(30)
    loop
        exitwhen i > 39
        if i < 8 then
            call Title_Show(Hero_Bg[i], false)
            call Title_Show(Boss_Bg[i], i < 5)
            call Title_Show(Hero_Glow[i], false)
            call Title_Show(Hero_SlotQ[i], true)
            if Hero_SlotIcon[i] != null then
                call RemoveUnit(Hero_SlotIcon[i])
                set Hero_SlotIcon[i] = null
            endif
        endif
        if i < 12 then
            set Boss_Choice[i] = -1
            set Boss_Hover[i] = -1
            set Hero_LockHover[i] = false
        endif
        if Hero_Icon[i] != 0 then
            call Title_Show(Hero_CellIcon[i], false)
        endif
        set Boss_BaseScale[i] = LoadReal(Title_HT, GetHandleId(Hero_CellQ[i]), 1)
        set i = i + 1
    endloop
    call Title_Show(Hero_LockGlow, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
    // The hero grid's right 3 x 5 to the left block, its left 3 x 5 to the right block, the middle to the bottom.
    call Boss_Deal(5, 3, 0)
    call Boss_Deal(0, 3, 15)
    call Boss_Deal(3, 2, 30)
    call Boss_Fly()
    set Boss_Timer = CreateTimer()
    call TimerStart(Boss_Timer, 0.02, true, function Boss_Tick)
endfunction

// Hero_Reset: no boss select; the cells back to the hero grid at their own size.
function Boss_Reset takes nothing returns nothing
    local integer i = 0
    if not Boss_Active then
        return
    endif
    set Boss_Active = false
    set Boss_Ready = false
    call DestroyTimer(Boss_Timer)
    set Boss_Timer = null
    loop
        exitwhen i > 39
        call SaveReal(Title_HT, GetHandleId(Hero_CellQ[i]), 1, Boss_BaseScale[i])
        call SaveReal(Title_HT, GetHandleId(Hero_CellFrame[i]), 1, Boss_BaseScale[i])
        call Hero_Put(Hero_CellQ[i], Hero_CellX(i), Hero_CellY(i))
        call Hero_Put(Hero_CellFrame[i], Hero_CellX(i), Hero_CellY(i))
        if Boss_Icon[i] != 0 then
            call Title_Show(Boss_CellIcon[i], false)
        endif
        if i < 8 then
            call Title_Show(Boss_Bg[i], false)
            if Boss_SlotIcon[i] != null then
                call RemoveUnit(Boss_SlotIcon[i])
                set Boss_SlotIcon[i] = null
            endif
        endif
        if i < 12 then
            call SetUnitScale(Boss_Neon[i], 0, 0, 0)
        endif
        set i = i + 1
    endloop
    call Title_Show(Boss_Card, false)
    call Title_Show(Boss_Name, false)
    call Boss_Remove(Boss_Shield)
    call Boss_Remove(Boss_Beam)
    call Boss_Remove(Boss_Flame)
    call Boss_Remove(Boss_Spark)
    set Boss_Shield = null
    set Boss_Beam = null
    set Boss_Flame = null
    set Boss_Spark = null
    set Boss_FxTime = -1
endfunction

// Hover: the cursor's neon frame and sound, on p's screen only (the frame's place is moved for everybody).
function Boss_OnTrack takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local real s = 0
    if not Boss_Ready or b < 0 or b > 39 then
        set b = -1
    endif
    if b == Boss_Hover[p] then
        return
    endif
    set Boss_Hover[p] = b
    if b >= 0 then
        call Hero_Put(Boss_Neon[p], Boss_CellX(b), Boss_CellY(b))
        set s = LoadReal(Title_HT, GetHandleId(Boss_Neon[p]), 1)
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Boss_Neon[p], s, s, s)
        if b >= 0 then
            call StopSound(Boss_CursorSnd, false, false)
            call StartSound(Boss_CursorSnd)
        endif
    endif
endfunction

function Boss_OnHit takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local integer i = 0
    local integer n = 0
    if not Boss_Ready or p > 7 or not Title_Registered[p] or b < 0 or b > 39 or Boss_Icon[b] == 0 or Boss_Choice[p] == b then
        return
    endif
    set Boss_Choice[p] = b
    call Hero_Put(Hero_Glow[p], Boss_CellX(b), Boss_CellY(b))
    call Title_Show(Hero_Glow[p], true)
    call Title_Show(Hero_SlotQ[p], false)
    if Boss_SlotIcon[p] != null then
        call RemoveUnit(Boss_SlotIcon[p])
    endif
    set Boss_SlotIcon[p] = Title_Pic('uidb', Hero_SlotX(p), 138.5, 53, 53, 402, 'DT32')
    call Boss_Display(b)
    loop
        exitwhen i > 7
        if Title_Registered[i] and Boss_Choice[i] < 0 then
            set n = n + 1
        endif
        set i = i + 1
    endloop
    if n == 0 and Boss_Left > 3 then
        set Boss_Left = 3
        set Boss_Ticks = 0
        call Hero_ClockShow(3)
    endif
endfunction

''')

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, 'unit array Hero_Glow' + N, 'unit array Hero_Glow' + N + GLOBALS)
    i = s.index('// Hidden pieces, no unit, not active')
    s = s[:i] + BOSS + s[i:]
    s = once(s, L('''    call Hero_Pieces(false)
    call Hero_ClockShow(-1)
'''), L('''    call Boss_Reset()
    call Hero_Pieces(false)
    call Hero_ClockShow(-1)
'''))
    s = once(s, L('''            call Title_Show(Hero_LockGlow, false)
        endif
'''), L('''            call Title_Show(Hero_LockGlow, false)
            call TimerStart(CreateTimer(), 0.6, false, function Boss_Start)
        endif
'''))
    for fn, var in (('Title_OnTrack', 'Hero_OnTrack'), ('Title_OnHit', 'Hero_OnHit')):
        boss = 'Boss_OnTrack' if fn == 'Title_OnTrack' else 'Boss_OnHit'
        old = L(f'''    if Hero_Active then
        call {var}(p, LoadInteger(Title_HT, id, 1))
''')
        s = once(s, old, L(f'''    if Boss_Active then
        call {boss}(p, LoadInteger(Title_HT, id, 1))
        return
    endif
''') + old)
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
