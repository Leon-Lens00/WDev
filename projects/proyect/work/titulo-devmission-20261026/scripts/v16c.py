#!/usr/bin/env python3
"""v16c (08/11/2026): consola del tutorial como la cuadrícula nativa de 3 × 4, a petición de Leon con su captura.

En la zona que marcó (abajo a la derecha, sobre la consola: columnas x 1500..1818, filas y 535..735) entran desde la
derecha, una tras otra, 12 casillas oscuras con los iconos de las habilidades base en su sitio nativo (abpx, abpy del
w3a):
    Q Subfusiles   W Rifles      E Francotiradores   R Escopetas
    A Disparo      (vacía)       G Recargar          D Dash
    Z Cuerpo a c.  X Explosivos  (vacía)             (vacía)
La cuadrícula va detrás del foco (profundidad 450), así queda oscurecida; el icono de Disparo se cambia por la pieza
de delante (392) que se ilumina y va al centro. Al pasar a la mira, la cuadrícula sale por la derecha.
Parte del j de v16b (visión de las piezas, Tauren sin guardia, cámara cerca).
Uso: v16c.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def jtexto(t):
    b = t.encode('utf-8')
    m = ''.join('0' if 0x80 <= c < 0xC0 else '1' for c in b)
    assert '"' not in t and '\\' not in t and '|' not in t
    return b.decode('latin-1'), m


def decir(lineas, espera):
    args = []
    for l in (lineas + ['', '', ''])[:3]:
        assert len(l) <= 40, l
        s, m = jtexto(l)
        args += [f'"{s}"', f'"{m}"']
    return f'call Tut_Decir({", ".join(args)}, {espera})'


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

s = once(s, 'fogmodifier array Tut_Vista\n', '''fogmodifier array Tut_Vista
unit array Tut_Casilla
unit array Tut_Boton
integer Tut_GModo= 0
real Tut_GIni= 0.
boolean Tut_SinA= false
''')

# Cuadrícula: piezas, movimiento y limpieza.
s = once(s, 'function Tut_PanelVer takes boolean ver returns nothing\n', '''// v16c: casilla i (fila i / 4, columna i - 4 × fila) de la consola del tutorial.
function Tut_Rejilla takes nothing returns nothing
    local integer i= 0
    local real u
    local real x
    local real y
    local boolean ver
    if Tut_GModo == 0 then
        return
    endif
    loop
        exitwhen i > 11
        set u = RMinBJ(1., RMaxBJ(0., ( Tut_T - Tut_GIni - 0.05 * ( ModuloInteger(i, 4) + i / 4 ) ) / 0.45))
        set u = u * u * ( 3. - 2. * u )
        if Tut_GModo == 1 then
            set u = 1. - u
        endif
        set x = 1500. + 106. * ModuloInteger(i, 4) + 560. * u
        set y = 535. + 100. * ( i / 4 )
        set ver = u < 0.999
        call ShowUnit(Tut_Casilla[i], ver)
        if ver then
            call HealthBars__Place(Tut_Casilla[i], Tut_Cam, x, y, 452.)
        endif
        if Tut_Boton[i] != null then
            set ver = ver and not ( i == 4 and Tut_SinA )
            call ShowUnit(Tut_Boton[i], ver)
            if ver then
                call HealthBars__Place(Tut_Boton[i], Tut_Cam, x, y, 450.)
            endif
        endif
        set i = i + 1
    endloop
    if Tut_GModo == 3 and Tut_T > Tut_GIni + 1.1 then
        set Tut_GModo = 0
    endif
endfunction

function Tut_PanelVer takes boolean ver returns nothing
''')
s = once(s, '''    call ShowUnit(Tut_Mira, false)
    // Textos para todos''', '''    call ShowUnit(Tut_Mira, false)
    // v16c: la consola del tutorial (casillas e iconos en su sitio nativo).
    set i = 0
    loop
        exitwhen i > 11
        set Tut_Casilla[i] = Tut_Pieza('uidb')
        call Tut_Foto(Tut_Casilla[i], 72., 72., 452., 'DS1F')
        call ShowUnit(Tut_Casilla[i], false)
        set i = i + 1
    endloop
    set Tut_Boton[0] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[0], 64., 64., 450., 'DS1I')
    set Tut_Boton[1] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[1], 64., 64., 450., 'DS1J')
    set Tut_Boton[2] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[2], 64., 64., 450., 'DS1K')
    set Tut_Boton[3] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[3], 64., 64., 450., 'DS1L')
    set Tut_Boton[4] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[4], 64., 64., 450., 'DS1E')
    set Tut_Boton[6] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[6], 64., 64., 450., 'DS1H')
    set Tut_Boton[7] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[7], 64., 64., 450., 'DS1G')
    set Tut_Boton[8] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[8], 64., 64., 450., 'DS1M')
    set Tut_Boton[9] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[9], 64., 64., 450., 'DS1N')
    set i = 0
    loop
        exitwhen i > 11
        if Tut_Boton[i] != null then
            call ShowUnit(Tut_Boton[i], false)
        endif
        set i = i + 1
    endloop
    set i = 0
    // Textos para todos''')
s = once(s, '''    call RemoveUnit(Tut_Mira)
''', '''    call RemoveUnit(Tut_Mira)
    loop
        exitwhen i > 11
        call RemoveUnit(Tut_Casilla[i])
        if Tut_Boton[i] != null then
            call RemoveUnit(Tut_Boton[i])
        endif
        set i = i + 1
    endloop
    set i = 0
''')
s = once(s, '''    call Tut_Guion()
endfunction''', '''    call Tut_Rejilla()
    call Tut_Guion()
endfunction''')

# Guion: la consola entra mientras el Tauren la nombra; el foco va al Disparo de la cuadrícula.
viejo3 = [l for l in s.split('\r\n') if 'call Tut_Decir("Abajo a la derecha, en la consola,"' in l]
assert len(viejo3) == 1
s = once(s, viejo3[0] + '\n', '''        set Tut_GModo = 1
        set Tut_GIni = Tut_T
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        ''' + decir(['Abajo a la derecha salen tus', 'habilidades base, en su sitio,', 'como en la consola del juego.'], 0.6) + '\n')
s = once(s, '''        call Tut_Poner(0, 1529., 790., 0.)
        call Tut_Poner(1, 1529., 790., 0.)
        call Tut_Poner(2, 260., 0., 0.)
        call Tut_Mover(2, 70., 1., 0.9)
        call ShowUnit(Tut_Icono, true)
        call ShowUnit(Tut_Foco, true)
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
''', '''        call Tut_Poner(0, 1500., 635., 0.)
        call Tut_Poner(1, 1500., 635., 0.)
        call Tut_Poner(2, 260., 0., 0.)
        call Tut_Mover(2, 60., 1., 0.9)
        set Tut_SinA = true
        call ShowUnit(Tut_Icono, true)
        call ShowUnit(Tut_Foco, true)
        call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")
''')
s = once(s, '''        call ShowUnit(Tut_Icono, false)
        call ShowUnit(Tut_Foco, false)
        set Tut_Sig = Tut_T + 0.25''', '''        call ShowUnit(Tut_Icono, false)
        call ShowUnit(Tut_Foco, false)
        set Tut_GModo = 3
        set Tut_GIni = Tut_T
        set Tut_Sig = Tut_T + 0.25''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16c ok')
