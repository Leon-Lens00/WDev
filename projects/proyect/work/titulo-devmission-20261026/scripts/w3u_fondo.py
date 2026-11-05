"""Add the title's nebula background dummy to war3map.w3u (Dev Mission title v6, 27/10/2026).

'uidn' copies every field of the UI system's 'uidm' ('ewsp' based, float, no collision) and changes only the
model to NebulaV8\\Nebula_PlusZ.mdx, the user's animated nebula storm (ModelEditor tormenta-nebula-v8): a
flat XY plane facing +Z, 2320 x 1400, one 48 s Stand loop. A unit instead of a special effect because 1.27b
cannot turn an effect and the plane's long side must lie along screen x (world +Y with camera rotation 180),
so it is created facing 90. Same layout as w3u_titulo.py; fails if 'uidn' is already used.

Usage: w3u_fondo.py IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

MODEL = b'NebulaV8\\Nebula_PlusZ.mdx'

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'uidn' for t in tables for _, new, _ in t), 'uidn exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    new = [(mid, ty, MODEL if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
    assert sum(m[0] == b'umdl' for m in new) == 1
    tables[1].append((base, b'uidn', new))
    out = encode(version, tables)
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'added': 'uidn', 'base': base.decode(), 'fields': len(new), 'custom': len(tables[1]),
                      'bytes': len(out)}))
