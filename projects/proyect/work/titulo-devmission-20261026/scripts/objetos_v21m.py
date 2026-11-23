#!/usr/bin/env python3
"""v21m (22/11/2026): técnicas de Goku sin maná y con recargas largas.

Leon: "le quitaremos el mana a las habiliades tambien pero en contrar aunmentaremos mucho mas el CD para no manchas al
protagonismo de las armas". Puentes AGk1-AGk5: maná 0. Recarga: Q 6 -> 20 s, W 10 -> 30 s, R 30 -> 90 s; X (forma) y
E (Revert) no hacen daño y quedan en 10 y 5 s. El texto de cada puente dice la recarga nueva y "sin maná".
Uso: objetos_v21m.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v21i)
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

a_in, a_out = sys.argv[1:3]
CD = {b'AGk1': 20., b'AGk2': 30., b'AGk3': 90., b'AGk4': 10., b'AGk5': 5.}
ver, tabs = parse_w3a(Path(a_in).read_bytes())
n = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] not in CD:
            continue
        cd = CD[r[1]]
        km = []
        vistos = set()
        for mid, ty, lvl, dat, v, end in r[2]:
            if mid == b'amcs':
                v = struct.pack('<i', 0)
            elif mid == b'acdn':
                v = struct.pack('<f', cd)
            elif mid == b'aub1':
                t = v.decode('utf-8')
                t2 = re.sub(r'Recarga \d+ s, \d+ de maná\.', 'Recarga %d s, sin maná.' % cd, t)
                assert t2 != t, t
                v = t2.encode('utf-8')
            if mid in (b'amcs', b'acdn', b'aub1'):
                vistos.add(mid)
            km.append((mid, ty, lvl, dat, v, end))
        assert vistos == {b'amcs', b'acdn', b'aub1'}, (r[1], vistos)
        tab[k] = (r[0], r[1], km)
        n += 1
assert n == 5, n
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v21m:', len(out), 'bytes;', n, 'puentes')
