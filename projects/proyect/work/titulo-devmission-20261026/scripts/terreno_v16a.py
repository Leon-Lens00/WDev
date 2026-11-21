#!/usr/bin/env python3
"""Terreno del tutorial v16a (08/11/2026): en la franja norte llana (altura 8518, Zvin), un recinto en
X 6000..10000, Y 7500..9500 que se puede pisar (wpm 64, como el pasillo de los menús) y un suelo de baldosas 'Ztil'
en X 6400..9600, Y 7700..9300. No toca alturas, acantilados ni agua.
Uso: terreno_v16a.py DIR_ENTRADA DIR_SALIDA (war3map.w3e y war3map.wpm)
"""
from pathlib import Path
import struct, sys

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
b = bytearray((src / 'war3map.w3e').read_bytes())
p = 13
nt = struct.unpack_from('<I', b, p)[0]
tiles = [b[p + 4 + 4 * i:p + 8 + 4 * i].decode() for i in range(nt)]
p += 4 + nt * 4
p += 4 + struct.unpack_from('<I', b, p)[0] * 4
mx, my = struct.unpack_from('<II', b, p)
ox, oy = struct.unpack_from('<ff', b, p + 8)
p += 16
til = tiles.index('Ztil')
cambios = 0
for j in range(my):
    y = oy + j * 128
    for i in range(mx):
        x = ox + i * 128
        q = p + (j * mx + i) * 7
        if 7300 <= y <= 9700 and 5800 <= x <= 10200:
            assert b[q:q + 7] == bytes.fromhex('46218e24484003'), (x, y, b[q:q + 7].hex())
            if 6400 <= x <= 9600 and 7700 <= y <= 9300:
                b[q + 4] = (b[q + 4] & 0xF0) | til
                cambios += 1
(dst / 'war3map.w3e').write_bytes(b)

w = bytearray((src / 'war3map.wpm').read_bytes())
wx, wy = struct.unpack_from('<II', w, 8)
abiertas = 0
for j in range(wy):
    y = oy + j * 32
    if not 7500 <= y < 9500:
        continue
    for i in range(wx):
        x = ox + i * 32
        if 6000 <= x < 10000:
            w[16 + j * wx + i] = 64
            abiertas += 1
(dst / 'war3map.wpm').write_bytes(w)
print('vertices Ztil', cambios, 'celdas abiertas', abiertas)
