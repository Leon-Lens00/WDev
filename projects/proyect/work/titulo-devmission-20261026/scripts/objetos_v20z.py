#!/usr/bin/env python3
"""v20z (21/11/2026): las piezas del cuadro MVP pasan a ser copias de la pieza de retrato 'dta0' (base ewsp, movimiento
float, sin colisión ni sombra, Aloc/Avul), como los retratos de las rachas, con su modelo MvpFrente<Nombre>.mdl.
Antes eran copias de los personajes (pie, colisión 1, ShadowFlyer): en terreno con niveles el modelo bajaba y se salía
del cuadro. Mismos ids hMf0-6 y misma posición en la tabla.
Uso: objetos_v20z.py IN_W3U OUT_W3U
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

TIPOS = {b'hMf0': 'Tauren', b'hMf1': 'Cairne', b'hMf2': 'Goku', b'hMf3': 'Freezer', b'hMf4': 'Trunks',
         b'hMf5': 'Naruto', b'hMf6': 'Kyuubi'}
src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
base, _, mods = next(r for r in tables[1] if r[1] == b'dta0')
assert any(m == b'umdl' for m, _, _, _ in mods) and any(m == b'unam' for m, _, _, _ in mods)
hechos = 0
for i, r in enumerate(tables[1]):
    nom = TIPOS.get(r[1])
    if nom is None:
        continue
    nuevo = {b'umdl': f'war3mapImported\\MvpFrente{nom}.mdl'.encode(), b'unam': f'{nom} MVP'.encode()}
    tables[1][i] = (base, r[1], [(m, t, nuevo.get(m, v), r[1]) for m, t, v, _ in mods])
    hechos += 1
assert hechos == len(TIPOS), hechos
Path(sys.argv[2]).write_bytes(encode(version, tables))
print('w3u v20z:', hechos, 'piezas MVP sobre dta0')
