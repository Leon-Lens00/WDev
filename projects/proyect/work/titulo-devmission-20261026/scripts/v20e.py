#!/usr/bin/env python3
"""v20e (20/11/2026): encuadre del modelo del cuadro MVP / menos puntos tras la prueba de v20d (vídeo de Leon).
- Se veía de espaldas (el tótem de Tauren.mdl tapaba el cuerpo): giro 290 → 110, de frente a la cámara inclinada.
- Con el ataque asomaba por el borde de arriba del cuadro: 30 px más abajo (pies a y 320 y 552).
Uso: v20e.py ENTRADA.j SALIDA.j [prueba]   (normal de v20d; prueba de v20d-prueba)
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


cambia('constant real MVP_MOD_GIRO = 290.\n', 'constant real MVP_MOD_GIRO = 110.\n')
cambia('MVP_MOD_X, 290.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 320.0 + dy, MVP_MOD_RANGO')
cambia('MVP_MOD_X, 522.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 552.0 + dy, MVP_MOD_RANGO')
if prueba:
    for viejo, nuevo in (('lat\\\\v20d-', 'lat\\\\v20e-'), ('v20d-don.txt', 'v20e-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20e', 'prueba' if prueba else 'normal')
