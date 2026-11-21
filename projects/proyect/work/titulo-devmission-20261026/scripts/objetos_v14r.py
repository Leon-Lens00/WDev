#!/usr/bin/env python3
"""Objetos de v14r: la unidad 'h00S' (StormDummy) de Storm v1.3.1, copia de la 'h000' (Ldummy) de su mapa de ejemplo.

Locust y vuelo, sin colisión ni ataque, modelo war3mapImported\\StormDummy.mdx (Ldummy.mdx: 180 animaciones). El nombre
pasa a texto plano (en el ejemplo era una cadena del wts). Falla si 'h00S' ya existe.

Uso: objetos_v14r.py EJEMPLO_W3U DIR_ENTRADA DIR_SALIDA (war3map.w3u)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

ejemplo, src, dst = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
dst.mkdir(exist_ok=True)

_, ej = parse(ejemplo.read_bytes())
fila = next(r for r in ej[1] if r[1] == b'h000')
mods = []
for m in fila[2]:
    if m[0] == b'unam':
        m = (m[0], m[1], b'StormDummy', m[3])
    elif m[0] == b'umdl':
        m = (m[0], m[1], b'war3mapImported\\StormDummy.mdx', m[3])
    mods.append(m)
assert any(m[0] == b'uabi' and m[2] == b'Aloc,Amrf' for m in mods)

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
assert all(r[1] != b'h00S' for t in tablas for r in t)
tablas[1].append((b'hfoo', b'h00S', mods))
salida = encode(version, tablas)
assert encode(*parse(salida)) == salida
(dst / 'war3map.w3u').write_bytes(salida)
print('w3u: h00S StormDummy con', len(mods), 'campos')
