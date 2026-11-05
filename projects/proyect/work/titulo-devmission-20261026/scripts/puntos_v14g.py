#!/usr/bin/env python3
"""Mapa editable de puntos sobre el terreno de v14g: Swamped-Ampliar con el terreno, pathing, sombras y doodads de
v14g, los 98 marcadores 'nPto' y dos tipos nuevos de marcador en el centro, uno de cada:

- 'nPtA' "Punto nuevo A" (tinte rojo) y 'nPtB' "Punto nuevo B" (tinte verde), copias de 'nPto' (base 'ncop').

Su uso lo decide el usuario según dónde los coloque. Un mapa guardado por el editor sólo aporta posiciones.
Uso: puntos_v14g.py DIR_AMPLIAR DIR_V14G DIR_SALIDA
"""
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puntos_editor_v13b import CENTRO, registros
from w3b_titulo import parse, encode

NUEVOS = [(b'nPtA', 'Punto nuevo A', (255, 64, 64), -128.), (b'nPtB', 'Punto nuevo B', (64, 255, 64), 128.)]

amp, v14g, out = (Path(a) for a in sys.argv[1:4])
out.mkdir(exist_ok=True)

version, tablas = parse((amp / 'war3map.w3u').read_bytes())
assert [r[1] for r in tablas[1]] == [b'nPto'], [r[1] for r in tablas[1]]
base = tablas[1][0][0]
for rid, nombre, (r, g, b), _ in NUEVOS:
    tablas[1].append((base, rid, [(b'unam', 3, nombre.encode(), b'\0\0\0\0')] +
                      [(m, 0, struct.pack('<i', c), b'\0\0\0\0') for m, c in ((b'uclr', r), (b'uclg', g), (b'uclb', b))]))
(out / 'war3map.w3u').write_bytes(encode(version, tablas))

u = (amp / 'war3mapUnits.doo').read_bytes()
rs = list(registros(u))
modelo = next(u[a:c] for a, c in rs if u[a:a + 4] == b'nPto')
ident = max(struct.unpack_from('<I', u, c - 4)[0] for _, c in rs) + 1
filas = [u[a:c] for a, c in rs]
for k, (rid, _, _, dx) in enumerate(NUEVOS):
    f = bytearray(modelo)
    f[:4] = rid
    struct.pack_into('<fff', f, 8, CENTRO[0] + dx, CENTRO[1], 0.)
    struct.pack_into('<I', f, len(f) - 4, ident + k)
    filas.append(bytes(f))
(out / 'war3mapUnits.doo').write_bytes(u[:12] + struct.pack('<I', len(filas)) + b''.join(filas))

for f in ('war3map.w3e', 'war3map.wpm', 'war3map.shd', 'war3map.doo'):
    (out / f).write_bytes((v14g / f).read_bytes())
