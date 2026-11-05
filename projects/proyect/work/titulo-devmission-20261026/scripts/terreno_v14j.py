#!/usr/bin/env python3
"""Terreno de v14j: el mapa ensanchado por el usuario (Swamped-Puntos-v14g.w3x, 48 casillas a cada lado), para que el
minimapa sea apaisado. Las franjas nuevas no se juegan: quedan planas y selladas.

El editor estiró hacia los lados la primera y la última columna (tierra al oeste, agua al este) y recalculó la marca de
borde. Del guardado del usuario se toman la malla vieja (con su borde nuevo), los límites de cámara y el área jugable;
las franjas pasan al vértice plano de la escena de menús, y el pathing y las sombras del mapa anterior vuelven tal cual,
con las franjas cerradas. Doodads, unidades y script siguen siendo los de v14i: las coordenadas del mundo no cambian.
Excepción: los doodads especiales del final de war3map.doo (piezas de acantilado: dos rampas y la cueva YCr2) se guardan
por casilla desde la esquina oeste, así que se corren LADO casillas; sin eso la cueva quedó 6144 al oeste, sobre suelo
llano (vista en v14j, 04/11/2026).

Uso: terreno_v14j.py DIR_V14I DIR_ANCHO DIR_SALIDA (DIR_V14I con war3map.doo)
"""
from pathlib import Path
import struct, sys

viejo, ancho, sal = (Path(a) for a in sys.argv[1:4])
LADO = 48  # casillas nuevas a cada lado


def malla(b):
    p = 13
    p += 4 + struct.unpack_from('<I', b, p)[0] * 4
    p += 4 + struct.unpack_from('<I', b, p)[0] * 4
    return p + 16, *struct.unpack_from('<II', b, p)


t = (viejo / 'war3map.w3e').read_bytes()
p, ax, ay = malla(t)
modelo = t[p + (140 * ax + 72) * 7:p + (140 * ax + 72) * 7 + 7]  # (0, 8704), suelo de los menús
b = bytearray((ancho / 'war3map.w3e').read_bytes())
q, mx, my = malla(b)
assert (ax, ay, mx, my) == (129, 161, 129 + 2 * LADO, 161)
for j in range(my):
    for i in list(range(LADO)) + list(range(LADO + ax, mx)):
        o = q + (j * mx + i) * 7
        v = bytearray(modelo)
        v[3] = (v[3] & ~0x40) | (b[o + 3] & 0x40)  # marca de borde del editor
        b[o:o + 7] = v
(sal / 'war3map.w3e').write_bytes(b)

for f, cerrado in (('war3map.wpm', 206), ('war3map.shd', 0)):
    v = (viejo / f).read_bytes()
    w = bytearray((ancho / f).read_bytes())
    c = 16 if f.endswith('wpm') else 0
    vx, wx = 4 * (ax - 1), 4 * (mx - 1)
    filas = (len(v) - c) // vx
    assert filas == (len(w) - c) // wx == 4 * (ay - 1)
    for j in range(filas):
        w[c + j * wx:c + (j + 1) * wx] = bytes([cerrado]) * (4 * LADO) + v[c + j * vx:c + (j + 1) * vx] + bytes([cerrado]) * (4 * LADO)
    (sal / f).write_bytes(w)


# Del w3i sólo cambian los límites de cámara y el área jugable.
def campo(i):
    q = 12
    for _ in range(4):
        q = i.index(b'\0', q) + 1
    return q


i = bytearray((viejo / 'war3map.w3i').read_bytes())
a = (ancho / 'war3map.w3i').read_bytes()
i[campo(i):campo(i) + 56] = a[campo(a):campo(a) + 56]
(sal / 'war3map.w3i').write_bytes(i)


# Doodads especiales: versión, número y por cada uno id, z, x e y en casillas, al final del archivo.
d = bytearray((viejo / 'war3map.doo').read_bytes())
for k in range(1, 64):
    q = len(d) - 16 * k - 8
    if q > 0 and struct.unpack_from('<II', d, q) == (0, k):
        break
else:
    raise SystemExit('no encuentro los doodads especiales')
for j in range(k):
    o = q + 8 + 16 * j + 8
    struct.pack_into('<i', d, o, struct.unpack_from('<i', d, o)[0] + LADO)
(sal / 'war3map.doo').write_bytes(d)
