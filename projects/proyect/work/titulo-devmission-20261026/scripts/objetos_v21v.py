#!/usr/bin/env python3
"""v21v (22/11/2026): X de Trunks (puente ATr1, Power Up) con 10 s de enfriamiento y sin maná, como la X de Goku (AGk4).
En 2.1a/v21s el puente traía 30 s y 50 de maná.
Uso: objetos_v21v.py ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

ver, tabs = parse_w3a(Path(sys.argv[1]).read_bytes())
hecho = 0
for t in tabs:
    for k, (base, nid, mods) in enumerate(t):
        if nid != b'ATr1':
            continue
        n = {b'acdn': 0, b'amcs': 0}
        for i, m in enumerate(mods):
            if m[0] == b'acdn':
                assert struct.unpack('<f', m[4])[0] == 30., m
                mods[i] = m[:4] + (struct.pack('<f', 10.),) + m[5:]
                n[m[0]] += 1
            elif m[0] == b'amcs':
                assert struct.unpack('<i', m[4])[0] == 50, m
                mods[i] = m[:4] + (struct.pack('<i', 0),) + m[5:]
                n[m[0]] += 1
        assert n == {b'acdn': 1, b'amcs': 1}, n
        t[k] = (base, nid, mods)
        hecho += 1
assert hecho == 1, hecho
Path(sys.argv[2]).write_bytes(encode_w3a(ver, tabs))
print('v21v: ATr1 10 s sin maná')
