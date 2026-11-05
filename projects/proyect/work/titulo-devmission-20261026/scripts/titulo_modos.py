"""Mode select screen after the Dev Mission title's registration (v8, 27/10/2026). Patches the compiled
war3map.j of v7 (CRLF kept).

When the 20 s registration ends with at least one player registered, the title turns into "Elegir modo de
juego" (layout of the user's reference 00-referencia.png, 1774 x 887, placed 1:1 at offset (73, 20) in
1920 x 1080 so the last box stays above the console):
- the logo (now the nebula menu logo, 'DT0C') glides from the centre to the left, easing in and out;
- the title comes down from above the screen;
- the five long boxes come in from the right like a staircase: each one starts 0.12 s after the previous one,
  without waiting for it to arrive. Box 3 is "Modo supervivencia / 1-10 waves + Boss" (active frame), the
  others are locked (lock and ???). Every box has eight rhombuses, off.
Every piece is a UI picture ('uidb', blended) built once with Title_Pic and moved by Mode_Tick (0.02 s,
synced timer, SetUnitX/Y in mockup pixel space). Once all of them have arrived, each user gets one trackable
per box (ModeHitBox.mdx, z 14, under Start's z 20 and over the background's z 8). Hovering a box shows its bright frame on that
player's client only (scale of a second picture); clicking is synced: only box 3 can be chosen for now, by a registered
player, and lights that player's rhombus in box 3 with their colour for everybody. The other boxes answer
"bloqueado" to the clicking player.
"-titulo" goes back to the title (logo back in the centre), "-salirtitulo" leaves as before, "-modos"
(diagnostic) registers the typing player if needed and opens the mode screen at once.

Usage: titulo_modos.py IN_J OUT_J
"""
from pathlib import Path
import sys

GLOBALS = '''boolean Mode_Active= false
boolean Mode_Ready= false
boolean Mode_Built= false
boolean Mode_Tracked= false
timer Mode_Timer= null
real Mode_Time= 0
integer Mode_N= 0
unit array Mode_U
real array Mode_PX0
real array Mode_PY0
real array Mode_PX1
real array Mode_PY1
real array Mode_T0
real array Mode_Dur
integer array Mode_EaseKind
unit array Mode_Box
unit array Mode_BoxHi
unit array Mode_Gem
unit array Mode_GemLit
integer array Mode_GemTex
integer array Mode_Choice
integer array Mode_Hover
integer Mode_Left= 0
boolean Clock_Built= false
integer array Clock_Tex
unit array Clock_Tens
unit array Clock_Units
integer Mode_Ticks= 0
'''

CONTENT_DEPTH = '394'
TITLE_DIGIT_Y = '112'  # where the title's texttag digits were (v8f in game: centre about 112)
MODE_DIGIT_Y = '628'   # logo centre 504, 446, about 289 tall: its bottom is near 590
LIT_DEPTH = '393.5'
CLOCK = '''
// v8g: the countdown of both screens with digit pictures (ModeDigit0-9, 'DT1D'-'DT26', canvas aspect 0.6875,
// 52 px tall): one picture per digit and place, made hidden on first use and moved/shown, never re-skinned
// (War Club did not retexture moved pieces, v8c). Not texttags: off the screen centre a texttag did not land at
// its pixel point (v8e in game, over "MISSION"). Shown for everybody (same count on every client).
function Clock_Build takes nothing returns nothing
    local integer d = 0
    set Clock_Built = true
    set Clock_Tex[0] = 'DT1D'
    set Clock_Tex[1] = 'DT1E'
    set Clock_Tex[2] = 'DT1F'
    set Clock_Tex[3] = 'DT20'
    set Clock_Tex[4] = 'DT21'
    set Clock_Tex[5] = 'DT22'
    set Clock_Tex[6] = 'DT23'
    set Clock_Tex[7] = 'DT24'
    set Clock_Tex[8] = 'DT25'
    set Clock_Tex[9] = 'DT26'
    loop
        exitwhen d > 9
        set Clock_Units[d] = Title_Pic('uidb', 960, 112, 35.75, 52, 399, Clock_Tex[d])
        call Title_Show(Clock_Units[d], false)
        if d == 1 or d == 2 then
            set Clock_Tens[d] = Title_Pic('uidb', 960, 112, 35.75, 52, 399, Clock_Tex[d])
            call Title_Show(Clock_Tens[d], false)
        endif
        set d = d + 1
    endloop
endfunction

function Clock_Put takes unit u, real px, real py returns nothing
    call SetUnitX(u, Title_WX(py, 399))
    call SetUnitY(u, Title_WY(px, 399))
    call Title_Show(u, true)
endfunction

// n (0-29) centred on (px, py); n < 0 hides the clock.
function Clock_Show takes integer n, real px, real py returns nothing
    local integer d = 0
    if not Clock_Built then
        call Clock_Build()
    endif
    loop
        exitwhen d > 9
        call Title_Show(Clock_Units[d], false)
        set d = d + 1
    endloop
    call Title_Show(Clock_Tens[1], false)
    call Title_Show(Clock_Tens[2], false)
    if n < 0 then
        return
    endif
    if n >= 10 then
        call Clock_Put(Clock_Tens[n / 10], px - 14, py)
        call Clock_Put(Clock_Units[n - n / 10 * 10], px + 14, py)
    else
        call Clock_Put(Clock_Units[n], px, py)
    endif
endfunction

'''

FUNCS = '''
// v8: mode select screen, see scripts/titulo_modos.py. The boxes' contents are at depth 394, not 399.5: the
// engine draws translucent pieces from the farthest to the nearest, and the right-hand rhombuses at 399.5 were
// farther from the eye than their box's centre, so the frame covered them (v8 in game). 396 is the limit. Pieces in 1920 x 1080 pixels: the reference layout
// at offset (73, 20); boxes centred on x 1311, every 146 from y 181, 790 x 116.
function Mode_Add takes unit u, real px0, real py0, real px1, real py1, real t0, real dur, integer ease returns nothing
    set Mode_U[Mode_N] = u
    set Mode_PX0[Mode_N] = px0
    set Mode_PY0[Mode_N] = py0
    set Mode_PX1[Mode_N] = px1
    set Mode_PY1[Mode_N] = py1
    set Mode_T0[Mode_N] = t0
    set Mode_Dur[Mode_N] = dur
    set Mode_EaseKind[Mode_N] = ease
    set Mode_N = Mode_N + 1
endfunction

// Piece i at fraction f of its way (0 start, 1 end).
function Mode_Place takes integer i, real f returns nothing
    local real px = Mode_PX0[i] + (Mode_PX1[i] - Mode_PX0[i]) * f
    local real py = Mode_PY0[i] + (Mode_PY1[i] - Mode_PY0[i]) * f
    local real d = LoadReal(Title_HT, GetHandleId(Mode_U[i]), 2)
    call SetUnitX(Mode_U[i], Title_WX(py, d))
    call SetUnitY(Mode_U[i], Title_WY(px, d))
endfunction

// Ease out cubic (0) or in-out cubic (1).
function Mode_Ease takes real t, integer ease returns real
    if t <= 0 then
        return 0.
    endif
    if t >= 1 then
        return 1.
    endif
    if ease == 1 then
        if t < 0.5 then
            return 4 * t * t * t
        endif
        set t = 2 - 2 * t
        return 1 - t * t * t / 2
    endif
    set t = 1 - t
    return 1 - t * t * t
endfunction

// A picture that ends at (px, py) and starts (dx, dy) pixels away.
function Mode_Pic takes real px, real py, real w, real h, real depth, integer tex, real dx, real dy, real t0 returns unit
    local unit u = Title_Pic('uidb', px, py, w, h, depth, tex)
    call Mode_Add(u, px + dx, py + dy, px, py, t0, 0.7, 0)
    return u
endfunction

function Mode_Build takes nothing returns nothing
    local integer b = 0
    local integer p
    local real cy
    local real t0
    local real gy
    local unit u
    set Mode_Built = true
    set Mode_Timer = CreateTimer()
    // Rawcodes are not plain counters past '9' ('DT19' + 1 is 'DT1:'), so one by one.
    set Mode_GemTex[0] = 'DT15'
    set Mode_GemTex[1] = 'DT16'
    set Mode_GemTex[2] = 'DT17'
    set Mode_GemTex[3] = 'DT18'
    set Mode_GemTex[4] = 'DT19'
    set Mode_GemTex[5] = 'DT1A'
    set Mode_GemTex[6] = 'DT1B'
    set Mode_GemTex[7] = 'DT1C'
    call Mode_Add(Title_Logo, 960, 419, 504, 446, 0, 0.9, 1)
    set u = Mode_Pic(960, 62, 610, 75, 400, 'DT0D', 0, -150, 0.25)
    loop
        exitwhen b > 4
        set cy = 181 + 146 * b
        set t0 = 0.35 + 0.12 * b
        set gy = cy + 30
        // Every box has the dark frame; the bright one lies over it and shows only under the cursor (user, 27/10).
        set Mode_Box[b] = Mode_Pic(1311, cy, 790, 116, 400, 'DT0F', 1250, 0, t0)
        set Mode_BoxHi[b] = Mode_Pic(1311, cy, 790, 116, 399.5, 'DT0E', 1250, 0, t0)
        if b == 2 then
            set u = Mode_Pic(1311 - 170, cy - 26, 300, 38.6, CONTENT_DEPTH, 'DT11', 1250, 0, t0)
            set u = Mode_Pic(1311 - 230, cy + 6, 180, 20.7, CONTENT_DEPTH, 'DT12', 1250, 0, t0)
            set gy = cy + 32
        else
            set u = Mode_Pic(1311 - 305, cy - 14, 38, 47.6, CONTENT_DEPTH, 'DT10', 1250, 0, t0)
            set u = Mode_Pic(1311 - 205, cy - 14, 58, 33.2, CONTENT_DEPTH, 'DT13', 1250, 0, t0)
        endif
        set p = 0
        loop
            exitwhen p > 7
            set Mode_Gem[b * 8 + p] = Mode_Pic(1311 - 308 + 47.6 * p, gy, 19, 29.4, CONTENT_DEPTH, 'DT14', 1250, 0, t0)
            set p = p + 1
        endloop
        set b = b + 1
    endloop
    // The lit rhombuses of box 3, one per player in its colour, over the off ones and hidden until chosen. Not a
    // skin change on the off rhombus: War Club did not retexture these moved pieces (v8c in game).
    set p = 0
    loop
        exitwhen p > 7
        set Mode_GemLit[p] = Mode_Pic(1311 - 308 + 47.6 * p, 181 + 146 * 2 + 32, 19, 29.4, LIT_DEPTH, Mode_GemTex[p], 1250, 0, 0.35 + 0.12 * 2)
        set p = p + 1
    endloop
    set u = null
endfunction

// Visual only: on player p's client the bright frame of the hovered box is shown, the others hidden (scale 0).
function Mode_ShowHover takes integer p returns nothing
    local integer b = 0
    local real s
    loop
        exitwhen b > 4
        set s = 0
        if b == Mode_Hover[p] then
            set s = LoadReal(Title_HT, GetHandleId(Mode_BoxHi[b]), 1)
        endif
        if GetLocalPlayer() == Player(p) then
            call SetUnitScale(Mode_BoxHi[b], s, s, s)
        endif
        set b = b + 1
    endloop
endfunction

// One trackable per box for every user player, made once (trackables cannot be destroyed in 1.27). The quads
// are 14 above the ground: over the background (8) but under Start (20), so after "-titulo" Start is still
// clickable; on this screen Start's quad, which lies inside box 4, counts as box 4.
function Mode_Tracks takes nothing returns nothing
    local integer p = 0
    local integer b
    local real depth = Title_D() + Title_Eye - 14
    set Mode_Tracked = true
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set b = 0
            loop
                exitwhen b > 4
                call Title_Track(p, "war3mapImported\\\\ModeHitBox.mdx", Title_WX(181 + 146 * b, depth), Title_WY(1311, depth), 10 + b)
                set b = b + 1
            endloop
        endif
        set p = p + 1
    endloop
endfunction

function Mode_Tick takes nothing returns nothing
    local integer i = 0
    local boolean done = true
    local real f
    set Mode_Time = Mode_Time + 0.02
    loop
        exitwhen i >= Mode_N
        set f = (Mode_Time - Mode_T0[i]) / Mode_Dur[i]
        if f < 1 then
            set done = false
        endif
        call Mode_Place(i, Mode_Ease(f, Mode_EaseKind[i]))
        set i = i + 1
    endloop
    if done then
        call PauseTimer(Mode_Timer)
        set Mode_Ready = true
        // v8e: 20 s to choose, counted from the moment every piece has arrived, under the logo.
        set Mode_Left = 20
        set Mode_Ticks = 0
        call Clock_Show(Mode_Left, 504, MODE_DIGIT_Y)
        if not Mode_Tracked then
            call Mode_Tracks()
        endif
    endif
endfunction

function Mode_Start takes nothing returns nothing
    local integer i = 0
    set Title_Active = false
    set Mode_Active = true
    set Mode_Ready = false
    set Mode_Left = -1
    set Mode_Time = 0
    if not Mode_Built then
        call Mode_Build()
    endif
    call Title_Show(Title_Start, false)
    call SetTextTagVisibility(Title_Clock, false)
    call Clock_Show(-1, 0, 0)
    loop
        exitwhen i > 11
        set Title_Hover[i] = false
        call Title_ShowHover(i)
        if i < 8 then
            call Title_Show(Title_Gem[i], false)
        endif
        set Mode_Choice[i] = -1
        set Mode_Hover[i] = -1
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i >= Mode_N
        call Title_Show(Mode_U[i], true)
        call Mode_Place(i, 0)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 7
        call Title_Show(Mode_GemLit[i], false)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 11
        call Mode_ShowHover(i)
        set i = i + 1
    endloop
    call TimerStart(Mode_Timer, 0.02, true, function Mode_Tick)
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15, "Registro cerrado: " + I2S(Title_Count) + " jugadores. Elige modo de juego (de momento, Modo supervivencia). -titulo vuelve al titulo.")
endfunction

// Back to the title screen (-titulo) or before leaving (-salirtitulo): mode pieces hidden, logo centred.
function Mode_Reset takes nothing returns nothing
    local integer i = 1
    if not Mode_Built then
        return
    endif
    set Mode_Active = false
    set Mode_Ready = false
    call PauseTimer(Mode_Timer)
    loop
        exitwhen i >= Mode_N
        call Title_Show(Mode_U[i], false)
        set i = i + 1
    endloop
    call Mode_Place(0, 0)
    call Clock_Show(-1, 0, 0)
    set i = 0
    loop
        exitwhen i > 7
        call Title_Show(Title_Gem[i], true)
        set i = i + 1
    endloop
    call SetTextTagVisibility(Title_Clock, true)
endfunction

function Mode_OnTrack takes integer p, integer kind returns nothing
    local integer b = -1
    if kind == 0 then
        set kind = 13
    endif
    if kind >= 10 and Mode_Ready then
        set b = kind - 10
    endif
    if b != Mode_Hover[p] then
        set Mode_Hover[p] = b
        call Mode_ShowHover(p)
    endif
endfunction

function Mode_OnHit takes integer p, integer kind returns nothing
    if kind == 0 then
        set kind = 13
    endif
    if not Mode_Ready or kind < 10 then
        return
    endif
    if kind != 12 then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 5, "Modo bloqueado por ahora.")
        return
    endif
    if not Title_Registered[p] then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 5, "No te registraste con Start.")
        return
    endif
    if Mode_Choice[p] == 2 then
        return
    endif
    set Mode_Choice[p] = 2
    if p < 8 then
        call Title_Show(Mode_GemLit[p], true)
    endif
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 8, GetPlayerName(Player(p)) + " eligio Modo supervivencia.")
endfunction

// v8e: the 20 s are over. Choosing stops (no hover, no clicks); the screen stays with the rhombuses lit.
function Mode_Finish takes nothing returns nothing
    local integer p = 0
    local integer n = 0
    set Mode_Ready = false
    loop
        exitwhen p > 11
        set Mode_Hover[p] = -1
        call Mode_ShowHover(p)
        if Mode_Choice[p] == 2 then
            set n = n + 1
        endif
        set p = p + 1
    endloop
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15, "Tiempo agotado: " + I2S(n) + " de " + I2S(Title_Count) + " eligieron Modo supervivencia.")
endfunction

// Called by Title_Tick every 0.05 s: one second every 20 ticks once the pieces have arrived.
function Mode_ClockTick takes nothing returns nothing
    if not Mode_Active or not Mode_Ready then
        return
    endif
    set Mode_Ticks = Mode_Ticks + 1
    if Mode_Ticks >= 20 then
        set Mode_Ticks = 0
        set Mode_Left = Mode_Left - 1
        call Clock_Show(Mode_Left, 504, MODE_DIGIT_Y)
        if Mode_Left <= 0 then
            call Mode_Finish()
        endif
    endif
endfunction

// v8i: after "-ajuste" (new eye height) the clock digits and the mode pieces get their height again, and the
// clock goes back to the screen that is up (before, Title_ClockText put the title's count over the mode screen).
// The boxes' trackables are not remade: they are made once and cannot be destroyed in 1.27.
function Mode_Refresh takes nothing returns nothing
    local integer i = 0
    if Clock_Built then
        loop
            exitwhen i > 9
            call Title_Height(Clock_Units[i])
            set i = i + 1
        endloop
        call Title_Height(Clock_Tens[1])
        call Title_Height(Clock_Tens[2])
    endif
    if Mode_Built then
        set i = 0
        loop
            exitwhen i >= Mode_N
            call Title_Height(Mode_U[i])
            set i = i + 1
        endloop
    endif
    if not Mode_Active then
        call Title_ClockText()
    else
        // -1 while the pieces come in (Mode_Start), 20-0 once they have arrived.
        call Clock_Show(Mode_Left, 504, MODE_DIGIT_Y)
    endif
endfunction

// Diagnostic: "-modos" registers the typing player if needed and opens the mode screen now.
function Mode_Debug takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    if Title_Exited or Mode_Active then
        return
    endif
    if not Title_Registered[p] then
        set Title_Registered[p] = true
        set Title_Count = Title_Count + 1
    endif
    call Mode_Start()
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    j = once(j, 'unit Title_Bg= null\n', 'unit Title_Bg= null\n' + GLOBALS)
    j = once(j, 'function Title_Finish takes nothing returns nothing\n', FUNCS.replace('CONTENT_DEPTH', CONTENT_DEPTH).replace('LIT_DEPTH', LIT_DEPTH).replace('MODE_DIGIT_Y', MODE_DIGIT_Y) + 'function Title_Finish takes nothing returns nothing\n')
    # Registration over: the mode screen when somebody registered, the old message otherwise.
    j = once(j, 'function Title_Finish takes nothing returns nothing\n    local integer p = 0\n    local string names = ""\n',
             'function Title_Finish takes nothing returns nothing\n    local integer p = 0\n    local string names = ""\n'
             '    if Title_Count > 0 then\n        call Mode_Start()\n        return\n    endif\n')
    j = once(j, '    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]\n',
             '    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]\n'
             '    if Mode_Active then\n        call Mode_OnTrack(p, LoadInteger(Title_HT, id, 1))\n        return\n    endif\n')
    j = once(j, '    local integer p = LoadInteger(Title_HT, id, 0)\n    if LoadInteger(Title_HT, id, 3) != Title_Gen',
             '    local integer p = LoadInteger(Title_HT, id, 0)\n'
             '    if Mode_Active then\n        call Mode_OnHit(p, LoadInteger(Title_HT, id, 1))\n        return\n    endif\n'
             '    if LoadInteger(Title_HT, id, 3) != Title_Gen')
    j = once(j, '    if Title_Exited then\n        return\n    endif\n    loop\n        exitwhen p > 11\n        set Title_Registered[p] = false\n',
             '    if Title_Exited then\n        return\n    endif\n    call Mode_Reset()\n    loop\n        exitwhen p > 11\n        set Title_Registered[p] = false\n')
    j = once(j, '    set Title_Exited = true\n    set Title_Active = false\n    call PauseTimer(Title_Timer)\n',
             '    set Title_Exited = true\n    set Title_Active = false\n    call PauseTimer(Title_Timer)\n    call Mode_Reset()\n')
    j = once(j, "    set Title_Logo = Title_Pic('uidm', 960, 419, 536, 287, 400, 'DT00')\n",
             "    // v8: the nebula menu logo (aspect 1.965), blended; it moves left on the mode screen.\n"
             "    set Title_Logo = Title_Pic('uidb', 960, 419, 568, 289, 400, 'DT0C')\n")
    j = once(j, '    local trigger f = CreateTrigger()\n', '    local trigger f = CreateTrigger()\n    local trigger m = CreateTrigger()\n')
    j = once(j, '        call TriggerRegisterPlayerChatEvent(f, Player(p), "-fondo ", false)\n',
             '        call TriggerRegisterPlayerChatEvent(f, Player(p), "-fondo ", false)\n'
             '        call TriggerRegisterPlayerChatEvent(m, Player(p), "-modos", true)\n')
    j = once(j, '    call TriggerAddAction(f, function Title_BackgroundSet)\n',
             '    call TriggerAddAction(f, function Title_BackgroundSet)\n    call TriggerAddAction(m, function Mode_Debug)\n')
    j = once(j, '    set f = null\n', '    set f = null\n    set m = null\n')
    # v8g: one clock of digit pictures for both screens (user, 28/10: "aplicar ese nuevo tipo de numero en el
    # primer panel"). The texttag stays, empty, because the title code still shows, hides and destroys it.
    j = once(j, 'function Title_ClockText takes nothing returns nothing\n', CLOCK + 'function Title_ClockText takes nothing returns nothing\n')
    j = once(j, '''function Title_ClockText takes nothing returns nothing
    local real off = 13
    if Title_Left >= 10 then
        set off = 26
    endif
    call SetTextTagText(Title_Clock, "|cffffd100" + I2S(Title_Left) + "|r", 0.046)
''', '''function Title_ClockText takes nothing returns nothing
    local real off = 13
    if Title_Left >= 10 then
        set off = 26
    endif
    call SetTextTagText(Title_Clock, "", 0.046)
    call Clock_Show(Title_Left, 960, TITLE_DIGIT_Y)
'''.replace('TITLE_DIGIT_Y', TITLE_DIGIT_Y))
    j = once(j, '    call DestroyTextTag(Title_Clock)\n', '    call Clock_Show(-1, 0, 0)\n    call DestroyTextTag(Title_Clock)\n')
    j = once(j, '    call Title_ClockText()\n    call Title_Tracks()\n', '    call Mode_Refresh()\n    call Title_Tracks()\n')
    j = once(j, '''function Title_Tick takes nothing returns nothing
    call Title_Camera()
''', '''function Title_Tick takes nothing returns nothing
    call Title_Camera()
    call Mode_ClockTick()
''')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
