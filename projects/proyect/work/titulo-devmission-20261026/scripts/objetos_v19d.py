#!/usr/bin/env python3
"""v19d (19/11/2026): las copias de D.O.N lanzan sin espera (Leon: "deben ejecutar rapidamente la habilidad").
- w3u: 'hCpG', 'hCpF', 'hCpT', 'hCpN', 'hCpK' con punto de lanzamiento (ucpt) y retroceso (ucbs) a 0, como los héroes
  de D.O.N; 'otau' traía los suyos.
- w3a sin cambios.
Uso: objetos_v19d.py DIR_ENTRADA (w3u de v19c) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
R = lambda v: struct.pack('<f', v)

b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
hechos = set()
for base, rid, mods in tablas[1]:
    if rid in (b'hCpG', b'hCpF', b'hCpT', b'hCpN', b'hCpK'):
        assert not any(m[0] in (b'ucpt', b'ucbs') for m in mods), rid
        mods.append((b'ucpt', 2, R(0.), b'\0\0\0\0'))
        mods.append((b'ucbs', 2, R(0.), b'\0\0\0\0'))
        hechos.add(rid)
assert len(hechos) == 5, hechos
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3u v19d: ucpt/ucbs 0 en hCpG, hCpF, hCpT, hCpN, hCpK')
