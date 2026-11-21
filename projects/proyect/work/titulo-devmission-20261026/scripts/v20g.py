#!/usr/bin/env python3
"""v20g (20/11/2026): valores del modelo del MVP elegidos en v20f-prueba (cuadro fijo, con capturas de la partida).
- Giro 240 (de frente: cara y pecho, el tótem detrás); x 1310; pies a y 300 (MVP) y 532 (menos puntos). Escala 0,22.
Uso: v20g.py ENTRADA.j SALIDA.j [prueba]   (normal de v20e; prueba de v20e-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')


def cambia(viejo, nuevo, veces=1):
    global src
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('constant real MVP_MOD_GIRO = 110.\n', 'constant real MVP_MOD_GIRO = 240.\n')
cambia('constant real MVP_MOD_X = 1330.\n', 'constant real MVP_MOD_X = 1310.\n')
cambia('MVP_MOD_X, 320.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 300.0 + dy, MVP_MOD_RANGO')
cambia('MVP_MOD_X, 552.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 532.0 + dy, MVP_MOD_RANGO')
if prueba:
    for viejo, nuevo in (('lat\\\\v20e-', 'lat\\\\v20g-'), ('v20e-don.txt', 'v20g-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20g', 'prueba' if prueba else 'normal')
