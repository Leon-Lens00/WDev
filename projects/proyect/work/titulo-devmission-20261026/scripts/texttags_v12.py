"""v12 (30/10/2026): todo el texto de las pantallas como texttags con degradado por letra.

Cada texttag se ata a la pieza que llevaba el texto (la unidad sigue de ancla, su textura ya sin letras:
textos_v12.py). Title_Show, los SetUnitX/Y de las animaciones y los encogidos no cambian: Tx_Tick copia la
posicion y Tx_Fade la visibilidad y el tamano. El reloj pasa de unidades-digito a un solo texttag.
Los "?" de las celdas y los "???" de las cajas de modo se quedan como imagen (usuario, 30/10).

Uso: texttags_v12.py IN_J OUT_J FRIZQT.ttf
"""
from pathlib import Path
import re, sys
from PIL import ImageFont

N = '\r\n'
A, B = (150, 205, 255), (250, 253, 255)


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


def utf(t):
    return t.encode('utf8').decode('latin-1')


def grad(text, a=A, b=B, k=1.0):
    """Un color por letra, mas claro en el centro. Cada caracter entero, tambien los de dos bytes."""
    out = ''
    n = max(len(text) - 1, 1)
    for i, c in enumerate(text):
        t = abs(2 * i / n - 1)
        col = [round((b[j] + (a[j] - b[j]) * t) * k) for j in range(3)]
        out += '|cff%02x%02x%02x%s|r' % (*col, utf(c)) if c != ' ' else ' '
    return '"' + out + '"'


def width(text, size):
    # 0.93: medido en juego (Friz de PIL a 1080 por unidad sale 7 % mas ancho que el texttag).
    return ImageFont.truetype(sys.argv[3], 1000).getlength(text) * size * 1080 / 1000 * 0.93


def bind(u, text, size, dx=0, dy=0, left=None):
    w = width(text, size)
    if left is not None:
        dx = left + w / 2
    return f'    call Tx_Bind({u}, {grad(text)}, {size}, {w:.1f}, {dx:.1f}, {dy:.1f})\n'


GLOBALS = '''integer Tx_N= 0
unit array Tx_U
texttag array Tx_T
string array Tx_S
real array Tx_Size
real array Tx_W
real array Tx_DX
real array Tx_DY
real array Tx_F
boolean array Tx_On
timer Tx_Timer= null
texttag Clock_Tag= null
'''

FUNCS = '''// v12: a texttag at screen (px, py), px its centre: w is its width in pixels (Friz at 1080 per unit of size).
function Tx_At takes texttag t, real px, real py, real size, real w returns nothing
    call SetTextTagPos(t, Title_WX(py + 0.75 * 1080 * size, 400 - Title_Eye), Title_WY(px - w / 2 + 150 * size, 400 - Title_Eye), Title_D() + Title_Eye - 400)
endfunction

// The tag follows its unit: screen point of the unit at its own depth (Title_WX, Title_WY inverted) + offset.
function Tx_Place takes integer i returns nothing
    local real d = LoadReal(Title_HT, GetHandleId(Tx_U[i]), 2)
    local real px = 961. + (GetUnitY(Tx_U[i]) - Title_Y()) / ((0.544 / 718.18930543) * d)
    local real py = 438.17 + 1.0296 * (GetUnitX(Tx_U[i]) - Title_X()) / ((0.302 / 387.73819261) * d)
    call Tx_At(Tx_T[i], px + Tx_DX[i] * Tx_F[i], py + Tx_DY[i] * Tx_F[i], Tx_Size[i] * Tx_F[i], Tx_W[i] * Tx_F[i])
endfunction

// Fraction f of the piece's size (0 hides). Boss_ShrinkApply and Strat_Grow scale units without Title_Show.
function Tx_Fade takes unit u, real f returns nothing
    local integer i = LoadInteger(Title_HT, GetHandleId(u), 7) - 1
    if i < 0 or Tx_U[i] != u then
        return
    endif
    set Tx_F[i] = f
    set Tx_On[i] = f > 0.04
    call SetTextTagVisibility(Tx_T[i], Tx_On[i])
    if Tx_On[i] then
        call SetTextTagText(Tx_T[i], Tx_S[i], Tx_Size[i] * f)
        call Tx_Place(i)
    endif
endfunction

function Tx_Tick takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= Tx_N
        if Tx_U[i] != null then
            if GetUnitTypeId(Tx_U[i]) == 0 then
                call DestroyTextTag(Tx_T[i])
                set Tx_T[i] = null
                set Tx_U[i] = null
                set Tx_On[i] = false
            elseif Tx_On[i] then
                call Tx_Place(i)
            endif
        endif
        set i = i + 1
    endloop
endfunction

function Tx_Bind takes unit u, string s, real size, real w, real dx, real dy returns nothing
    set Tx_U[Tx_N] = u
    set Tx_S[Tx_N] = s
    set Tx_Size[Tx_N] = size
    set Tx_W[Tx_N] = w
    set Tx_DX[Tx_N] = dx
    set Tx_DY[Tx_N] = dy
    set Tx_F[Tx_N] = 0
    set Tx_On[Tx_N] = false
    set Tx_T[Tx_N] = CreateTextTag()
    call SetTextTagPermanent(Tx_T[Tx_N], true)
    call SetTextTagVisibility(Tx_T[Tx_N], false)
    call SaveInteger(Title_HT, GetHandleId(u), 7, Tx_N + 1)
    set Tx_N = Tx_N + 1
    if Tx_Timer == null then
        set Tx_Timer = CreateTimer()
        call TimerStart(Tx_Timer, 0.03, true, function Tx_Tick)
    endif
endfunction

'''


def clock():
    size, w = 0.04, width('0:30', 0.04)
    c = []
    for i in range(4):
        t = abs(2 * i / 3 - 1)
        c.append('|cff%02x%02x%02x' % tuple(round(B[j] + (A[j] - B[j]) * t) for j in range(3)))
    return f'''// n seconds (0-119) as M:SS centred on (px, py); n < 0 hides the clock. v12: one texttag.
function Clock_Show takes integer n, real px, real py returns nothing
    local integer s
    if Clock_Tag == null then
        set Clock_Tag = CreateTextTag()
        call SetTextTagPermanent(Clock_Tag, true)
    endif
    call SetTextTagVisibility(Clock_Tag, n >= 0)
    if n < 0 then
        return
    endif
    set s = n - n / 60 * 60
    call SetTextTagText(Clock_Tag, "{c[0]}" + I2S(n / 60) + "|r{c[1]}:|r{c[2]}" + I2S(s / 10) + "|r{c[3]}" + I2S(s - s / 10 * 10) + "|r", {size})
    call Tx_At(Clock_Tag, px, py, {size}, {w:.1f})
endfunction

'''


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    assert s.startswith('globals' + N)
    s = 'globals' + N + GLOBALS.replace('\n', N) + s[len('globals' + N):]
    s = once(s, 'function Title_Skin takes unit u, integer tex returns nothing', FUNCS + 'function Title_Skin takes unit u, integer tex returns nothing')
    s = once(s, '''    local real s = 0
    if on then
        set s = LoadReal(Title_HT, GetHandleId(u), 1)
    endif
    call SetUnitScale(u, s, s, s)
endfunction
''', '''    local real s = 0
    if on then
        set s = LoadReal(Title_HT, GetHandleId(u), 1)
        call Tx_Fade(u, 1)
    else
        call Tx_Fade(u, 0)
    endif
    call SetUnitScale(u, s, s, s)
endfunction
''')
    # Reloj
    a = s.index('// n seconds (0-119) as M:SS centred on (px, py); n < 0 hides the clock.')
    b = s.index('function Title_ClockText takes nothing returns nothing')
    s = s[:a] + clock().replace('\n', N) + s[b:]
    s = once(s, '''    if not Clock_Built then
        call Clock_Build()
    endif
''', '')
    # Inicio
    dim = grad('Start', k=0.47)
    s = once(s, "    call Title_Show(Title_StartHover, false)\n    loop\n        exitwhen p > 7\n        set Title_Gem[p]",
             "    call Title_Show(Title_StartHover, false)\n" + bind('Title_Start', 'Start', 0.032)
             + "    call Tx_Fade(Title_Start, 1)\n    loop\n        exitwhen p > 7\n        set Title_Gem[p]")
    s = once(s, "        call SetUnitVertexColor(Title_Start, c, c, c, 255)\n",
             "        call SetUnitVertexColor(Title_Start, c, c, c, 255)\n"
             "        if c < 255 then\n"
             "            call SetTextTagText(Tx_T[LoadInteger(Title_HT, GetHandleId(Title_Start), 7) - 1], " + dim + ", 0.032)\n"
             "        endif\n")
    # Modos
    s = once(s, "    set u = Mode_Pic(960, 62, 610, 75, 400, 'DT0D', 0, -150, 0.25)\n",
             "    set u = Mode_Pic(960, 62, 610, 75, 400, 'DT0D', 0, -150, 0.25)\n" + bind('u', 'Elegir modo de juego', 0.042))
    s = once(s, "            set u = Mode_Pic(1311 - 170, cy - 26, 300, 38.6, 394, 'DT11', 1250, 0, t0)\n",
             "            set u = Mode_Pic(1311 - 170, cy - 26, 300, 38.6, 394, 'DT11', 1250, 0, t0)\n" + '    ' + bind('u', 'Modo supervivencia', 0.036, dy=-9, left=-150))
    s = once(s, "            set u = Mode_Pic(1311 - 230, cy + 6, 180, 20.7, 394, 'DT12', 1250, 0, t0)\n",
             "            set u = Mode_Pic(1311 - 230, cy + 6, 180, 20.7, 394, 'DT12', 1250, 0, t0)\n" + '    ' + bind('u', '1-10 waves + Boss', 0.024, dy=-1, left=-90))
    # Heroe: las etiquetas de modos se van justo antes del destello de Hero_Arm; encima de el taparian la luz.
    s = once(s, 'function Hero_Begin takes nothing returns nothing\n', '''function Tx_ModeHide takes nothing returns nothing
    local integer i = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen i >= Mode_N
        call Tx_Fade(Mode_U[i], 0)
        set i = i + 1
    endloop
    call Clock_Show(-1, 0, 0)
endfunction

function Hero_Begin takes nothing returns nothing
''')
    s = once(s, '    call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)\n',
             '    call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)\n    call TimerStart(CreateTimer(), 4.9, false, function Tx_ModeHide)\n')
    s = once(s, "    set Hero_Bg[5] = Title_Pic('uidb', 1487, 394, 289.56, 281.60, 403, 'DT3E')\n",
             "    set Hero_Bg[5] = Title_Pic('uidb', 1487, 394, 289.56, 281.60, 403, 'DT3E')\n"
             + bind('Hero_Bg[0]', 'Selección de héroe', 0.04, 968 - 781.5, -8)
             + bind('Hero_Bg[2]', 'Tiempo de selección', 0.024)
             + bind('Hero_Bg[4]', 'Lock in', 0.036, 2, 101))
    # Boss
    s = once(s, "    set Boss_Bg[4] = Title_Pic('uidb', 1278, 670, 256, 64, 404, 'DT2W')\n",
             "    set Boss_Bg[4] = Title_Pic('uidb', 1278, 670, 256, 64, 404, 'DT2W')\n"
             + bind('Boss_Bg[0]', 'Selección de boss', 0.04, 968 - 781.5, -8)
             + bind('Boss_Bg[2]', 'Tiempo de selección', 0.024))
    s = once(s, "    set Boss_Name = Title_Pic('uidb', 970, 663, 256, 128, 403, 'DT30')\n",
             "    set Boss_Name = Title_Pic('uidb', 970, 663, 256, 128, 403, 'DT30')\n" + bind('Boss_Name', 'Nereus', 0.056, -2, 3))
    s = once(s, "    set Boss_PickBtn = Title_Pic('uidb', 968, 757, 374, 114, 401, 'DT38')\n",
             "    set Boss_PickBtn = Title_Pic('uidb', 968, 757, 374, 114, 401, 'DT38')\n" + bind('Boss_PickBtn', 'Lock in', 0.036))
    s = once(s, "        call SetUnitScale(Boss_SU[i], s, s, s)\n", "        call SetUnitScale(Boss_SU[i], s, s, s)\n        call Tx_Fade(Boss_SU[i], f)\n")
    s = once(s, "        call SetUnitScale(Boss_SU[i], 0, 0, 0)\n", "        call SetUnitScale(Boss_SU[i], 0, 0, 0)\n        call Tx_Fade(Boss_SU[i], 0)\n")
    # Estrategia
    s = once(s, "    set Strat_Pic[3] = Title_Pic('uidb', 968, 205, 435.2, 54.4, 404, 'DT3D')\n",
             "    set Strat_Pic[3] = Title_Pic('uidb', 968, 205, 435.2, 54.4, 404, 'DT3D')\n"
             + bind('Strat_Pic[0]', 'Fase de estrategia', 0.04, -9.5, 0)
             + bind('Strat_Pic[1]', 'Información', 0.03, 0, -42)
             + bind('Strat_Pic[2]', 'Tiempo de estrategia', 0.024)
             + bind('Strat_Pic[3]', 'Entrando a partida con:', 0.024))
    s = once(s, "        call SetUnitScale(Strat_GU[i], s, s, s)\n", "        call SetUnitScale(Strat_GU[i], s, s, s)\n        call Tx_Fade(Strat_GU[i], f)\n")
    s, n = re.subn(r'(set Strat_(?:Lbl|Info)\[\d+\] = )"([^"]*)"', lambda m: m.group(1) + grad(m.group(2).encode('latin-1').decode('utf8')), s)
    assert n >= 10, n
    s = once(s, 'call SetTextTagText(Strat_Tag[2], "Jefe tauren", 0.032)', 'call SetTextTagText(Strat_Tag[2], ' + grad('Jefe tauren') + ', 0.032)')
    s = once(s, 'call SetTextTagText(Strat_Tag[2], "???", 0.032)', 'call SetTextTagText(Strat_Tag[2], ' + grad('???') + ', 0.032)')
    # Presentacion
    s = once(s, "    set Pres_Name = Title_Pic('uidb', 961, 665.5, 256, 128, 320, 'DT30')\n",
             "    set Pres_Name = Title_Pic('uidb', 961, 665.5, 256, 128, 320, 'DT30')\n" + bind('Pres_Name', 'Nereus', 0.056, -2, 3))
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
