#!/usr/bin/env python3
"""Textos de v14c en war3map.w3a: disparo rápido sólo con subfusiles y rifles; giro antes de disparar.

Uso: objetos_v14c.py ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

TEXTOS = {b'Arp1': 'Se detiene, gira y dispara el arma activa. Con disparo rápido, subfusiles y rifles sueltan seis balas al ritmo del arma.',
          b'Aw07': 'Sólo subfusiles y rifles: cada A suelta seis balas al ritmo del arma con movimiento artificial.',
          b'Aw09': 'Vuelve al disparo de una bala: la unidad se detiene y gira antes de disparar.'}
version, tablas = parse_w3a(Path(sys.argv[1]).read_bytes())
n = 0
for i, f in enumerate(tablas[1]):
    if f[1] in TEXTOS:
        mods = [(m[0], m[1], m[2], m[3], TEXTOS[f[1]].encode('utf-8'), m[5]) if m[0] == b'aub1' else m for m in f[2]]
        tablas[1][i] = (f[0], f[1], mods)
        n += 1
assert n == 3
Path(sys.argv[2]).write_bytes(encode_w3a(version, tablas))
