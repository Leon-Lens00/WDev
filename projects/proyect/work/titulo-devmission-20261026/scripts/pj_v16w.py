#!/usr/bin/env python3
"""v16w (13/11/2026): -pj N aceptaba sólo celdas con Hero_Icon, pero Hero_Icon lo rellena Hero_Build, que sólo corre al
mostrar la pantalla de héroes; con la entrada directa no corre y todas valían 0, así que "-pj 5" respondía con el uso
(Leon: "esta bien asi? no funca"). Se quita esa condición: el rango 0..5 ya está comprobado.
Uso: pj_v16w.py v16v/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
a = b'(k == 0 and n != "0") or Hero_Icon[k] == 0 then'
assert j.count(a) == 1, j.count(a)
j = j.replace(a, b'(k == 0 and n != "0") then')
Path(sys.argv[2]).write_bytes(j)
print('v16w: -pj sin Hero_Icon')
