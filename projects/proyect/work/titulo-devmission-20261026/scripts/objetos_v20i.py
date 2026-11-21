#!/usr/bin/env python3
"""v20i-prueba (20/11/2026): modelos del cuadro MVP que miran de frente a la cámara, como el retrato de las rachas.
- w3u: una copia por personaje con war3mapImported\\MvpFrente<Nombre>.mdl (mvp_frente.cjs: hueso billboard en los
  pies, capas sin sombra ni niebla) y sin habilidades de objeto (uabi vacío).
- imp: los siete MDX.
Uso: objetos_v20i.py DIR_ENTRADA (w3u e imp de v20h-prueba) DIR_SALIDA
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
TIPOS = [('h005', 'hMf0', 'Tauren'), ('h006', 'hMf1', 'Cairne'), ('hGok', 'hMf2', 'Goku'), ('hFrz', 'hMf3', 'Freezer'),
         ('hTrk', 'hMf4', 'Trunks'), ('hNar', 'hMf5', 'Naruto'), ('hNaK', 'hMf6', 'Kyuubi')]

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b, 'w3u: ida y vuelta distinta'
existentes = {r[1] for t in tablas for r in t}
for base_id, rid, nom in TIPOS:
    assert rid.encode() not in existentes, rid
    base = next(r for r in tablas[1] if r[1] == base_id.encode())
    nuevo = {b'umdl': f'war3mapImported\\MvpFrente{nom}.mdl'.encode(), b'unam': f'{nom} MVP'.encode(), b'uabi': b''}
    mods = [(m, t, nuevo.get(m, v), rid.encode()) for m, t, v, _ in base[2]]
    for m, v in nuevo.items():
        if not any(x[0] == m for x in mods):
            mods.append((m, 3, v, rid.encode()))
    tablas[1].append((base[0], rid.encode(), mods))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))

imp = (src / 'war3map.imp').read_bytes()
iv, n = struct.unpack_from('<II', imp, 0)
assert iv == 1
i, ent = 8, []
for _ in range(n):
    j = imp.index(b'\0', i + 1)
    ent.append((imp[i], imp[i + 1:j].decode('utf-8')))
    i = j + 1
assert i == len(imp)
for _, _, nom in TIPOS:
    p = f'war3mapImported\\MvpFrente{nom}.mdx'
    assert all(e[1] != p for e in ent), p
    ent.append((13, p))
(dst / 'war3map.imp').write_bytes(struct.pack('<II', 1, len(ent)) + b''.join(bytes([f]) + p.encode() + b'\0' for f, p in ent))
print('w3u v20i:', ' '.join(r for _, r, _ in TIPOS), '; imp', n, '->', len(ent))
