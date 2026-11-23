#!/usr/bin/env python3
"""v21f (22/11/2026): objetos de Goku tras la prueba de v21e.

- A0BZ (Ultimate, la lanza la copia): vuelve a la fila de Rain of Fire de v21c/v21d (ANrf, sin daño, 0,01 s), con
  la que la copia sí lanzaba la R; nombre, textos e icono de 2.1a. La fila de 2.1a (Impale de criaturas, ACmp) no
  llegaba a lanzarse desde la copia (Leon: "solo sale el dummy y desaparece").
- AGk4 (X): puente Transformación del controlador, sin objetivo, orden roar, 25 de maná, recarga 10 s.
Uso: objetos_v21f.py V21C.w3a ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

v21c, a_in, a_out = sys.argv[1:4]
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')
_, vieja = parse_w3a(Path(v21c).read_bytes())
ver, tabs = parse_w3a(Path(a_in).read_bytes())
fila = lambda t, i: [r for tab in t for r in tab if r[1] == i]
(ant,) = fila(vieja, b'A0BZ')
(nue,) = fila(tabs, b'A0BZ')
assert ant[0] == b'ANrf' and nue[0] == b'ACmp'
TEXTO = {b'anam', b'aret', b'atp1', b'aub1', b'arut', b'aart', b'arar'}
mods = [m for m in ant[2] if m[0] not in TEXTO] + [m for m in nue[2] if m[0] in TEXTO]
A0BZ = (b'ANrf', b'A0BZ', mods)

(x,) = fila(tabs, b'AGk4')
CAMBIO = {b'anam': S('Goku: Transformación'), b'aart': S('war3mapImported\\BTNPowerUPGokuGOd.blp'),
          b'atp1': S('Transformación (|cffffcc00X|r)'), b'acdn': R(10.), b'amcs': I(25),
          b'aub1': S('Goku carga energía y sube una forma: Super Saiyan, Super Saiyan 3, Super Saiyan Dios, '
                               'Super Saiyan Blue y Ultra Instinto. La Ultimate (R) y el color del Kamehameha cambian '
                               'con la forma. También sube con las muertes de la oleada; al acabarla vuelve a la base.'
                               '|n|n|cff808080Recarga 10 s, 25 de maná.|r')}
assert {m[0] for m in x[2]} >= set(CAMBIO)
xm = [(mid, ty, lvl, dat, CAMBIO.get(mid, v), end) for mid, ty, lvl, dat, v, end in x[2]]
AGk4 = (x[0], b'AGk4', xm)
n = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] == b'A0BZ':
            tab[k] = A0BZ; n += 1
        elif r[1] == b'AGk4':
            tab[k] = AGk4; n += 1
assert n == 2
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v21f:', len(out), 'bytes; A0BZ', len(mods), 'campos')
