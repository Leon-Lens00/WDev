#!/usr/bin/env python3
"""Objetos e imports de la barra del jefe, v17m (14/11/2026).

- unidades 'hbk2'..'hbkA', copias de la barra derecha 'hbet' con sólo el modelo y el nombre cambiados:
  UI\\HealthBarsHorizontal\\HealthJefe{n}.mdx (jefe_barras_v17m.py);
- imports: los 9 MDX (marca 13, ruta propia). Falla si un id o una ruta ya existe.
Uso: objetos_v17m.py IN_W3U OUT_W3U IN_IMP OUT_IMP
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

RONDAS = '23456789A'
UNITS = {f'hbk{c}': f'UI\\HealthBarsHorizontal\\HealthJefe{c}.mdx' for c in RONDAS}

src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src
used = {new for t in tables for _, new, _ in t}
base, _, mods = next(r for r in tables[1] if r[1] == b'hbet')
assert any(mid == b'umdl' for mid, _, _, _ in mods) and any(mid == b'unam' for mid, _, _, _ in mods)
for rid, model in UNITS.items():
    assert rid.encode() not in used, rid
    nuevos = []
    for mid, ty, v, end in mods:
        if mid == b'umdl':
            v = model.encode()
        elif mid == b'unam':
            v = f'Boss health bar {rid[3]}'.encode()
        nuevos.append((mid, ty, v, end))
    tables[1].append((base, rid.encode(), nuevos))
Path(sys.argv[2]).write_bytes(encode(version, tables))

imp = Path(sys.argv[3]).read_bytes()
iv, n = struct.unpack_from('<II', imp, 0)
assert iv == 1
i, names = 8, []
for _ in range(n):
    j = imp.index(b'\0', i + 1)
    names.append(imp[i + 1:j].decode('utf-8'))
    i = j + 1
assert i == len(imp)
for p in UNITS.values():
    assert p not in names, p
extra = b''.join(bytes([13]) + p.encode() + b'\0' for p in UNITS.values())
Path(sys.argv[4]).write_bytes(struct.pack('<II', 1, n + len(UNITS)) + imp[8:] + extra)
print(json.dumps({'units': list(UNITS), 'imports': n + len(UNITS)}))
