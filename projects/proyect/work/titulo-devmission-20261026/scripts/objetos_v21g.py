#!/usr/bin/env python3
"""v21g (22/11/2026): la E de Goku vuelve a ser Revert, como en D.O.N 2.1a.

En 2.1a la E era Revert (A0CZ, Aroa, recarga 5 s, 1 de maná, BTNRevert.blp): vuelve a Goku normal. La Transmisión
Instantánea estaba en la T. El puente AGk5 (E) pasa a ser Revert sin objetivo; la Transmisión sale del kit (el libro
tiene 5 técnicas por héroe).
Uso: objetos_v21g.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v21f)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

a_in, a_out = sys.argv[1:3]
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')
ver, tabs = parse_w3a(Path(a_in).read_bytes())
(e,) = [r for tab in tabs for r in tab if r[1] == b'AGk5']
assert e[0] == b'ANcl'
CAMBIO = {b'anam': S('Goku: Revert'), b'aart': S('war3mapImported\\BTNRevert.blp'),
          b'atp1': S('Revert (|cffffcc00E|r)'), b'acdn': R(5.), b'amcs': I(1), b'Ncl2': I(0),
          b'aub1': S('Goku deja la transformación y vuelve a su forma normal al instante.'
                     '|n|n|cff808080Recarga 5 s, 1 de maná.|r')}
assert {m[0] for m in e[2]} >= set(CAMBIO)
em = [(mid, ty, lvl, dat, CAMBIO.get(mid, v), end) for mid, ty, lvl, dat, v, end in e[2] if mid != b'atar']
n = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] == b'AGk5':
            tab[k] = (r[0], r[1], em); n += 1
assert n == 1
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v21g:', len(out), 'bytes; AGk5', len(em), 'campos')
