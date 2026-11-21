#!/usr/bin/env python3
"""v20j-prueba (20/11/2026): ajuste en la partida de Leon sobre v20i-prueba. De frente ya se ve de pie, pero el Tauren
agacha la cabeza (postura de su stand): copias de frente con 10, 20 y 30° hacia atrás ('hMg1'..'hMg3').
- -incl 10 / 20 / 30 con -frente activo usa esas copias (sólo Tauren); 0 vuelve a la de frente sin inclinar.
- Valores ajustados en la partida: escala 0.27, x 1262, y 358 (centrado en el cuadro y algo más grande).
Uso: v20j.py ENTRADA.j SALIDA.j prueba   (de v20i-prueba)
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


cambia('real MVP_MOD_ESCALA = 0.22\n', 'real MVP_MOD_ESCALA = 0.27\n')
cambia('real MVP_MOD_X = 1310.\n', 'real MVP_MOD_X = 1262.\n')
cambia('real MvpCal_PY = 345.\n', 'real MvpCal_PY = 358.\n')
cambia('''    if MvpCal_Frente then
        if id == 'h005' then
            return 'hMf0'
''', '''    if MvpCal_Frente then
        if id == 'h005' and MvpCal_Incl == 10 then
            return 'hMg1'
        elseif id == 'h005' and MvpCal_Incl == 20 then
            return 'hMg2'
        elseif id == 'h005' and MvpCal_Incl == 30 then
            return 'hMg3'
        elseif id == 'h005' then
            return 'hMf0'
''')
cambia('if MvpCal_Incl != 0 and MvpCal_Incl != 25 and MvpCal_Incl != 35 and MvpCal_Incl != 45 and MvpCal_Incl != 55 then',
       'if MvpCal_Incl != 0 and MvpCal_Incl != 10 and MvpCal_Incl != 20 and MvpCal_Incl != 30 and MvpCal_Incl != 25 and MvpCal_Incl != 35 and MvpCal_Incl != 45 and MvpCal_Incl != 55 then')
cambia('"Inclinaciones: 0, 25, 35, 45 o 55."', '"Inclinaciones: de frente 0, 10, 20 o 30; sin -frente 25, 35, 45 o 55."')
cambia('-frente lo quita / pone; -escala', '-incl 10 / 20 / 30 levanta la cara (Tauren); -frente lo quita / pone; -escala')
for viejo, nuevo in (('lat\\\\v20i-', 'lat\\\\v20j-'), ('v20i-don.txt', 'v20j-don.txt')):
    assert viejo in src, viejo
    src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20j prueba')
