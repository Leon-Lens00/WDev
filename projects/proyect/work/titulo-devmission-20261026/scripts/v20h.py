#!/usr/bin/env python3
"""v20h-prueba (20/11/2026): elegir en la partida cuánto se inclina hacia atrás el modelo del cuadro MVP. Sólo prueba.
Sobre v20f-prueba (comandos de calibración, sin oleadas) con los valores de v20g (giro 240, x 1310, y 300).
- Warcraft 1.27b no puede inclinar una unidad desde JASS: se usan copias del Tauren con el modelo inclinado
  ('hMv2' 25°, 'hMv3' 35°, 'hMv4' 45°, 'hMv5' 55°; objetos_v20h.py).
- -incl N (0, 25, 35, 45 o 55): el modelo del cuadro usa esa copia si el personaje es el Tauren ('h005'); con otro
  personaje avisa y sigue con el modelo normal. 0 vuelve al normal. Vale también para el cuadro real.
Uso: v20h.py ENTRADA.j SALIDA.j prueba   (de v20f-prueba)
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


cambia('real MVP_MOD_GIRO = 110.\n', 'real MVP_MOD_GIRO = 240.\n')
cambia('real MVP_MOD_X = 1330.\n', 'real MVP_MOD_X = 1310.\n')
cambia('real MvpCal_PY = 320.\n', 'real MvpCal_PY = 300.\n// v20h-prueba: inclinación del modelo (copias del Tauren).\ninteger MvpCal_Incl = 0\n')
cambia('''// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''', '''// v20h-prueba: tipo con el modelo inclinado (sólo hay copias del Tauren).
function MvpCal_Tipo takes integer id returns integer
    if id != 'h005' then
        return id
    elseif MvpCal_Incl == 25 then
        return 'hMv2'
    elseif MvpCal_Incl == 35 then
        return 'hMv3'
    elseif MvpCal_Incl == 45 then
        return 'hMv4'
    elseif MvpCal_Incl == 55 then
        return 'hMv5'
    endif
    return id
endfunction

// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''')
cambia('set u = CreateUnit(CAMERA_DUMMY_PLAYER, GetUnitTypeId(h), 0., 0., MVP_MOD_GIRO)',
       'set u = CreateUnit(CAMERA_DUMMY_PLAYER, MvpCal_Tipo(GetUnitTypeId(h)), 0., 0., MVP_MOD_GIRO)')
cambia('''    elseif SubString(s, 0, 6) == "-anim " and MvpCal_U[p] != null then''', '''    elseif SubString(s, 0, 6) == "-incl " then
        set MvpCal_Incl = S2I(SubString(s, 6, n))
        if MvpCal_Incl != 0 and MvpCal_Incl != 25 and MvpCal_Incl != 35 and MvpCal_Incl != 45 and MvpCal_Incl != 55 then
            call DisplayTimedTextToPlayer(Player(p), 0, 0, 15, "Inclinaciones: 0, 25, 35, 45 o 55.")
            set MvpCal_Incl = 0
        endif
        if MvpCal_Incl != 0 and GetUnitTypeId(Game_Hero[p]) != 'h005' then
            call DisplayTimedTextToPlayer(Player(p), 0, 0, 15, "Sólo el Tauren tiene copias inclinadas.")
        endif
        if MvpCal_U[p] != null then
            call MvpCal_Poner(p)
        endif
    elseif SubString(s, 0, 6) == "-anim " and MvpCal_U[p] != null then''')
cambia('"MVP: giro " + R2S(MVP_MOD_GIRO)', '"MVP: incl " + I2S(MvpCal_Incl) + "   giro " + R2S(MVP_MOD_GIRO)')
cambia('''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-anim ", false)
''', '''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-anim ", false)
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-incl ", false)
''')
cambia('"Calibración del MVP (sin oleadas): -mvp muestra el cuadro; -giro N, -escala N, -mvpx N, -mvpy N, -anim attack."',
       '"Calibración del MVP (sin oleadas, Tauren): -mvp muestra el cuadro; -incl 25 / 35 / 45 / 55 inclina el modelo (0 normal); -giro, -escala, -mvpx, -mvpy, -anim."')
for viejo, nuevo in (('lat\\\\v20f-', 'lat\\\\v20h-'), ('v20f-don.txt', 'v20h-don.txt')):
    assert viejo in src, viejo
    src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20h prueba')
