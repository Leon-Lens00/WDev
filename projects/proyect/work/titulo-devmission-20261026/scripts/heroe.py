"""Hero select screen after the mode screen (Dev Mission title v9f-v9g, 29/10/2026).

The user asked: when the mode choice ends, the armillary effect (model 2, 'uida') plays again but big, so its
light covers the whole screen at the peak, and under it the hero select screen of their mockup is left ready;
a click on a cell lights it in the player's colour, like the slots at the top; 60 s to choose; the hero name
blank for now. Icons come later.

- Hero_Begin (end of Mode_Finish): 'uida' at 3.6 times panel 1's size, centred on (960, 435), Birth.
- Hero_Show at its peak (5.6 s): the mode pieces and the clock go, the cleaned mockup (8 tiles of 512,
  texturas_heroe.py) and the clock at 1:00 come. The tiles are drawn 514 px wide (1 px over each neighbour: in
  v9f the joins showed thin lines) and at depth 700: at 405 a tile nearer the screen centre than a glow at 399
  was nearer the eye, so it was drawn after and cut the glow in half (v9f in game, cell straddling x 512).
- Hero_Go when it ends (8 s): unit removed, cells clickable (trackables at z 26, over the background 8, modes
  14 and Start 20), count from 60.
- A click on cell k by a registered player 1-8 moves that player's glow (additive 'uidg', HeroGlow1-8) there.
- The clock is M:SS with digit pictures (the countdown's ModeDigit and HeroColon), one per digit and place,
  shown and hidden, never re-skinned (v8c).
Cells and clock in 1920 x 1080 pixels: the mockup's positions plus (80, 15).

Usage: heroe.py IN_J OUT_J
"""
from pathlib import Path
import sys

GLOBALS_AFTER = 'integer Title_Gen= 0\r\n'
GLOBALS = '''boolean Hero_Active= false
boolean Hero_Ready= false
boolean Hero_Built= false
boolean Hero_Tracked= false
unit Hero_Arm= null
real Hero_ArmDepth= 390.
real Hero_ArmScale= 0.2714
integer Hero_Left= 0
integer Hero_Ticks= 0
unit array Hero_Bg
unit array Hero_Glow
integer array Hero_GlowTex
integer array Hero_Choice
unit array Hero_ClockMin
unit array Hero_ClockTen
unit array Hero_ClockUnit
unit Hero_Colon= null
'''

BEFORE = '// v8e: the 20 s are over. Choosing stops (no hover, no clicks); the screen stays with the rhombuses lit.\r\n'
CODE = r'''// v9f: hero select screen, see scripts/heroe.py. Cells centred on (297 + 113.89 c, 289 + 113.25 r), c 0-7,
// r 0-4; the clock's minute, colon, tens and units at x 924, 949.5, 974.5 and 1006.5, y 130.5 (mockup + (80, 15)).
function Hero_CellX takes integer k returns real
    return 297 + 113.89 * ModuloInteger(k, 8)
endfunction

function Hero_CellY takes integer k returns real
    return 289 + 113.25 * (k / 8)
endfunction

function Hero_Put takes unit u, real px, real py returns nothing
    local real d = LoadReal(Title_HT, GetHandleId(u), 2)
    call SetUnitX(u, Title_WX(py, d))
    call SetUnitY(u, Title_WY(px, d))
endfunction

function Hero_Build takes nothing returns nothing
    local integer i = 0
    local integer array bg
    set Hero_Built = true
    if not Clock_Built then
        call Clock_Build()
    endif
    set bg[0] = 'DT27'
    set bg[1] = 'DT28'
    set bg[2] = 'DT29'
    set bg[3] = 'DT2A'
    set bg[4] = 'DT2B'
    set bg[5] = 'DT2C'
    set bg[6] = 'DT2D'
    set bg[7] = 'DT2E'
    set Hero_GlowTex[0] = 'DT2F'
    set Hero_GlowTex[1] = 'DT2G'
    set Hero_GlowTex[2] = 'DT2H'
    set Hero_GlowTex[3] = 'DT2I'
    set Hero_GlowTex[4] = 'DT2J'
    set Hero_GlowTex[5] = 'DT2K'
    set Hero_GlowTex[6] = 'DT2L'
    set Hero_GlowTex[7] = 'DT2M'
    loop
        exitwhen i > 7
        set Hero_Bg[i] = Title_Pic('uidb', 256 + 512 * ModuloInteger(i, 4), 256 + 512 * (i / 4), 514, 514, 700, bg[i])
        call Title_Show(Hero_Bg[i], false)
        set Hero_Glow[i] = Title_Pic('uidg', Hero_CellX(0), Hero_CellY(0), 128, 128, 399, Hero_GlowTex[i])
        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 9
        if i < 2 then
            set Hero_ClockMin[i] = Title_Pic('uidb', 924, 130.5, 50.6, 73.6, 399, Clock_Tex[i])
            call Title_Show(Hero_ClockMin[i], false)
        endif
        if i < 6 then
            set Hero_ClockTen[i] = Title_Pic('uidb', 974.5, 130.5, 50.6, 73.6, 399, Clock_Tex[i])
            call Title_Show(Hero_ClockTen[i], false)
        endif
        set Hero_ClockUnit[i] = Title_Pic('uidb', 1006.5, 130.5, 50.6, 73.6, 399, Clock_Tex[i])
        call Title_Show(Hero_ClockUnit[i], false)
        set i = i + 1
    endloop
    set Hero_Colon = Title_Pic('uidb', 949.5, 130.5, 50.6, 73.6, 399, 'DT2N')
    call Title_Show(Hero_Colon, false)
endfunction

// n seconds as M:SS; n < 0 hides the clock.
function Hero_ClockShow takes integer n returns nothing
    local integer i = 0
    loop
        exitwhen i > 9
        if i < 2 then
            call Title_Show(Hero_ClockMin[i], false)
        endif
        if i < 6 then
            call Title_Show(Hero_ClockTen[i], false)
        endif
        call Title_Show(Hero_ClockUnit[i], false)
        set i = i + 1
    endloop
    call Title_Show(Hero_Colon, n >= 0)
    if n < 0 then
        return
    endif
    call Title_Show(Hero_ClockMin[n / 60], true)
    set n = n - n / 60 * 60
    call Title_Show(Hero_ClockTen[n / 10], true)
    call Title_Show(Hero_ClockUnit[n - n / 10 * 10], true)
endfunction

// One trackable per cell for every user player, made once (trackables cannot be destroyed in 1.27).
function Hero_Tracks takes nothing returns nothing
    local integer p = 0
    local integer k
    local real depth = Title_D() + Title_Eye - 26
    set Hero_Tracked = true
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set k = 0
            loop
                exitwhen k > 39
                call Title_Track(p, "war3mapImported\\HeroHitCell.mdx", Title_WX(Hero_CellY(k), depth), Title_WY(Hero_CellX(k), depth), 100 + k)
                set k = k + 1
            endloop
        endif
        set p = p + 1
    endloop
endfunction

// Hidden pieces, no unit, not active: -titulo and -salirtitulo.
function Hero_Reset takes nothing returns nothing
    local integer i = 0
    set Hero_Active = false
    set Hero_Ready = false
    if Hero_Arm != null then
        call RemoveUnit(Hero_Arm)
        set Hero_Arm = null
    endif
    if not Hero_Built then
        return
    endif
    loop
        exitwhen i > 7
        call Title_Show(Hero_Bg[i], false)
        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    call Hero_ClockShow(-1)
endfunction

function Hero_Go takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    if Hero_Arm != null then
        call RemoveUnit(Hero_Arm)
        set Hero_Arm = null
    endif
    if Title_Exited or not Hero_Active then
        return
    endif
    set Hero_Left = 60
    set Hero_Ticks = 0
    set Hero_Ready = true
    if not Hero_Tracked then
        call Hero_Tracks()
    endif
endfunction

// At the light's peak: the mode screen goes and the hero screen is left under the light.
function Hero_Show takes nothing returns nothing
    local integer i = 0
    if Title_Exited or not Hero_Active then
        call DestroyTimer(GetExpiredTimer())
        return
    endif
    if not Hero_Built then
        call Hero_Build()
    endif
    loop
        exitwhen i >= Mode_N
        call Title_Show(Mode_U[i], false)
        set i = i + 1
    endloop
    call Clock_Show(-1, 0, 0)
    set i = 0
    loop
        exitwhen i > 11
        set Hero_Choice[i] = -1
        if i < 8 then
            call Title_Show(Hero_Bg[i], true)
            call Title_Show(Hero_Glow[i], false)
        endif
        set i = i + 1
    endloop
    call Hero_ClockShow(60)
    call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)
endfunction

function Hero_Begin takes nothing returns nothing
    local real d = Hero_ArmDepth
    if Title_Exited or Hero_Active then
        return
    endif
    set Hero_Active = true
    set Hero_Ready = false
    set Hero_Arm = CreateUnit(CAMERA_DUMMY_PLAYER, 'uida', Title_WX(435, d), Title_WY(960, d), 90)
    call UnitAddAbility(Hero_Arm, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Hero_Arm, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(Hero_Arm, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Hero_Arm, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(Hero_Arm, Title_D() + Title_Eye - d + 620 * Hero_ArmScale, 0)
    call SetUnitScale(Hero_Arm, Hero_ArmScale, Hero_ArmScale, Hero_ArmScale)
    call SetUnitAnimationByIndex(Hero_Arm, 0)
    call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)
endfunction

function Hero_OnHit takes integer p, integer kind returns nothing
    local integer k = kind - 100
    if not Hero_Ready or k < 0 or k > 39 or p > 7 then
        return
    endif
    if not Title_Registered[p] or Hero_Choice[p] == k then
        return
    endif
    set Hero_Choice[p] = k
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
endfunction

// Called by Title_Tick every 0.05 s: one second every 20 ticks; at 0 the choices stay as they are.
function Hero_ClockTick takes nothing returns nothing
    if not Hero_Ready then
        return
    endif
    set Hero_Ticks = Hero_Ticks + 1
    if Hero_Ticks >= 20 then
        set Hero_Ticks = 0
        set Hero_Left = Hero_Left - 1
        call Hero_ClockShow(Hero_Left)
        if Hero_Left <= 0 then
            set Hero_Ready = false
        endif
    endif
endfunction

'''

REPLACE = [
    # Mode_Finish ends by starting the hero screen.
    ('''        if Mode_Choice[p] == 2 then\r
            set n = n + 1\r
        endif\r
        set p = p + 1\r
    endloop\r
endfunction\r
''', '''        if Mode_Choice[p] == 2 then\r
            set n = n + 1\r
        endif\r
        set p = p + 1\r
    endloop\r
    call Hero_Begin()\r
endfunction\r
'''),
    ('''    call Title_Camera()\r
    call Mode_ClockTick()\r
''', '''    call Title_Camera()\r
    call Mode_ClockTick()\r
    call Hero_ClockTick()\r
'''),
    ('''    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]\r
    if Mode_Active then\r
''', '''    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]\r
    if Hero_Active then\r
        return\r
    endif\r
    if Mode_Active then\r
'''),
    ('''    local integer p = LoadInteger(Title_HT, id, 0)\r
    if Mode_Active then\r
        call Mode_OnHit(p, LoadInteger(Title_HT, id, 1))\r
''', '''    local integer p = LoadInteger(Title_HT, id, 0)\r
    if Hero_Active then\r
        call Hero_OnHit(p, LoadInteger(Title_HT, id, 1))\r
        return\r
    endif\r
    if Mode_Active then\r
        call Mode_OnHit(p, LoadInteger(Title_HT, id, 1))\r
'''),
    ('''    call Entry_Stop()\r
    call Mode_Reset()\r
''', '''    call Entry_Stop()\r
    call Hero_Reset()\r
    call Mode_Reset()\r
'''),
    ('''    call PauseTimer(Title_Timer)\r
    call Mode_Reset()\r
''', '''    call PauseTimer(Title_Timer)\r
    call Hero_Reset()\r
    call Mode_Reset()\r
'''),
]

if __name__ == '__main__':
    j = open(sys.argv[1], encoding='latin-1', newline='').read()
    crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
    assert j.count(GLOBALS_AFTER) == 1
    j = j.replace(GLOBALS_AFTER, GLOBALS_AFTER + crlf(GLOBALS))
    assert j.count(BEFORE) == 1
    j = j.replace(BEFORE, crlf(CODE) + BEFORE)
    for old, new in REPLACE:
        assert j.count(old) == 1, old[:80]
        j = j.replace(old, new)
    open(sys.argv[2], 'w', encoding='latin-1', newline='').write(j)
    print('ok', len(REPLACE))
