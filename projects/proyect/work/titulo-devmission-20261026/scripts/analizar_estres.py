#!/usr/bin/env python3
"""Cuadros de una prueba de estrés (entrar-estres-v14q.sh). Uso: analizar_estres.py CARPETA [CARPETA...]

Por carpeta: cuadros de la ronda (del registro «ronda» menos 2 s al registro «fin»), los primeros 20 s de la ronda (salen
los nueve tipos), y la ventana de 1,5 s tras cada matanza (hora del registro menos 1 s). Los cuadros con escritura de
registro (±0,1 s de la hora de cada archivo) se quitan: cada Preload de registro cuesta un cuadro de unos 19 ms.
"""
from pathlib import Path
import os
import re
import sys


def resumen(xs):
    if not xs:
        return 'sin cuadros'
    s = sorted(xs)
    p = lambda q: s[min(len(s) - 1, int(q * len(s)))]
    return (f'{len(s)} cuadros, mediana {p(0.5):.1f} ms, p99 {p(0.99):.1f}, máx {s[-1]:.0f}, '
            f'>50 ms {sum(x > 50 for x in s)}, >100 ms {sum(x > 100 for x in s)}')


for d in map(Path, sys.argv[1:]):
    # cuadros.txt: «µs-época µs-dentro-de-present». La duración del cuadro es el intervalo entre dos presents seguidos.
    marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
    cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
    regs = []
    for f in (d / 'lat').glob('*.txt'):
        m = re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))
        if m:
            regs.append((os.path.getmtime(f), m.group(1)))
    regs.sort()
    escrituras = [t for t, _ in regs]
    limpio = lambda t: all(abs(t - e) > 0.1 for e in escrituras)
    ini = next(t for t, x in regs if x.startswith('ronda')) - 2.
    # Si la oleada se vacía antes de los 155 s no hay registro «fin»: la ronda acaba 2 s después de la última matanza.
    fin = next((t for t, x in regs if x.startswith('fin')), max(t for t, x in regs if x.startswith('matanza')) + 2.)
    print(f'== {d.name}')
    for t, x in regs:
        if not x.startswith('matanza'):
            print('  ', x)
    ronda = [ms for t, ms in cuadros if ini <= t <= fin and limpio(t)]
    print('   ronda:', resumen(ronda))
    print('   primeros 20 s:', resumen([ms for t, ms in cuadros if ini <= t <= ini + 20 and limpio(t)]))
    ventanas = []
    for t, x in regs:
        if x.startswith('matanza'):
            k = t - 1.
            v = [ms for tt, ms in cuadros if k - 0.05 <= tt <= k + 1.5 and limpio(tt)]
            ventanas += v
            print(f'   {x}: máx {max(v, default=0):.0f} ms, >50 ms {sum(m > 50 for m in v)}')
    print('   tras matanzas:', resumen(ventanas))
    carga = [ms for t, ms in cuadros if t < ini]
    if carga:
        print(f'   antes de la ronda: {len(carga)} cuadros, máx {max(carga):.0f} ms')
