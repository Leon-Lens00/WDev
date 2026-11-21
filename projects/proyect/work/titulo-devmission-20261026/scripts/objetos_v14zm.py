#!/usr/bin/env python3
"""Objetos de v14zm (07/11/2026): 12 unidades ficticias para los efectos del cuchillo, copias de 'h00S' (Locust y
vuelo, sin colisión, sombra ni ataque) con otro modelo y nombre:
  'hkA1'..'hkA6': war3mapImported\\CullingCleave1..6.mdx (golpe A, por delante; tier 1..6)
  'hkB1'..'hkB6': war3mapImported\\CullingSlash1..6.mdx (golpe B, área)
Falla si alguno ya existe. Lo demás del w3u queda igual.
Uso: objetos_v14zm.py ENTRADA.w3u SALIDA.w3u (war3map.w3u de v14zl)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse

ent, sal = Path(sys.argv[1]), Path(sys.argv[2])
b = ent.read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
base, _, plantilla = next(r for r in tablas[1] if r[1] == b'h00S')
assert any(m[0] == b'uabi' and m[2] == b'Aloc,Amrf' for m in plantilla)
usados = {r[0] if n == 0 else r[1] for n, t in enumerate(tablas) for r in t}
nuevos = []
for letra, modelo in (('A', 'CullingCleave'), ('B', 'CullingSlash')):
    for t in range(1, 7):
        rid = f'hk{letra}{t}'.encode()
        assert rid not in usados, rid
        mods = []
        for m in plantilla:
            if m[0] == b'umdl':
                m = (m[0], m[1], f'war3mapImported\\{modelo}{t}.mdx'.encode(), m[3])
            elif m[0] == b'unam':
                m = (m[0], m[1], f'{modelo}{t}'.encode(), m[3])
            mods.append(m)
        tablas[1].append((base, rid, mods))
        nuevos.append(rid.decode())
salida = encode(version, tablas)
assert encode(*parse(salida)) == salida
sal.write_bytes(salida)
print('w3u:', ' '.join(nuevos))
