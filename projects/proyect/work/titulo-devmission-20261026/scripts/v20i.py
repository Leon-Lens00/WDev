#!/usr/bin/env python3
"""v20i-prueba (20/11/2026): el modelo del cuadro MVP mira de frente a la cámara, como el retrato de las tarjetas de
racha (Leon: "¿no lo puedes ajustar el modelo a nivel de los portraits?"). Sólo prueba, sin oleadas, con comandos.
- Cada personaje tiene una copia 'hMf0'..'hMf6' cuyo modelo cuelga de un hueso billboard en los pies: el motor lo
  gira hacia la cámara, así que el giro de la unidad ya no cuenta. Capas sin sombra ni niebla, como el retrato.
- De frente se ve todo el alto: pies más abajo en el cuadro (y 300 -> 345).
- -frente activa / quita las copias de frente (activas al empezar); sin ellas vuelven -incl y el modelo normal.
Uso: v20i.py ENTRADA.j SALIDA.j prueba   (de v20h-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
assert len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('real MvpCal_PY = 300.\n', 'real MvpCal_PY = 345.\n// v20i-prueba: copias que miran de frente (billboard).\nboolean MvpCal_Frente = true\n')
cambia('''function MvpCal_Tipo takes integer id returns integer
    if id != 'h005' then''', '''function MvpCal_Tipo takes integer id returns integer
    if MvpCal_Frente then
        if id == 'h005' then
            return 'hMf0'
        elseif id == 'h006' then
            return 'hMf1'
        elseif id == 'hGok' then
            return 'hMf2'
        elseif id == 'hFrz' then
            return 'hMf3'
        elseif id == 'hTrk' then
            return 'hMf4'
        elseif id == 'hNar' then
            return 'hMf5'
        elseif id == 'hNaK' then
            return 'hMf6'
        endif
        return id
    endif
    if id != 'h005' then''')
cambia('''function MvpCal_Comando takes nothing returns nothing
''', '''function MvpCal_Si takes boolean b returns string
    if b then
        return "sí"
    endif
    return "no"
endfunction

function MvpCal_Comando takes nothing returns nothing
''')
cambia('''    elseif SubString(s, 0, 6) == "-incl " then''', '''    elseif s == "-frente" then
        set MvpCal_Frente = not MvpCal_Frente
        if MvpCal_U[p] != null then
            call MvpCal_Poner(p)
        endif
    elseif SubString(s, 0, 6) == "-incl " then''')
cambia('"MVP: incl " + I2S(MvpCal_Incl)', '"MVP: frente " + MvpCal_Si(MvpCal_Frente) + "   incl " + I2S(MvpCal_Incl)')
cambia('''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-incl ", false)
''', '''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-incl ", false)
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-frente", true)
''')
cambia('"Calibración del MVP (sin oleadas, Tauren): -mvp muestra el cuadro; -incl 25 / 35 / 45 / 55 inclina el modelo (0 normal); -giro, -escala, -mvpx, -mvpy, -anim."',
       '"Calibración del MVP (sin oleadas): -mvp muestra el cuadro con tu personaje de frente; -frente lo quita / pone; -escala, -mvpx, -mvpy, -anim attack / death."')
for viejo, nuevo in (('lat\\\\v20h-', 'lat\\\\v20i-'), ('v20h-don.txt', 'v20i-don.txt')):
    assert viejo in src, viejo
    src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20i prueba')
