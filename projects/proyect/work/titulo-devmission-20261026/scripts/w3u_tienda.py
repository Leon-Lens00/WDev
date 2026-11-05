#!/usr/bin/env python3
"""v14e: 'uids', copia de 'uidb' con war3mapImported\\TitleDummyFlat.mdl, sólo para las piezas de la tienda.

'uidb' sigue con su modelo billboard para el título, los menús y los iconos del HUD de juego. Falla si 'uids' existe.

Uso: w3u_tienda.py IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

MODEL = b'war3mapImported\\TitleDummyFlat.mdl'

src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
assert all(new != b'uids' for t in tables for _, new, _ in t), 'uids exists'
base, _, mods = next(r for r in tables[1] if r[1] == b'uidb')
new = [(mid, ty, MODEL if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
assert sum(m[0] == b'umdl' for m in new) == 1
tables[1].append((base, b'uids', new))
out = encode(version, tables)
Path(sys.argv[2]).write_bytes(out)
print(json.dumps({'added': 'uids', 'base': base.decode(), 'fields': len(new), 'custom': len(tables[1]), 'bytes': len(out)}))
