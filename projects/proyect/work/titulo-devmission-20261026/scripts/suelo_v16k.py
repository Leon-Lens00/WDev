#!/usr/bin/env python3
"""v16k (08/11/2026): suelo del tutorial en azul celeste pastel, para que resalte el foco negro.
SueloAzur.mdx es TitlePlano.mdx (plano de 4096 x 4096 a z 2) con la textura war3mapImported\\SueloAzur.blp, un BLP1
de paleta de 8 x 8 de un solo color (180, 220, 245) con mipmaps hasta 1 x 1. Añade los dos al war3map.imp (flag 13).
Uso: suelo_v16k.py TitlePlano.mdx war3map.imp(base) DIR_MODELOS DIR_IMP
"""
from pathlib import Path
import struct, sys

COLOR = (180, 220, 245)
mdx, imp, dmod, dimp = (Path(a) for a in sys.argv[1:5])
dmod.mkdir(parents=True, exist_ok=True)
dimp.mkdir(parents=True, exist_ok=True)

d = bytearray(mdx.read_bytes())
i = d.find(b'TEXS')
n, = struct.unpack_from('<I', d, i + 4)
assert n == 268, n  # una sola textura: id reemplazable, ruta de 260, dos enteros
viejo = b'war3mapImported\\NegroSolido.blp'
assert bytes(d[i + 12:i + 12 + len(viejo)]) == viejo
nuevo = b'war3mapImported\\SueloAzur.blp'
d[i + 12:i + 12 + 260] = nuevo + b'\0' * (260 - len(nuevo))
(dmod / 'SueloAzur.mdx').write_bytes(bytes(d))

r, g, b = COLOR
niveles = [bytes(s * s) for s in (8, 4, 2, 1)]
offs, p = [], 156 + 1024
for nv in niveles:
    offs.append(p)
    p += len(nv)
head = b'BLP1' + struct.pack('<6I', 1, 0, 8, 8, 5, 1)
head += struct.pack('<16I', *(offs + [0] * (16 - len(offs))))
head += struct.pack('<16I', *([len(nv) for nv in niveles] + [0] * (16 - len(niveles))))
pal = bytes((b, g, r, 0)) + bytes(4 * 255)
(dmod / 'SueloAzur.blp').write_bytes(head + pal + b''.join(niveles))

e = imp.read_bytes()
v, cnt = struct.unpack_from('<ii', e, 0)
rutas = [b'war3mapImported\\SueloAzur.mdx', b'war3mapImported\\SueloAzur.blp']
for ru in rutas:
    assert b'\x0d' + ru + b'\0' not in e, ru
extra = b''.join(b'\x0d' + ru + b'\0' for ru in rutas)
(dimp / 'war3map.imp').write_bytes(struct.pack('<ii', v, cnt + len(rutas)) + e[8:] + extra)
print('SueloAzur', COLOR)
