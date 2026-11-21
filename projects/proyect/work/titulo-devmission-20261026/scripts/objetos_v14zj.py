#!/usr/bin/env python3
"""Objetos de v14zj (07/11/2026): nueva disposición de botones del controlador.

  fila de arriba:  Q subfusil (Aw01)   W rifle (Aw02)     E francotirador (Aw03)  R escopeta (Aw04)
  fila central:    A disparo (Arp1)    F recargar (Aw08)  G batería (Aw0A)        D dash (Ard1)
  fila de abajo:   Z cuchillo (Aw05)   X granadas (Aw06)  C misil de calor (Aw00, todavía sin darse; fase 5)

Cambia ahky, abpx y abpy, y la tecla de «(|cffffcc00X|r)» en cada nivel de atp1. Lo demás queda igual.
Uso: objetos_v14zj.py DIR_ENTRADA DIR_SALIDA (war3map.w3a extraído de v14zi)
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
NUEVO = {b'Aw01': ('Q', 0, 0), b'Aw02': ('W', 1, 0), b'Aw03': ('E', 2, 0), b'Aw04': ('R', 3, 0),
         b'Arp1': ('A', 0, 1), b'Aw08': ('F', 1, 1), b'Aw0A': ('G', 2, 1), b'Ard1': ('D', 3, 1),
         b'Aw05': ('Z', 0, 2), b'Aw06': ('X', 1, 2), b'Aw00': ('C', 2, 2)}
assert len({(x, y) for _, x, y in NUEVO.values()}) == len({k for k, _, _ in NUEVO.values()}) == len(NUEVO)

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
assert parse_w3a(encode_w3a(version, tablas)) == (version, tablas)
hechos = set()
for n, f in enumerate(tablas[1]):
    if f[1] not in NUEVO:
        continue
    k, x, y = NUEVO[f[1]]
    vistos, mods = set(), []
    for m in f[2]:
        mid, typ, lvl, data, val, end = m
        if mid == b'ahky':
            val = k.encode()
        elif mid == b'abpx':
            val = struct.pack('<I', x)
        elif mid == b'abpy':
            val = struct.pack('<I', y)
        elif mid == b'atp1':
            val, c = re.subn(rb'\(\|cffffcc00[A-Z]\|r\)', b'(|cffffcc00' + k.encode() + b'|r)', val)
            assert c == 1, (f[1], lvl, val)
        vistos.add(mid)
        mods.append((mid, typ, lvl, data, val, end))
    assert {b'ahky', b'abpx', b'abpy', b'atp1'} <= vistos, f[1]
    tablas[1][n] = (f[0], f[1], mods)
    hechos.add(f[1])
assert hechos == set(NUEVO), set(NUEVO) - hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))
