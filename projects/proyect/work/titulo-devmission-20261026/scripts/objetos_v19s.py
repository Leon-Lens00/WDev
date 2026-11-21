#!/usr/bin/env python3
"""v19s (19/11/2026): fuera las burbujas de los paneles de mejoras (Leon: "quitales el contorno de brillo de los dos
cuadros de la izquierda como derecha").
- w3u: fuera 'ubjP' y 'ubjD'.
- imp: fuera war3mapImported\\CuaBurbujaPan.mdx y CuaBurbujaDet.mdx.
Uso: objetos_v19s.py DIR_ENTRADA (w3u e imp de v19r) DIR_SALIDA
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
FUERA = ['war3mapImported\\CuaBurbujaPan.mdx', 'war3mapImported\\CuaBurbujaDet.mdx']

imp = (src / 'war3map.imp').read_bytes()
iv, n = struct.unpack_from('<II', imp, 0)
assert iv == 1
i, ent = 8, []
for _ in range(n):
    j = imp.index(b'\0', i + 1)
    ent.append((imp[i], imp[i + 1:j].decode('utf-8')))
    i = j + 1
assert i == len(imp)
nombres = [p for _, p in ent]
assert all(nombres.count(p) == 1 for p in FUERA)
ent = [e for e in ent if e[1] not in FUERA]
(dst / 'war3map.imp').write_bytes(struct.pack('<II', 1, len(ent)) + b''.join(bytes([f]) + p.encode() + b'\0' for f, p in ent))

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
antes = len(tablas[1])
tablas[1] = [r for r in tablas[1] if r[1] not in (b'ubjP', b'ubjD')]
assert len(tablas[1]) == antes - 2
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('imp', n, '->', len(ent), '; w3u: -ubjP -ubjD')
