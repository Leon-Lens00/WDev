#!/usr/bin/env python3
"""v20h-prueba (20/11/2026): Tauren inclinado hacia atrás para el cuadro MVP, para elegir el ángulo en la partida.
- w3u: 'hMv2' 'hMv3' 'hMv4' 'hMv5', copias de 'h005' (Tauren) con war3mapImported\\MvpTauren25/35/45/55.mdl y sin
  habilidades de objeto (uabi vacío: sólo es un modelo del cuadro).
- imp: los cuatro MDX (generados con inclinar_mvp.cjs desde Units\\Orc\\Tauren\\Tauren.mdx de war3.mpq).
Uso: objetos_v20h.py DIR_ENTRADA (w3u e imp de v20f-prueba) DIR_SALIDA
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
TIPOS = [('hMv2', 25), ('hMv3', 35), ('hMv4', 45), ('hMv5', 55)]

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b, 'w3u: ida y vuelta distinta'
base = next(r for r in tablas[1] if r[1] == b'h005')
existentes = {r[1] for t in tablas for r in t}
for rid, g in TIPOS:
    assert rid.encode() not in existentes, rid
    nuevo = {b'umdl': f'war3mapImported\\MvpTauren{g}.mdl'.encode(), b'unam': f'Tauren MVP {g}'.encode(), b'uabi': b''}
    mods = [(m, t, nuevo.get(m, v), rid.encode()) for m, t, v, _ in base[2]]
    if not any(m[0] == b'uabi' for m in mods):
        mods.append((b'uabi', 3, b'', rid.encode()))
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
for _, g in TIPOS:
    p = f'war3mapImported\\MvpTauren{g}.mdx'
    assert all(e[1] != p for e in ent), p
    ent.append((13, p))
(dst / 'war3map.imp').write_bytes(struct.pack('<II', 1, len(ent)) + b''.join(bytes([f]) + p.encode() + b'\0' for f, p in ent))
print('w3u v20h:', ' '.join(r for r, _ in TIPOS), '; imp', n, '->', len(ent))
