#!/usr/bin/env python3
"""Objetos de v16c (08/11/2026), consola del tutorial: 'DS1F' TutCasilla (import) y los iconos de las habilidades
base como destructibles de textura: 'DS1G' BTNBootsOfSpeed (Dash) y 'DS1H' BTNManaRecharge (Recargar), del juego;
'DS1I'..'DS1N' BTNArma1..6 (ya importados en el mapa).
Uso: objetos_v16c.py DIR_ENTRADA DIR_SALIDA (w3b e imp del mapa v16b)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
nuevos = [('DS1F', 'TutCasilla'), ('DS1G', 'TutDash'), ('DS1H', 'TutRecargar')] + [(f'DS1{c}', f'BTNArma{i + 1}') for i, c in enumerate('IJKLMN')]
w3b_modos.add(nuevos, ['war3mapImported\\TutCasilla.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
juego = {b'DS1G': b'ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp',
         b'DS1H': b'ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp'}
version, tablas = parse((dst / 'war3map.w3b').read_bytes())
n = 0
for i, (base, nuevo, mods) in enumerate(tablas[1]):
    if nuevo in juego:
        tablas[1][i] = (base, nuevo, [(m, t, juego[nuevo] if m == b'btxf' else v, o) for m, t, v, o in mods])
        n += 1
assert n == 2
(dst / 'war3map.w3b').write_bytes(encode(version, tablas))
print('DS1G, DS1H -> iconos del juego')
