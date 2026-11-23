#!/usr/bin/env python3
"""v21w (22/11/2026): botón X (Power Up, ATr1) en el controlador de Trunks.
Leon jugó v21v-prueba: "hace falta agregarle la habilidad X". v21s dejó ATr1 fuera de la barra (X no se usaba) y v21v
lo cableó (Tr_SubirX) sin ponerlo en el controlador. Va en la casilla (1,1), como la X de Goku.
Uso: v21w.py ENTRADA.j SALIDA.j [prueba]   (normal de v21v; prueba de v21v-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia("""        // v21s: Sword of Hope (T).
        call UnitAddAbility(Game_Ctrl[p], 'ATr6')
""", """        // v21s: Sword of Hope (T).
        call UnitAddAbility(Game_Ctrl[p], 'ATr6')
        // v21w: Power Up (X), cableado en v21v (Tr_SubirX).
        call UnitAddAbility(Game_Ctrl[p], 'ATr1')
""")
if prueba:
    cambia('lat\\\\v21v-', 'lat\\\\v21w-', src.count('lat\\\\v21v-'))
    cambia('v21v-don.txt', 'v21w-don.txt', src.count('v21v-don.txt'))
    assert 'lat\\\\v21v-' not in src and 'v21v-don.txt' not in src, 'quedan registros v21v'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21w', 'prueba' if prueba else 'normal')
