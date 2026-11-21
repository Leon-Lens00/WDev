#!/usr/bin/env python3
"""v16t-rapidas (13/11/2026): FN SCAR (fusil de asalto) al ritmo del MP5 y balas de arma de fuego al doble de velocidad.

Leon (13/11/2026), tras el laboratorio de ritmo: "la rpm de scar que sea a nivel del mp5, hazlos el doble de rapido
ahora, como balas autenticas y probar como va".

- Fusil de asalto: 480 rpm (intervalo 0,125, el del subfusil) en los seis tiers; daño por bala que conserva el daño por
  segundo de cada tier de v16t-corto.
- Velocidad de bala ×2 en subfusil, fusil de asalto, francotirador y escopeta. Misiles y granadas siguen igual (vuelan
  en arco hasta el punto elegido). El choque se barre cada 8 de distancia (GroundCollision_trace): no atraviesa.
- Rasgos de la tienda con la velocidad nueva.
Uso: rapidas_v16t.py v16t-corto/war3map.j v16t-rpm/war3map.j SALIDA.j
"""
from pathlib import Path
import re
import sys

orig = Path(sys.argv[1]).read_bytes().decode('latin-1')
j = Path(sys.argv[2]).read_bytes().decode('latin-1')


def leer(campo, i, s=None):
    m = re.findall(rf'\n    set Arm_{campo}\[{i}\] = ([^\r\n]+)\r\n', j if s is None else s)
    assert len(m) == 1, (campo, i, m)
    return m[0]


def poner(campo, i, valor):
    global j
    a = f'\n    set Arm_{campo}[{i}] = {leer(campo, i)}\r\n'
    assert j.count(a) == 1, a
    j = j.replace(a, f'\n    set Arm_{campo}[{i}] = {valor}\r\n')


num = lambda s: float(s.rstrip('.'))
fmt = lambda x: f'{x:.4f}'.rstrip('0') if x != int(x) else f'{int(x)}.'
# intervalo del subfusil (v16t-rpm: el del tier 1 en todos)
int_smg = num(leer('Int', 6))
assert all(num(leer('Int', w)) == int_smg for w in range(6, 12))
for c in (1, 2, 3, 4):
    for t in range(6):
        w = c * 6 + t
        vel = num(leer('Vel', w))
        poner('Vel', w, fmt(vel * 2))
        if c == 2:
            dps = num(leer('Dano', w, orig)) * int(leer('Perd', w, orig)) / num(leer('Int', w, orig))
            poner('Int', w, fmt(int_smg))
            poner('Dano', w, fmt(float(round(dps * int_smg / int(leer('Perd', w))))))
        r = leer('Rasgo', w)
        r2 = re.sub(r'bala \d+', f'bala {int(vel * 2)}', r)
        assert r2 != r, (w, r)
        poner('Rasgo', w, r2)
        print(w, leer('Nombre', w), f'{60 / num(leer("Int", w)):.0f} rpm', 'daño', leer('Dano', w), 'vel', leer('Vel', w))
Path(sys.argv[3]).write_bytes(j.encode('latin-1'))
