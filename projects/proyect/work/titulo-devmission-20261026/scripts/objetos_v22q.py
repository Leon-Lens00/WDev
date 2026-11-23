#!/usr/bin/env python3
"""v22q (23/11/2026): textos del Tauren: la Roca crece y llega antes con el tier, el Bombardeo termina antes y la
pasiva lanza a veces una roca.
Uso: objetos_v22q.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v22p)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

C = {
    b'ATb3': [('daña en un área grande y rebota 3 veces hacia delante (cada bote hace menos).',
               'daña en un área y rebota 3 veces hacia delante (cada bote hace menos). Con cada tier el área es más '
               'grande y la roca llega antes.')],
    b'ATb4': [('y durante 8 s lanza rocas en espiral alrededor.',
               'y lanza rocas en espiral alrededor durante 8 s. Con cada tier caen más deprisa y termina antes (4 s '
               'en T6).')],
    b'ATbP': [('a 200 alrededor.',
               'a 200 alrededor. A veces, además, una copia lanza una roca como la de la E (con su tier) hacia el '
               'blanco.')],
}
a_in, a_out = sys.argv[1:3]
ver, tabs = parse_w3a(Path(a_in).read_bytes())
n = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] not in C:
            continue
        km = []
        for mid, ty, lvl, dat, v, end in r[2]:
            if mid == b'aub1':
                t = v.decode('utf-8')
                for a, b in C[r[1]]:
                    assert t.count(a) == 1, (r[1], t)
                    t = t.replace(a, b)
                v = t.encode('utf-8')
                n += 1
            km.append((mid, ty, lvl, dat, v, end))
        tab[k] = (r[0], r[1], km)
assert n == 3, n
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v22q:', len(out), 'bytes')
