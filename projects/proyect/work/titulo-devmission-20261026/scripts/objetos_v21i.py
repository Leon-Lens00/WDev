#!/usr/bin/env python3
"""v21i (22/11/2026): Kaioken de Goku sobre el cuerpo real.

A0JF (Inner Fire de 2.1a, buff B05J) sólo admitía héroes y duraba 0,1 s en unidades normales; Goku es una unidad
normal, así que la R de Super Saiyan Blue no le daba nada. Blancos sin "hero" y 25 s también en unidades normales,
como la duración de héroe de 2.1a. El resto (daño +100/150/200/250 %, armadura +10, regeneración) queda igual.
Uso: objetos_v21i.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v21g/v21h)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

a_in, a_out = sys.argv[1:3]
ver, tabs = parse_w3a(Path(a_in).read_bytes())
(k,) = [r for tab in tabs for r in tab if r[1] == b'A0JF']
assert k[0] == b'Ainf'
CAMBIO = {b'atar': b'alive,allies,friend,notself', b'adur': struct.pack('<f', 25.)}
n = 0
km = []
for mid, ty, lvl, dat, v, end in k[2]:
    if mid in CAMBIO:
        if mid == b'atar':
            assert v == b'alive,allies,friend,hero,notself', v
        v = CAMBIO[mid]; n += 1
    km.append((mid, ty, lvl, dat, v, end))
assert n == 8, n
for tab in tabs:
    for i, r in enumerate(tab):
        if r[1] == b'A0JF':
            tab[i] = (r[0], r[1], km)
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v21i:', len(out), 'bytes; A0JF', n, 'campos cambiados')
