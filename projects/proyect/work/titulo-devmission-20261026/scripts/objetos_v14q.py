#!/usr/bin/env python3
"""Objetos de v14q: el texto de cada nivel de Aw00..Aw06 lleva el alcance de su tier (armas_v14q). Parte del w3a de v14p.

Uso: objetos_v14q.py DIR_ENTRADA DIR_SALIDA (war3map.w3a)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
from armas_v14q import ARMAS, TIERS, rasgo

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
n = 0
for i, f in enumerate(tablas[1]):
    if not (f[1].startswith(b'Aw0') and f[1][3:] in b'0123456'):
        continue
    c = int(f[1][3:])
    nuevos = []
    for m in f[2]:
        if m[0] == b'aub1':
            t = m[2]
            m = (m[0], m[1], t, m[3], f'Activa esta arma. {rasgo(c, ARMAS[c * TIERS + t - 1], t)}.'.encode('utf-8'), m[5])
            n += 1
        nuevos.append(m)
    tablas[1][i] = (f[0], f[1], nuevos)
assert n == 7 * TIERS, n
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida and parse_w3a(salida)[1][1] == tablas[1]
(dst / 'war3map.w3a').write_bytes(salida)
print('w3a: alcance en', n, 'textos de nivel')
