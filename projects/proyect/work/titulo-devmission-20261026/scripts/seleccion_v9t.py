"""Strategy board v9t (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9s (CRLF kept).

The user kept v9s's shrink-everything for later and asked instead, 3 s after the boss is decided:
- the central sphere (card, effect, name and its ornaments, Pick) shrinks into its centre and the pieces by the
  clock (the 8 top slots, the players' cell glows, title and label) shrink in place until nothing is left
  (Boss_ShrinkCollect rewritten; the clock stays);
- then the boss cells leave as the hero ones did, in disorder, now out of the screen: the two 3 x 5 blocks fly to
  the right (random delay up to 0.5 s, accelerating, a random vertical drift), the left block across the screen;
  the bottom row closes the Pick gap into the mockup's 10 squares (368.5 + 133 k), which are the waves;
- with every cell out, the strategy board grows from nothing (0.5 s): the mockup's title, "Tiempo de estrategia",
  "Entrando a partida con:", the portrait frame with the hero select's 3D portrait (the player's chosen Tauren),
  the information panel, both spheres (card under the Ubershield effect, as the boss sphere) and the boss square
  above the row; the column between clock and row is scaled (frame and caption 0.85, panel 0.8) so the square
  fits. The Start screen's animated background stays. 0:30 then counts down; at 0:00 nothing more (yet).
- Each player browses on their own screen (GetLocalPlayer: scales, texttag texts and positions, the shield's
  birth, the pick sound): by default both spheres show the boss, "Boss: <name>" under each and "???" as the
  information; wave square k shows the rock example in both spheres, "Wave k" and "Detalles de la wave k."; the boss
  square shows the boss again. Every change plays the boss select's pick effect in both spheres (beam, flame and,
  0.6 s later, sparks), created for everybody (trackable events are synchronised) and scaled 0 on the other screens.
  The player's glow marks the square shown, CellHi the one under the mouse.
- Texts are texttags (the user's choice). Their point is computed as Title_ClockText's (the text hangs about 1.1
  font heights below it) and centred with the measured Friz Quadrata advances at .027 (ui-studio
  dialogue-font-metrics.js), scaled; off the screen centre a texttag landed off its pixel in v8e, so their places
  are to be checked in the game.
- Boss_Reset (-titulo) also resets the board and puts the boss icons and the portrait back.

Usage: seleccion_v9t.py IN_J OUT_J METRICS_JS
"""
from pathlib import Path
import json, re, sys

N = '\r\n'


def L(s):
    return s.replace('\n', N)


def once(s, old, new):
    old, new = L(old), L(new)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


def width(adv, text, size):
    return round(sum(adv.get(c, 15) for c in text) * size / 0.027, 1)


LABEL, INFO, NAME = 0.028, 0.022, 0.032

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    js = Path(sys.argv[3]).read_text(encoding='utf-8')
    adv = json.loads(re.search(r'Object.freeze\((\{.*\})\)', js).group(1))['advances']
    texts = [('Boss: Nereus', '???')] + [(f'Wave {k}', f'Detalles de la wave {k}.') for k in range(1, 11)]
    table = ''.join(f'''    set Strat_Lbl[{i}] = "{a}"
    set Strat_LblW[{i}] = {width(adv, a, LABEL)}
    set Strat_Info[{i}] = "{b}"
    set Strat_InfoW[{i}] = {width(adv, b, INFO)}
''' for i, (a, b) in enumerate(texts))
    name_w, unknown_w = width(adv, 'Jefe tauren', NAME), width(adv, '???', NAME)

    s = once(s, 'real Boss_ShrinkTime= -1\n', '''real Boss_ShrinkTime= -1
boolean Strat_Active= false
boolean Strat_Built= false
boolean Strat_Ready= false
boolean Strat_Tracked= false
real Strat_FlyTime= -1
real Strat_GrowTime= -1
real array Strat_Delay
real array Strat_DY
unit array Strat_Pic
unit array Strat_Card
unit array Strat_Shield
unit Strat_BossFrame= null
unit Strat_BossIcon= null
unit array Strat_Hi
unit array Strat_Sel
texttag array Strat_Tag
integer array Strat_View
integer array Strat_Hover
unit array Strat_Fx
real array Strat_FxT
boolean array Strat_FxSpark
unit array Strat_GU
real array Strat_GS
integer Strat_GN= 0
integer Strat_Left= 0
integer Strat_Ticks= 0
real Strat_PortS= 0
string array Strat_Lbl
real array Strat_LblW
string array Strat_Info
real array Strat_InfoW
''')

    # The shrink: the sphere into its centre, the pieces by the clock in place; cells and clock stay.
    i = s.index(L('// Every piece of the boss screen that is shown now'))
    j = s.index(L('// f = 1: as collected'), i)
    s = s[:i] + L('''// v9t: a piece that shrinks in place (its own centre as the anchor).
function Boss_ShrinkSelf takes unit u returns nothing
    if u != null then
        call Boss_ShrinkPic(u)
        set Boss_SAX[Boss_SN - 1] = GetUnitX(u)
        set Boss_SAY[Boss_SN - 1] = GetUnitY(u)
    endif
endfunction

// v9t: the sphere (card, effect, name, its ornaments, Pick) into its centre; title, label, the 8 slots and the
// players' cell glows in place. The cells fly out afterwards (Strat_Fly); the clock stays.
function Boss_ShrinkCollect takes nothing returns nothing
    local integer i = 0
    set Boss_SN = 0
    loop
        exitwhen i > 7
        if i < 3 then
            call Boss_ShrinkSelf(Boss_Bg[i])
        elseif i < 5 then
            call Boss_ShrinkPic(Boss_Bg[i])
        endif
        if Boss_Choice[i] >= 0 then
            call Boss_ShrinkSelf(Hero_Glow[i])
        endif
        if Boss_SlotIcon[i] == null then
            call Boss_ShrinkSelf(Hero_SlotQ[i])
        else
            call Boss_ShrinkSelf(Boss_SlotIcon[i])
        endif
        call Boss_ShrinkSelf(Hero_SlotFrame[i])
        call Boss_ShrinkSelf(Hero_SlotGlow[i])
        set i = i + 1
    endloop
    call Boss_ShrinkPic(Boss_Card)
    call Boss_ShrinkPic(Boss_Name)
    call Boss_ShrinkPic(Boss_PickBtn)
    if Boss_Shield != null then
        call Boss_ShrinkAdd(Boss_Shield, 5.5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5), 560)
    endif
endfunction

''') + s[j:]
    # No pan any more: the camera bounds stay.
    s = once(s, '''    set Boss_ShrinkTime = Boss_Time + 3
    call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + Boss_Pan + 1, Title_X() + 1, Title_Y() + Boss_Pan + 1, Title_X() + 1, Title_Y() - 1)
''', '''    set Boss_ShrinkTime = Boss_Time + 3
''')

    strat = '''// v9t: the strategy board (scripts/seleccion_v9t.py). Spheres at mockup (250, 410) and (1525, 410) + (80, 15).
function Strat_SX takes integer s returns real
    if s == 0 then
        return 330.0
    endif
    return 1605.0
endfunction

// Squares: 0-9 the waves (the bottom row closed, the mockup's centres), 10 the boss square above it.
function Strat_SqX takes integer i returns real
    if i < 10 then
        return 368.5 + 133.0 * i
    endif
    return 968.0
endfunction

function Strat_SqY takes integer i returns real
    if i < 10 then
        return 757.0
    endif
    return 650.0
endfunction

function Strat_FxAt takes integer id, real px, real py, real depth, real scale, real speed returns unit
    local unit u = CreateUnit(CAMERA_DUMMY_PLAYER, id, Title_WX(py, depth), Title_WY(px, depth), 270)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(u, Title_D() + Title_Eye - depth, 0)
    call SetUnitScale(u, scale, scale, scale)
    call SetUnitTimeScale(u, speed)
    return u
endfunction

// A texttag centred on (px, py) for a text w pixels wide: its point is the left end, about 1.1 font heights
// above the text (Title_ClockText). Visual only.
function Strat_TextAt takes texttag t, real px, real py, real size, real w returns nothing
    call SetTextTagPos(t, Title_WX(py - 1.1 * 1080 * size, 400), Title_WY(px - w / 2, 400), Title_D() + Title_Eye - 400)
endfunction

function Strat_Build takes nothing returns nothing
    local integer i = 0
    set Strat_Built = true
''' + table + '''    set Strat_Pic[0] = Title_Pic('uidb', 781.5, 67, 512, 128, 404, 'DT3A')
    set Strat_Pic[1] = Title_Pic('uidb', 1174, 67, 512, 128, 404, 'DT3B')
    set Strat_Pic[2] = Title_Pic('uidb', 967.5, 176, 256, 32, 404, 'DT3C')
    set Strat_Pic[3] = Title_Pic('uidb', 968, 205, 435.2, 54.4, 404, 'DT3D')
    // The frame behind the portrait (405): its inside is dark at 0.85.
    set Strat_Pic[4] = Title_Pic('uidb', 968, 310, 435.2, 217.6, 407, 'DT3E')
    set Strat_Pic[5] = Title_Pic('uidb', 831.6, 518, 409.6, 204.8, 404, 'DT3F')
    set Strat_Pic[6] = Title_Pic('uidb', 1104.4, 518, 409.6, 204.8, 404, 'DT3G')
    loop
        exitwhen i > 6
        call Title_Show(Strat_Pic[i], false)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 3
        set Strat_Card[i] = Title_Pic('uidb', Strat_SX(ModuloInteger(i, 2)), 425, 356, 356, 561, 'DT3H')
        call Title_Show(Strat_Card[i], false)
        set Strat_Tag[i] = CreateTextTag()
        call SetTextTagPermanent(Strat_Tag[i], true)
        call SetTextTagColor(Strat_Tag[i], 200, 228, 255, 255)
        call SetTextTagText(Strat_Tag[i], "", LABEL_SIZE)
        call SetTextTagVisibility(Strat_Tag[i], false)
        set i = i + 1
    endloop
    set Strat_BossFrame = Title_Pic('uidb', 968, 650, 90, 90, 401, 'DT2P')
    call Title_Show(Strat_BossFrame, false)
    set Strat_BossIcon = Title_Pic('uidb', 968, 650, 58, 58, 402, 'DT32')
    call Title_Show(Strat_BossIcon, false)
    set i = 0
    loop
        exitwhen i > 7
        set Strat_Hi[i] = Title_Pic('uidb', 968, 650, 100, 100, 400.5, 'DT33')
        call Title_Show(Strat_Hi[i], false)
        set Strat_Sel[i] = Title_Pic('uidg', 968, 650, 128, 128, 399, Hero_GlowTex[i])
        call Title_Show(Strat_Sel[i], false)
        set i = i + 1
    endloop
    // The hero select's portrait was 176 px tall at 405; the frame's inside is 133 px here.
    set Strat_PortS = Hero_PortraitScale * 125 / 176
endfunction

// The boss cells out: blocks to the right off the screen (accelerating, drift), bottom row into the wave row.
function Strat_Fly takes real time returns nothing
    local integer k = 0
    local integer b
    local real t
    local real x0
    local real y0
    local real px
    local real py
    loop
        exitwhen k > 39
        set b = Boss_Of[k]
        set x0 = Boss_CellX(b)
        set y0 = Boss_CellY(b)
        if b < 30 then
            set t = RMinBJ(RMaxBJ((time - Strat_Delay[k]) / 0.9, 0), 1)
            set t = t * t
            set px = x0 + (2150 - x0) * t
            set py = y0 + Strat_DY[k] * t
        else
            set t = RMinBJ(time / 0.6, 1)
            set t = t * t * (3 - 2 * t)
            set px = x0 + (Strat_SqX(b - 30) - x0) * t
            set py = y0
        endif
        call Hero_Put(Hero_CellQ[k], px, py)
        call Hero_Put(Hero_CellFrame[k], px, py)
        if Boss_Icon[b] != 0 then
            call Hero_Put(Boss_CellIcon[b], px, py)
        endif
        set k = k + 1
    endloop
endfunction

function Strat_Begin takes nothing returns nothing
    local integer k = 0
    if not Strat_Built then
        call Strat_Build()
    endif
    set Strat_Active = true
    set Strat_Ready = false
    set Strat_GrowTime = -1
    set Strat_FlyTime = Boss_Time + 0.15
    loop
        exitwhen k > 39
        set Strat_Delay[k] = GetRandomReal(0, 0.5)
        set Strat_DY[k] = GetRandomReal(-70, 70)
        if k < 8 then
            set Strat_FxT[k] = -1
            set Strat_Hover[k] = -1
            set Strat_View[k] = -1
        endif
        set k = k + 1
    endloop
endfunction

// Grow list: every piece of the board shown to everybody, at its own scale.
function Strat_GrowAdd takes unit u, real s returns nothing
    set Strat_GU[Strat_GN] = u
    set Strat_GS[Strat_GN] = s
    set Strat_GN = Strat_GN + 1
endfunction

// The portrait on each screen: the player's chosen hero (only the Tauren has one). Visual only.
function Strat_ShowPortrait takes real f returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    local real s = 0
    if p < 12 and Hero_Choice[p] >= 0 then
        if Hero_Icon[Hero_Choice[p]] == 'DT2R' then
            set s = Strat_PortS * f
        endif
    endif
    call SetUnitScale(Hero_Portrait, s, s, s)
endfunction

function Strat_Show takes nothing returns nothing
    local integer i = 0
    local real k = 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    set Strat_GN = 0
    loop
        exitwhen i > 39
        if Boss_Of[i] < 30 then
            call Title_Show(Hero_CellQ[i], false)
            call Title_Show(Hero_CellFrame[i], false)
            if Boss_Icon[Boss_Of[i]] != 0 then
                call Title_Show(Boss_CellIcon[Boss_Of[i]], false)
            endif
        endif
        if i < 7 then
            call Strat_GrowAdd(Strat_Pic[i], LoadReal(Title_HT, GetHandleId(Strat_Pic[i]), 1))
        endif
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 1
        call Title_Skin(Strat_Card[i], Boss_Icon[Boss_Final])
        call Strat_GrowAdd(Strat_Card[i], LoadReal(Title_HT, GetHandleId(Strat_Card[i]), 1))
        set Strat_Shield[i] = Strat_FxAt('ubs0', Strat_SX(i), 425, 560, 0, 1)
        call Strat_GrowAdd(Strat_Shield[i], 5.5 * k)
        call SetUnitAnimation(Strat_Shield[i], "birth")
        call QueueUnitAnimation(Strat_Shield[i], "stand")
        set i = i + 1
    endloop
    call Strat_GrowAdd(Strat_BossFrame, LoadReal(Title_HT, GetHandleId(Strat_BossFrame), 1))
    call Strat_GrowAdd(Strat_BossIcon, LoadReal(Title_HT, GetHandleId(Strat_BossIcon), 1))
    call SetUnitX(Hero_Portrait, Title_WX(310, 405))
    call SetUnitY(Hero_Portrait, Title_WY(968, 405))
endfunction

function Strat_Grow takes real f returns nothing
    local integer i = 0
    local real s
    loop
        exitwhen i >= Strat_GN
        set s = Strat_GS[i] * f
        call SetUnitScale(Strat_GU[i], s, s, s)
        set i = i + 1
    endloop
    call Strat_ShowPortrait(f)
endfunction

// The square p is shown (p's glow) and the one under p's mouse (CellHi); the boss square is 0.9 of a cell.
function Strat_PutSel takes integer p returns nothing
    local integer q = Strat_View[p]
    local real s
    if q < 0 then
        set q = 10
    endif
    call Hero_Put(Strat_Sel[p], Strat_SqX(q), Strat_SqY(q))
    set s = LoadReal(Title_HT, GetHandleId(Strat_Sel[p]), 1)
    if q == 10 then
        set s = 0.9 * s
    endif
    if not Strat_Active then
        set s = 0
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Strat_Sel[p], s, s, s)
    endif
endfunction

// p's view on p's screen: boss or wave cards, label under both spheres, information.
function Strat_ShowView takes integer p returns nothing
    local integer v = Strat_View[p] + 1
    local real sb = LoadReal(Title_HT, GetHandleId(Strat_Card[0]), 1)
    local real sr = 0
    if v > 0 then
        set sr = sb
        set sb = 0
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Strat_Card[0], sb, sb, sb)
        call SetUnitScale(Strat_Card[1], sb, sb, sb)
        call SetUnitScale(Strat_Card[2], sr, sr, sr)
        call SetUnitScale(Strat_Card[3], sr, sr, sr)
        call SetTextTagText(Strat_Tag[0], Strat_Lbl[v], LABEL_SIZE)
        call SetTextTagText(Strat_Tag[1], Strat_Lbl[v], LABEL_SIZE)
        call Strat_TextAt(Strat_Tag[0], Strat_SX(0), 663, LABEL_SIZE, Strat_LblW[v])
        call Strat_TextAt(Strat_Tag[1], Strat_SX(1), 663, LABEL_SIZE, Strat_LblW[v])
        call SetTextTagText(Strat_Tag[3], Strat_Info[v], INFO_SIZE)
        call Strat_TextAt(Strat_Tag[3], 968, 545, INFO_SIZE, Strat_InfoW[v])
    endif
endfunction

function Strat_FxClear takes integer p returns nothing
    local integer j = 0
    loop
        exitwhen j > 5
        call Boss_Remove(Strat_Fx[p * 6 + j])
        set Strat_Fx[p * 6 + j] = null
        set j = j + 1
    endloop
    set Strat_FxT[p] = -1
endfunction

// One of p's effect pieces: made for everybody, seen only by p.
function Strat_FxFor takes integer p, integer j, unit u returns nothing
    set Strat_Fx[p * 6 + j] = u
    if GetLocalPlayer() != Player(p) then
        call SetUnitScale(u, 0, 0, 0)
    endif
endfunction

// The boss select's pick in both spheres, on p's screen: sound, shield birth, beam and flame (sparks at 0.6 s).
function Strat_Play takes integer p returns nothing
    local real k = 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    local integer s = 0
    call Strat_FxClear(p)
    loop
        exitwhen s > 1
        call Strat_FxFor(p, 3 * s, Strat_FxAt('ubs1', Strat_SX(s), 425, 560, 5 * k, 2))
        call Strat_FxFor(p, 3 * s + 1, Strat_FxAt('ubs2', Strat_SX(s), 425, 560, 2 * k, 0.85))
        set s = s + 1
    endloop
    set Strat_FxT[p] = 0
    set Strat_FxSpark[p] = false
    if GetLocalPlayer() == Player(p) then
        call StopSound(Boss_PickSnd, false, false)
        call StartSound(Boss_PickSnd)
        call SetUnitAnimation(Strat_Shield[0], "birth")
        call QueueUnitAnimation(Strat_Shield[0], "stand")
        call SetUnitAnimation(Strat_Shield[1], "birth")
        call QueueUnitAnimation(Strat_Shield[1], "stand")
    endif
endfunction

function Strat_Tracks takes nothing returns nothing
    local integer p = 0
    local integer i
    local real depth = 398
    set Strat_Tracked = true
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set i = 0
            loop
                exitwhen i > 9
                call Title_Track(p, "war3mapImported\\\\StratHitCell.mdx", Title_WX(Strat_SqY(i), depth), Title_WY(Strat_SqX(i), depth), 300 + i)
                set i = i + 1
            endloop
            call Title_Track(p, "war3mapImported\\\\StratHitBoss.mdx", Title_WX(Strat_SqY(10), depth), Title_WY(Strat_SqX(10), depth), 310)
        endif
        set p = p + 1
    endloop
endfunction

// Board grown: squares live, everybody on the boss, texts on, 0:30.
function Strat_Go takes nothing returns nothing
    local integer p = 0
    local integer me = GetPlayerId(GetLocalPlayer())
    if not Strat_Tracked then
        call Strat_Tracks()
    endif
    loop
        exitwhen p > 7
        set Strat_View[p] = -1
        set Strat_Hover[p] = -1
        call Strat_PutSel(p)
        call Strat_ShowView(p)
        set p = p + 1
    endloop
    // The hero's name under the portrait, on each screen its own. Visual only.
    if me < 12 and Hero_Choice[me] >= 0 and Hero_Icon[Hero_Choice[me]] == 'DT2R' then
        call SetTextTagText(Strat_Tag[2], "Jefe tauren", NAME_SIZE)
        call Strat_TextAt(Strat_Tag[2], 968, 412, NAME_SIZE, NAME_W)
    else
        call SetTextTagText(Strat_Tag[2], "???", NAME_SIZE)
        call Strat_TextAt(Strat_Tag[2], 968, 412, NAME_SIZE, UNKNOWN_W)
    endif
    set p = 0
    loop
        exitwhen p > 3
        call SetTextTagVisibility(Strat_Tag[p], true)
        set p = p + 1
    endloop
    set Strat_Ready = true
    set Strat_Left = 30
    set Strat_Ticks = 0
    call Hero_ClockShow(30)
endfunction

function Strat_Tick takes nothing returns nothing
    local real t
    local integer p = 0
    local real k = 5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    if Strat_FlyTime >= 0 and Boss_Time >= Strat_FlyTime then
        call Strat_Fly(Boss_Time - Strat_FlyTime)
        if Boss_Time - Strat_FlyTime >= 1.4 then
            set Strat_FlyTime = -1
            call Strat_Show()
            set Strat_GrowTime = Boss_Time + 0.15
        endif
    endif
    if Strat_GrowTime >= 0 and Boss_Time >= Strat_GrowTime then
        set t = RMinBJ((Boss_Time - Strat_GrowTime) / 0.5, 1)
        call Strat_Grow(t * t * (3 - 2 * t))
        if t >= 1 then
            set Strat_GrowTime = -1
            call Strat_Go()
        endif
    endif
    loop
        exitwhen p > 7
        if Strat_FxT[p] >= 0 then
            set Strat_FxT[p] = Strat_FxT[p] + 0.02
            if Strat_FxT[p] >= 0.6 and not Strat_FxSpark[p] then
                set Strat_FxSpark[p] = true
                call Strat_FxFor(p, 2, Strat_FxAt('ubs3', Strat_SX(0), 425, 560, k, 1.5))
                call Strat_FxFor(p, 5, Strat_FxAt('ubs3', Strat_SX(1), 425, 560, k, 1.5))
            endif
            if Strat_FxT[p] >= 2 and Strat_Fx[p * 6] != null then
                call RemoveUnit(Strat_Fx[p * 6])
                call RemoveUnit(Strat_Fx[p * 6 + 1])
                call RemoveUnit(Strat_Fx[p * 6 + 3])
                call RemoveUnit(Strat_Fx[p * 6 + 4])
                set Strat_Fx[p * 6] = null
                set Strat_Fx[p * 6 + 1] = null
                set Strat_Fx[p * 6 + 3] = null
                set Strat_Fx[p * 6 + 4] = null
            endif
            if Strat_FxT[p] >= 2.6 then
                call Strat_FxClear(p)
            endif
        endif
        set p = p + 1
    endloop
    if Strat_Ready then
        set Strat_Ticks = Strat_Ticks + 1
        if Strat_Ticks >= 50 then
            set Strat_Ticks = 0
            set Strat_Left = Strat_Left - 1
            call Hero_ClockShow(Strat_Left)
            if Strat_Left <= 0 then
                // Time up: the squares stop (what follows is the user's next board).
                set Strat_Ready = false
                set p = 0
                loop
                    exitwhen p > 7
                    set Strat_Hover[p] = -1
                    call SetUnitScale(Strat_Hi[p], 0, 0, 0)
                    set p = p + 1
                endloop
            endif
        endif
    endif
endfunction

// -titulo: the board hidden, effects and shields gone, boss icons and the portrait back at their places.
function Strat_Reset takes nothing returns nothing
    local integer i = 0
    set Strat_Active = false
    set Strat_Ready = false
    set Strat_FlyTime = -1
    set Strat_GrowTime = -1
    if not Strat_Built then
        return
    endif
    loop
        exitwhen i > 39
        if Boss_Icon[i] != 0 then
            call Hero_Put(Boss_CellIcon[i], Boss_CellX(i), Boss_CellY(i))
        endif
        if i < 7 then
            call Title_Show(Strat_Pic[i], false)
        endif
        if i < 4 then
            call SetUnitScale(Strat_Card[i], 0, 0, 0)
            call SetTextTagVisibility(Strat_Tag[i], false)
        endif
        if i < 2 then
            call Boss_Remove(Strat_Shield[i])
            set Strat_Shield[i] = null
        endif
        if i < 8 then
            call Strat_FxClear(i)
            set Strat_Hover[i] = -1
            set Strat_View[i] = -1
            call SetUnitScale(Strat_Hi[i], 0, 0, 0)
            call SetUnitScale(Strat_Sel[i], 0, 0, 0)
        endif
        set i = i + 1
    endloop
    call Title_Show(Strat_BossFrame, false)
    call Title_Show(Strat_BossIcon, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
    call SetUnitX(Hero_Portrait, Title_WX(394, 405))
    call SetUnitY(Hero_Portrait, Title_WY(1487, 405))
endfunction

// Hover: CellHi on the square under p's mouse, on p's screen only (its place is moved for everybody).
function Strat_OnTrack takes integer p, integer kind returns nothing
    local integer q = kind - 300
    local real s = 0
    if p > 7 then
        return
    endif
    if not Strat_Ready or q < 0 or q > 10 then
        set q = -1
    endif
    if q == Strat_Hover[p] then
        return
    endif
    set Strat_Hover[p] = q
    if q >= 0 then
        call Hero_Put(Strat_Hi[p], Strat_SqX(q), Strat_SqY(q))
        set s = LoadReal(Title_HT, GetHandleId(Strat_Hi[p]), 1)
        if q == 10 then
            set s = 0.9 * s
        endif
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Strat_Hi[p], s, s, s)
    endif
endfunction

// A square: p's view changes on p's screen (wave k or the boss), with the pick effect.
function Strat_OnHit takes integer p, integer kind returns nothing
    local integer v = kind - 300
    if not Strat_Ready or p > 7 or v < 0 or v > 10 then
        return
    endif
    if v == 10 then
        set v = -1
    endif
    if v == Strat_View[p] then
        return
    endif
    set Strat_View[p] = v
    call Strat_PutSel(p)
    call Strat_ShowView(p)
    call Strat_Play(p)
endfunction

function Boss_Tick takes nothing returns nothing'''
    strat = (strat.replace('LABEL_SIZE', str(LABEL)).replace('INFO_SIZE', str(INFO)).replace('NAME_SIZE', str(NAME))
             .replace('NAME_W', str(name_w)).replace('UNKNOWN_W', str(unknown_w)))
    s = once(s, 'function Boss_Tick takes nothing returns nothing', strat)

    # Tick: after the shrink the board instead of the pan.
    s = once(s, '''        if t >= 1 then
            set Boss_ShrinkTime = -1
            set Boss_PanTime = Boss_Time + 0.3
        endif
    endif
''', '''        if t >= 1 then
            set Boss_ShrinkTime = -1
            call Strat_Begin()
        endif
    endif
    if Strat_Active then
        call Strat_Tick()
    endif
''')
    s = once(s, '''    set Boss_ShrinkTime = -1
    call Boss_ShrinkRestore()
''', '''    set Boss_ShrinkTime = -1
    call Boss_ShrinkRestore()
    call Strat_Reset()
''')
    s = once(s, '''function Boss_OnTrack takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local real s = 0
    local boolean on = kind == 240 and Boss_Ready
''', '''function Boss_OnTrack takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local real s = 0
    local boolean on = kind == 240 and Boss_Ready
    if Strat_Active then
        call Strat_OnTrack(p, kind)
        return
    endif
''')
    s = once(s, '''function Boss_OnHit takes integer p, integer kind returns nothing
    local integer b = kind - 200
''', '''function Boss_OnHit takes integer p, integer kind returns nothing
    local integer b = kind - 200
    if Strat_Active then
        call Strat_OnHit(p, kind)
        return
    endif
''')
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s), 'name_w', name_w)
