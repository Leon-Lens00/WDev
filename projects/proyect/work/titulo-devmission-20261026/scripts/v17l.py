#!/usr/bin/env python3
"""v17l (14/11/2026): el Mur'gul Snarecaster vuelve a su tamaño de v17j.

Leon tras probar v17k: "no importa que se corte un poco, si ajustamos ello se quedara pequeno el murlok al estar en stand
con respecto a los demas, y creo ya lo hicimos con el morado y termino pequenio, ajustarias ello y estaria listo".
- Mur'gul Snarecaster (ronda 5) otra vez a escala 1,1375 con OX 35,5 (en v17k al 75 %): en reposo quedaba pequeño frente
  a los demás jefes; que la cabeza se corte un momento al atacar se acepta, como en el Murloc Mutant.
Uso: v17l.py v17k/war3map.j SALIDA.j (y v17k-prueba/war3map.j para la de prueba)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('    set JefePres_Escala[5] = 0.8531\n    set JefePres_OX[5] = 26.6\n',
    '    set JefePres_Escala[5] = 1.1375\n    set JefePres_OX[5] = 35.5\n')
una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17k (scripts/v17k.py): fondo al 80 %, banda larga,\n'
    '// Snarecaster al 75 %;',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17l (scripts/v17l.py): Snarecaster a su tamaño de v17j;\n'
    '// v17k (scripts/v17k.py): fondo al 80 %, banda larga, nombres más grandes;')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17l: Snarecaster a su tamaño')
