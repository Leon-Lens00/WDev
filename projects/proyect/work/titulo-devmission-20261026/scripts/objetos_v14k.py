#!/usr/bin/env python3
"""Objetos de v14k (tienda, 04/11/2026): tres copias de la unidad de retrato 'dta0' para la tienda, con retratos sin
billboard (scripts/retrato_sin_billboard.cjs; lejos de X 0 el billboard los deja de canto y no se ven):
'dgo0' golem (retrato_golem.cjs), 'dts0' Tauren y 'dcs0' Cairne (los del título). Falla si algún id ya existe.

Uso: objetos_v14k.py IN_W3U OUT_W3U
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

NUEVAS = [(b'dgo0', 'war3mapImported\\RetratoGolem.mdx', b'Shop portrait Golem'),
          (b'dts0', 'war3mapImported\\RetratoTauren.mdx', b'Shop portrait Tauren'),
          (b'dcs0', 'war3mapImported\\RetratoCairne.mdx', b'Shop portrait Cairne')]
src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
usados = {new for t in tables for _, new, _ in t}
base, _, mods = next(r for r in tables[1] if r[1] == b'dta0')
assert any(m == b'umdl' for m, _, _, _ in mods)
for rid, model, nombre in NUEVAS:
    assert rid not in usados, rid
    tables[1].append((base, rid, [(m, t, model.encode() if m == b'umdl' else nombre if m == b'unam' else v, e)
                                  for m, t, v, e in mods]))
Path(sys.argv[2]).write_bytes(encode(version, tables))
print('ok', [r.decode() for r, _, _ in NUEVAS])
