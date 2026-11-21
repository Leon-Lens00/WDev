#!/usr/bin/env python3
"""v19m (19/11/2026): acabado de los cuadros (sólo war3map.w3b y war3map.imp).
- DS1P CuaBanda, DS1Q CuaMarco, DS1R CuaCabecera (texturas_v19m.py) con sus imports war3mapImported\\*.blp.
- DM08: icono de la carta Purga (BTNDispelMagic), copia de D000 como DM00..DM07.
Uso: objetos_v19m.py DIR_ENTRADA (w3b e imp de v19l) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
T = [('DS1P', 'CuaBanda'), ('DS1Q', 'CuaMarco'), ('DS1R', 'CuaCabecera')]
w3b_modos.add(T, [f'war3mapImported\\{n}.blp' for _, n in T],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
b = (dst / 'war3map.w3b').read_bytes()
version, tables = parse(b)
assert encode(version, tables) == b
assert b'DM08' not in {r[1] for t in tables for r in t}
template = next(r for r in tables[1] if r[1] == b'D000')
mods = []
for mid, ty, v, _ in template[2]:
    if mid == b'btxf':
        v = b'ReplaceableTextures\\CommandButtons\\BTNDispelMagic.blp'
    elif mid == b'bnam':
        v = b'Carta Purga'
    mods.append((mid, ty, v, b'DM08'))
tables[1].append((b'ATtc', b'DM08', mods))
(dst / 'war3map.w3b').write_bytes(encode(version, tables))
print('w3b v19m: DS1P DS1Q DS1R DM08; imp +3')
