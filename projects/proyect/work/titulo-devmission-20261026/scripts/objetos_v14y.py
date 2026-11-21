#!/usr/bin/env python3
"""w3u de v14y: el personaje (h005) y su variante (h006) ven 1100 de día y de noche, antes 300. El resto, como v14s.
Uso: objetos_v14y.py ENTRADA.w3u SALIDA.w3u"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

SIGHT = 1100
version, tables = parse(Path(sys.argv[1]).read_bytes())
n = 0
for r in tables[1]:
    if r[1] in (b'h005', b'h006'):
        assert sum(m[0] in (b'usid', b'usin') for m in r[2]) == 2, r[1]
        r[2][:] = [(m[0], m[1], struct.pack('<i', SIGHT), m[3]) if m[0] in (b'usid', b'usin') else m for m in r[2]]
        n += 1
assert n == 2, n
Path(sys.argv[2]).write_bytes(encode(version, tables))
print('ok')
