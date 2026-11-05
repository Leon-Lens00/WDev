"""v12b (30/10/2026): salida de la pantalla de modos y entrada a heroe, pedido del usuario.

Al acabar modos sale la esfera a la escala de su primera aparicion (Panel_ArmScale, centro 960, 419) y a la vez
el logo vuelve al centro, el reloj se desvanece y las piezas salen por donde entraron (Mode_OutTick, la entrada
al reves). En el pico la esfera salta a Hero_ArmScale para que su luz cubra la pantalla. Cuando se ha ido
(Hero_Go, 8 s) los texttags de heroe entran por escala (Tx_HeroIn).

Uso: salida_modos_v12b.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


GLOBALS = '''real Mode_OutT= 0
real Mode_OutEnd= 0
real Hero_ArmT= 0
real Tx_InT= 0
real Clock_F= 1.
integer Clock_Last= -1
real Clock_LastX= 0
real Clock_LastY= 0
'''

FUNCS = '''// v12b: the entry played backwards from the same clock; the logo starts at once, as the sphere does.
function Mode_OutTick takes nothing returns nothing
    local integer i = 1
    set Mode_OutT = Mode_OutT + 0.02
    call Mode_Place(0, Mode_Ease(1 - Mode_OutT / Mode_Dur[0], Mode_EaseKind[0]))
    loop
        exitwhen i >= Mode_N
        call Mode_Place(i, Mode_Ease((Mode_OutEnd - Mode_OutT - Mode_T0[i]) / Mode_Dur[i], Mode_EaseKind[i]))
        set i = i + 1
    endloop
    if Mode_OutT >= Mode_OutEnd then
        call PauseTimer(Mode_Timer)
        set i = 1
        loop
            exitwhen i >= Mode_N
            call Tx_Fade(Mode_U[i], 0)
            set i = i + 1
        endloop
    endif
endfunction

function Mode_Out takes nothing returns nothing
    local integer i = 1
    set Mode_OutT = 0
    set Mode_OutEnd = 0
    // SetTextTagColor's alpha changes nothing on a visible tag (v12b in game). The engine's own fade does: the
    // tag ends by itself and Clock_Show makes a new one.
    call SetTextTagPermanent(Clock_Tag, false)
    call SetTextTagAge(Clock_Tag, 0)
    call SetTextTagLifespan(Clock_Tag, 0.9)
    call SetTextTagFadepoint(Clock_Tag, 0)
    set Clock_Tag = null
    loop
        exitwhen i >= Mode_N
        set Mode_OutEnd = RMaxBJ(Mode_OutEnd, Mode_T0[i] + Mode_Dur[i])
        set i = i + 1
    endloop
    call TimerStart(Mode_Timer, 0.02, true, function Mode_OutTick)
endfunction

// v12b: at the burst (the model's orbs have collapsed to a point) from the first appearance's scale to the one
// whose light covers the screen; the fly height keeps the sphere's centre at its depth.
function Hero_ArmTick takes nothing returns nothing
    local real d = Hero_ArmDepth
    local real f
    local real s
    set Hero_ArmT = Hero_ArmT + 0.02
    if Hero_Arm == null or Hero_ArmT >= 4.9 then
        call DestroyTimer(GetExpiredTimer())
    endif
    if Hero_Arm == null or Hero_ArmT < 4.5 then
        return
    endif
    set f = Mode_Ease((Hero_ArmT - 4.5) / 0.4, 1)
    set s = Panel_ArmScale + (Hero_ArmScale - Panel_ArmScale) * f
    call SetUnitX(Hero_Arm, Title_WX(419 + 16 * f, d))
    call SetUnitFlyHeight(Hero_Arm, Title_D() + Title_Eye - d + 620 * s, 0)
    call SetUnitScale(Hero_Arm, s, s, s)
endfunction

'''

IN = '''// v12b: the hero screen's texttags grow in once the light has gone (ease out back).
function Tx_HeroIn takes nothing returns nothing
    local real t
    local real f = 1.
    set Tx_InT = Tx_InT + 0.02
    set t = Tx_InT / 0.35 - 1
    if t >= 0 then
        call DestroyTimer(GetExpiredTimer())
    else
        set f = 1 + 2.7 * t * t * t + 1.7 * t * t
    endif
    call Tx_Fade(Hero_Bg[0], f)
    call Tx_Fade(Hero_Bg[2], f)
    call Tx_Fade(Hero_Bg[4], f)
    set Clock_F = f
    call Clock_Show(Clock_Last, Clock_LastX, Clock_LastY)
endfunction

function Hero_Go takes nothing returns nothing
'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    assert s.startswith('globals' + N)
    s = 'globals' + N + GLOBALS.replace('\n', N) + s[len('globals' + N):]
    # Reloj escalable
    s = once(s, '    call SetTextTagVisibility(Clock_Tag, n >= 0)\n',
             '    set Clock_Last = n\n    set Clock_LastX = px\n    set Clock_LastY = py\n'
             '    call SetTextTagVisibility(Clock_Tag, n >= 0 and Clock_F > 0.04)\n')
    s, n = re.subn(r'( \+ "\|r", )0\.04\)', r'\g<1>0.04 * Clock_F)', s)
    assert n == 1
    s, n = re.subn(r'call Tx_At\(Clock_Tag, px, py, 0\.04, ([\d.]+)\)', r'call Tx_At(Clock_Tag, px, py, 0.04 * Clock_F, \1 * Clock_F)', s)
    assert n == 1
    # Sustituye la ocultacion por tiempo de v12: las etiquetas salen con sus piezas.
    a = s.index('function Tx_ModeHide takes nothing returns nothing')
    b = s.index('function Hero_Begin takes nothing returns nothing')
    s = s[:a] + FUNCS.replace('\n', N) + s[b:]
    s = once(s, '    call TimerStart(CreateTimer(), 4.9, false, function Tx_ModeHide)\n',
             '    call TimerStart(CreateTimer(), 0.02, true, function Hero_ArmTick)\n    call Mode_Out()\n')
    s = once(s, "    set Hero_Arm = CreateUnit(CAMERA_DUMMY_PLAYER, 'uida', Title_WX(435, d), Title_WY(960, d), 90)\n",
             "    set Hero_ArmT = 0\n    set Hero_Arm = CreateUnit(CAMERA_DUMMY_PLAYER, 'uida', Title_WX(419, d), Title_WY(960, d), 90)\n")
    s = once(s, '    call SetUnitFlyHeight(Hero_Arm, Title_D() + Title_Eye - d + 620 * Hero_ArmScale, 0)\n    call SetUnitScale(Hero_Arm, Hero_ArmScale, Hero_ArmScale, Hero_ArmScale)\n',
             '    call SetUnitFlyHeight(Hero_Arm, Title_D() + Title_Eye - d + 620 * Panel_ArmScale, 0)\n    call SetUnitScale(Hero_Arm, Panel_ArmScale, Panel_ArmScale, Panel_ArmScale)\n')
    # Heroe: la pantalla llega bajo la luz sin sus textos
    s = once(s, '''    call Hero_Pieces(true)
    call Hero_ClockShow(60)
    call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)
''', '''    call Tx_Fade(Hero_Bg[0], 0)
    call Tx_Fade(Hero_Bg[2], 0)
    call Tx_Fade(Hero_Bg[4], 0)
    call Hero_Pieces(true)
    set Clock_F = 0
    call Hero_ClockShow(60)
    call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)
''')
    s = once(s, 'function Hero_Go takes nothing returns nothing\n', IN)
    s = once(s, '''    if Title_Exited or not Hero_Active then
        return
    endif
    set Hero_Left = 60
''', '''    set Clock_F = 1.
    if Title_Exited or not Hero_Active then
        return
    endif
    set Tx_InT = 0
    set Clock_F = 0
    call TimerStart(CreateTimer(), 0.02, true, function Tx_HeroIn)
    set Hero_Left = 60
''')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
