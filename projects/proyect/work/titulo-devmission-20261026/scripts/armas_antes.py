#!/usr/bin/env python3
"""Armas como antes de v16t-rpm y v16t-rapidas (14/11/2026), salvo la escopeta.

Leon: "podemos probar las anteriores, la escopeta si esta bien tal como esta ahora su fix con solo 3 perdigones mas ser
mas grandes".
- Subfusil (6-11), fusil de asalto (12-17), francotirador (18-23) y granada (36-41): Int, Dano y Vel de v16t-corto
  (ritmo, daño por bala y velocidad de antes). Disp y Perfora siguen como ahora (v16t-perfora).
- Escopeta (24-29) y misiles (0-5) sin cambios.
- Rasgo: "bala N" con la velocidad restaurada.
Uso: armas_antes.py ENTRADA.j V16T-CORTO.j SALIDA.j
"""
from pathlib import Path
import re
import sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
corto = Path(sys.argv[2]).read_bytes().decode('latin-1')


def leer(campo, i, t):
    m = re.findall(rf'\n    set Arm_{campo}\[{i}\] = ([^\r\n]+)\r\n', t)
    assert len(m) == 1, (campo, i, m)
    return m[0]


def poner(campo, i, valor):
    global s
    a = f'\n    set Arm_{campo}[{i}] = {leer(campo, i, s)}\r\n'
    assert s.count(a) == 1, a
    s = s.replace(a, f'\n    set Arm_{campo}[{i}] = {valor}\r\n')


for w in list(range(6, 24)) + list(range(36, 42)):
    antes = {c: leer(c, w, s) for c in ('Int', 'Dano', 'Vel')}
    for c in ('Int', 'Dano', 'Vel'):
        poner(c, w, leer(c, w, corto))
    r = leer('Rasgo', w, s)
    vel = int(float(leer('Vel', w, s)))
    r2 = re.sub(r'bala \d+', f'bala {vel}', r)
    if r2 != r:
        poner('Rasgo', w, r2)
    it = float(leer('Int', w, s))
    print(f"{w:2d} {leer('Nombre', w, s):28s} {60 / float(antes['Int']):4.0f}->{60 / it:4.0f} rpm  "
          f"daño {antes['Dano']}->{leer('Dano', w, s)}  vel {antes['Vel']}->{leer('Vel', w, s)}")
Path(sys.argv[3]).write_bytes(s.encode('latin-1'))
