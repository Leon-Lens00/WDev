#!/usr/bin/env python3
"""v19r (19/11/2026): paneles de mejoras en la pantalla de inicio de la tienda.
- w3b: 'DS1T' CuaPanel (340 × 310) y 'DS1U' CuaDetalle (340 × 290), de texturas_v19r.py, con sus imports.
- imp: CuaBurbujaPan.mdx y CuaBurbujaDet.mdx (burbuja_v19q.py panel|detalle) y las zonas de clic CuaHitIco.mdx
  (56 × 56) y CuaHitTab.mdx (104 × 36) de hits_v19r.cjs.
- w3u: 'ubjP' y 'ubjD', copias de 'ubjt' (la esfera de la tienda) con esas burbujas.
Uso: objetos_v19r.py DIR_ENTRADA (w3u, w3b e imp de v19q) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DS1T', 'CuaPanel'), ('DS1U', 'CuaDetalle')],
              ['war3mapImported\\CuaPanel.blp', 'war3mapImported\\CuaDetalle.blp',
               'war3mapImported\\CuaBurbujaPan.mdx', 'war3mapImported\\CuaBurbujaDet.mdx',
               'war3mapImported\\CuaHitIco.mdx', 'war3mapImported\\CuaHitTab.mdx'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
usados = {r[1] for t in tablas for r in t}
base, _, mods = next(r for r in tablas[1] if r[1] == b'ubjt')
assert sum(m[0] == b'umdl' for m in mods) == 1
for rid, mdl in ((b'ubjP', b'war3mapImported\\CuaBurbujaPan.mdx'), (b'ubjD', b'war3mapImported\\CuaBurbujaDet.mdx')):
    assert rid not in usados, rid
    tablas[1].append((base, rid, [(m[0], m[1], mdl if m[0] == b'umdl' else m[2], m[3]) for m in mods]))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3b v19r: DS1T DS1U; imp +6; w3u: ubjP ubjD')
