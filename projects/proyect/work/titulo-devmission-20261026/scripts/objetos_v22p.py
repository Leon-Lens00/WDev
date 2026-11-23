#!/usr/bin/env python3
"""v22p (23/11/2026): texto de la Estampida: el círculo se ensancha y los kodos corren más con el tier.
Uso: objetos_v22p.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v22o)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

VIEJO = 'distintas distancias: dañan a cada enemigo que tocan y lo apartan.'
NUEVO = ('distintas distancias: dañan a cada enemigo que tocan y lo apartan. Con cada tier hay más filas de kodos (el '
         'círculo es más ancho) y corren más rápido.')
a_in, a_out = sys.argv[1:3]
ver, tabs = parse_w3a(Path(a_in).read_bytes())
n = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] != b'ACb4':
            continue
        km = []
        for mid, ty, lvl, dat, v, end in r[2]:
            if mid == b'aub1':
                t = v.decode('utf-8')
                assert t.count(VIEJO) == 1, t
                v = t.replace(VIEJO, NUEVO).encode('utf-8')
                n += 1
            km.append((mid, ty, lvl, dat, v, end))
        tab[k] = (r[0], r[1], km)
assert n == 1, n
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v22p:', len(out), 'bytes')
