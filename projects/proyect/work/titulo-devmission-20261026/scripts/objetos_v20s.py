#!/usr/bin/env python3
"""v20s (20/11/2026), fase 2 del rework: el Power Up de Freezer (A0IZ, Berserk) y el Finish Sign de Trunks (A0I5,
Roar) duran hasta el final de la wave. Los lanza el script al llegar a las muertes; la duración del nivel 1 pasa de
30 s / 15 s a 3600 s y el script quita el buff (B04B / B03N) al terminar la wave.
Uso: objetos_v20s.py DIR_ENTRADA (w3a de v20r) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
R = lambda v: struct.pack('<f', v)
VIEJA = {b'A0IZ': 30.0, b'A0I5': 15.0}
b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b, 'w3a: ida y vuelta distinta'
n = 0
for t in ta:
    for k, (base, rid, mods) in enumerate(t):
        if rid not in VIEJA:
            continue
        nuevos = []
        for mid, ty, lv, dat, v, end in mods:
            if mid in (b'adur', b'ahdu') and lv == 1:
                assert struct.unpack('<f', v)[0] == VIEJA[rid], (rid, mid)
                v = R(3600.0)
                n += 1
            nuevos.append((mid, ty, lv, dat, v, end))
        t[k] = (base, rid, nuevos)
assert n == 4, n
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))
print('v20s: A0IZ y A0I5 nivel 1 a 3600 s')
