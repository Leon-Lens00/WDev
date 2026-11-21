#!/usr/bin/env python3
"""Objetos de v14s: la unidad 'h00S' de v14r pasa a llamarse StormLuz y a usar war3mapImported\\StormLuz.mdx (Ldummy con
la luz direccional dentro). El resto de campos sigue igual.

Uso: objetos_v14s.py DIR_ENTRADA DIR_SALIDA (war3map.w3u de v14r)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
i, fila = next((i, r) for i, r in enumerate(tablas[1]) if r[1] == b'h00S')
mods = []
for m in fila[2]:
    if m[0] == b'unam':
        assert m[2] == b'StormDummy'
        m = (m[0], m[1], b'StormLuz', m[3])
    elif m[0] == b'umdl':
        assert m[2] == b'war3mapImported\\StormDummy.mdx'
        m = (m[0], m[1], b'war3mapImported\\StormLuz.mdx', m[3])
    mods.append(m)
tablas[1][i] = (fila[0], fila[1], mods)
salida = encode(version, tablas)
assert encode(*parse(salida)) == salida
(dst / 'war3map.w3u').write_bytes(salida)
print('w3u: h00S StormLuz')
