#!/usr/bin/env python3
"""Cuadros de una prueba de tormentas (entrar-vNN-rayos.sh). Uso: analizar_rayos.py CARPETA [CARPETA...]

Ventana: del registro «rayo 1» menos 1 s al registro «fin». Quita los cuadros a ±0,1 s de cada escritura de registro y
cuenta los cuadros de más de 50 y 100 ms en los 0,5 s posteriores a cada tormenta lanzada (hora del registro «rayo»).
"""
from pathlib import Path
import os
import re
import sys

for d in map(Path, sys.argv[1:]):
    marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
    cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
    regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('*.txt')
                  if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
    esc = [t for t, _ in regs]
    rayos = [t for t, x in regs if x.startswith('rayo')]
    ini, fin = rayos[0] - 1., next(t for t, x in regs if x.startswith('fin'))
    v = [(t, x) for t, x in cuadros if ini <= t <= fin and all(abs(t - e) > 0.1 for e in esc)]
    s = sorted(x for _, x in v)
    tras = [x for t, x in v if any(0 <= t - r <= 4. for r in rayos)]
    print(f'{d.name}: {len(s)} cuadros, mediana {s[len(s)//2]:.1f} ms, p99 {s[int(.99*len(s))]:.1f}, máx {s[-1]:.0f}, '
          f'>50 ms {sum(x > 50 for x in s)}, >100 ms {sum(x > 100 for x in s)}; '
          f'{len(rayos)} tormentas, >100 ms en sus 4 s: {sum(x > 100 for x in tras)}')
