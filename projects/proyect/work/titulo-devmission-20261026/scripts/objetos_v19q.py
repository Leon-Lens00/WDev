#!/usr/bin/env python3
"""v19q (19/11/2026): fuera la burbuja gris de las cartas cerradas; burbuja de la cabecera.
- w3u: fuera 'ubjG'; nueva 'ubjC', copia de 'ubjt' (la esfera de la tienda) con war3mapImported\\CuaBurbujaCab.mdx.
- imp: fuera CuaBurbujaGris.mdx; nuevo CuaBurbujaCab.mdx (flag 13 como los demás). CuaBurbuja.mdx y CuaCarta.blp
  siguen en la lista: sólo cambia su contenido.
Uso: objetos_v19q.py DIR_ENTRADA (w3u e imp de v19p) DIR_SALIDA
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
FUERA = ['war3mapImported\\CuaBurbujaGris.mdx']
NUEVOS = ['war3mapImported\\CuaBurbujaCab.mdx']
SIGUEN = ['war3mapImported\\CuaBurbuja.mdx', 'war3mapImported\\CuaCarta.blp']

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
assert all(nombres.count(p) == 1 for p in FUERA + SIGUEN) and not any(p in nombres for p in NUEVOS)
ent = [e for e in ent if e[1] not in FUERA] + [(13, p) for p in NUEVOS]
(dst / 'war3map.imp').write_bytes(struct.pack('<II', 1, len(ent)) + b''.join(bytes([f]) + p.encode() + b'\0' for f, p in ent))

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
antes = len(tablas[1])
tablas[1] = [r for r in tablas[1] if r[1] != b'ubjG']
assert len(tablas[1]) == antes - 1
usados = {r[1] for t in tablas for r in t}
base, _, mods = next(r for r in tablas[1] if r[1] == b'ubjt')
assert sum(m[0] == b'umdl' for m in mods) == 1
rid, mdl = b'ubjC', b'war3mapImported\\CuaBurbujaCab.mdx'
assert rid not in usados, rid
tablas[1].append((base, rid, [(m[0], m[1], mdl if m[0] == b'umdl' else m[2], m[3]) for m in mods]))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('imp', n, '->', len(ent), '; w3u: -ubjG +ubjC')
