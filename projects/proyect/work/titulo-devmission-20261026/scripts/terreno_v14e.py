#!/usr/bin/env python3
"""Terreno de v14e: el mapa ampliado por el usuario, con la franja norte plana y sellada para menús y tienda.

El editor estiró hacia arriba la última fila: acantilados, agua y un paso a pie por el oeste. Todo lo que queda al norte
del mapa anterior pasa a un vértice plano, y las filas antiguas de pathing vuelven tal cual, con su borde cerrado.

Uso: terreno_v14e.py DIR_V14D DIR_AMPLIADO DIR_SALIDA
"""
from pathlib import Path
import struct, sys

viejo, nuevo, sal = (Path(a) for a in sys.argv[1:4])
FILA_PLANA = 129  # y 7296: la primera fila que no existía


def malla(b):
    p = 13
    p += 4 + struct.unpack_from('<I', b, p)[0] * 4
    p += 4 + struct.unpack_from('<I', b, p)[0] * 4
    return p + 16, *struct.unpack_from('<II', b, p)


t = (viejo / 'war3map.w3e').read_bytes()
p, ax, ay = malla(t)
modelo = t[p + (104 * ax + 72) * 7:p + (104 * ax + 72) * 7 + 7]  # (0, 4096), donde estaba la escena
b = bytearray((nuevo / 'war3map.w3e').read_bytes())
q, mx, my = malla(b)
assert (ax, ay, mx, my) == (129, 129, 129, 161)
b[q:q + ay * ax * 7] = t[p:p + ay * ax * 7]
for j in range(FILA_PLANA, my):
    b[q + j * mx * 7:q + (j + 1) * mx * 7] = modelo * mx
(sal / 'war3map.w3e').write_bytes(b)

w = bytearray((nuevo / 'war3map.wpm').read_bytes())
v = (viejo / 'war3map.wpm').read_bytes()
wx, wy = struct.unpack_from('<II', w, 8)
n = len(v) - 16
w[16:16 + n] = v[16:]
# Fuera del pasillo central sigue siendo borde: libre sólo donde va la escena.
for j in range(n // wx, wy):
    y = j * 32 - 9216
    for i in range(wx):
        x = i * 32 - 9216
        w[16 + j * wx + i] = 64 if -2000 <= x < 4400 and 7296 <= y < 9728 else 206
(sal / 'war3map.wpm').write_bytes(w)

# Del w3i sólo cambian los límites de cámara y el área jugable.
def campo(i):
    q = 12
    for _ in range(4):
        q = i.index(b'\0', q) + 1
    return q


i = bytearray((viejo / 'war3map.w3i').read_bytes())
a = (nuevo / 'war3map.w3i').read_bytes()
i[campo(i):campo(i) + 56] = a[campo(a):campo(a) + 56]
(sal / 'war3map.w3i').write_bytes(i)
