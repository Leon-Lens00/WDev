#!/usr/bin/env python3
"""Objetos de v16a (08/11/2026), tutorial: destructibles de textura 'DS1A' TutFoco, 'DS1B' TutPanel, 'DS1C' TutMano,
'DS1D' TutMira (con sus imports) y 'DS1E' con el icono del Disparo del juego (BTNFireBolt, sin import).
Uso: objetos_v16a.py DIR_ENTRADA DIR_SALIDA (w3b e imp del mapa v14zy)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
nombres = [('DS1A', 'TutFoco'), ('DS1B', 'TutPanel'), ('DS1C', 'TutMano'), ('DS1D', 'TutMira')]
w3b_modos.add(nombres + [('DS1E', 'TutIconoA')], [f'war3mapImported\\{n}.blp' for _, n in nombres],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
version, tablas = parse((dst / 'war3map.w3b').read_bytes())
n = 0
for i, (base, nuevo, mods) in enumerate(tablas[1]):
    if nuevo == b'DS1E':
        tablas[1][i] = (base, nuevo, [(m, t, b'ReplaceableTextures\\CommandButtons\\BTNFireBolt.blp' if m == b'btxf' else v, o)
                                      for m, t, v, o in mods])
        n += 1
assert n == 1
(dst / 'war3map.w3b').write_bytes(encode(version, tablas))
print('DS1E -> BTNFireBolt')
