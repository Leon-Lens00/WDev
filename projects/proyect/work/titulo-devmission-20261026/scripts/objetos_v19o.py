#!/usr/bin/env python3
"""v19o (19/11/2026): cartas con ventana de la tienda y contorno de los indicadores.
- w3b: DS1S CuaCarta (texturas_v19o.py) con su import.
- imp: war3mapImported\\CuaAroAzul.mdx y CuaAroRojo.mdx (aro_v19o.py + mdx_sin_billboard.py).
- w3u: 'ubjA' y 'ubjR', copias de 'ubjt' (la esfera de la tienda) con esos modelos.
Uso: objetos_v19o.py DIR_ENTRADA (w3u, w3b e imp de v19n) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DS1S', 'CuaCarta')],
              ['war3mapImported\\CuaCarta.blp', 'war3mapImported\\CuaAroAzul.mdx', 'war3mapImported\\CuaAroRojo.mdx'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
usados = {r[1] for t in tablas for r in t}
base, _, mods = next(r for r in tablas[1] if r[1] == b'ubjt')
assert sum(m[0] == b'umdl' for m in mods) == 1
for rid, mdl in ((b'ubjA', b'war3mapImported\\CuaAroAzul.mdx'), (b'ubjR', b'war3mapImported\\CuaAroRojo.mdx')):
    assert rid not in usados, rid
    tablas[1].append((base, rid, [(m[0], m[1], mdl if m[0] == b'umdl' else m[2], m[3]) for m in mods]))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3b v19o: DS1S; imp +3; w3u: ubjA ubjR')
