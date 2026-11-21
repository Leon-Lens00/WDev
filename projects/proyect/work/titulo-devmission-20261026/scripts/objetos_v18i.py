#!/usr/bin/env python3
"""v18i (15/11/2026): bolsas de oro más grandes. En la grabación de v18h se veían muy pequeñas desde la cámara de
juego. 'nbg0' 1,2 -> 2,0; 'nbg1' 1,7 -> 2,8; 'nbg2' (cofre) 1,0 -> 2,0. Sólo cambia 'usca' de esas tres en el w3u.
Uso: objetos_v18i.py DIR_ENTRADA (w3u de v18h) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
ESC = {b'nbg0': (1.2, 2.0), b'nbg1': (1.7, 2.8), b'nbg2': (1.0, 2.0)}
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
hechos = set()
for k, (base, rid, mods) in enumerate(tablas[1]):
    if rid in ESC:
        antes, nuevo = ESC[rid]
        i = next(n for n, x in enumerate(mods) if x[0] == b'usca')
        assert abs(struct.unpack('<f', mods[i][2])[0] - antes) < 1e-6, rid
        mods[i] = (b'usca', 1, struct.pack('<f', nuevo), mods[i][3])
        hechos.add(rid)
assert hechos == set(ESC)
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3u: escalas de las bolsas', {k.decode(): v[1] for k, v in ESC.items()})
