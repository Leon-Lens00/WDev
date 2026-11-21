#!/usr/bin/env python3
"""Tabla por arma del estrés de v16t (estres_v16t.py). Uso: analizar_estres_v16t.py CARPETA
Como analizar_estres_v16q.py (cuadros del tramo sin los 2 s primeros ni ±0,15 s de cada registro), más las balas
disparadas medidas (campo «balas», si existe) por segundo, en 1,5 s y por tirador.
"""
from pathlib import Path
import os, re, sys

d = Path(sys.argv[1])
NOM = {'1': 'MP5', '2': 'Fusil de asalto', '3': 'Francotirador', '4': 'Escopeta', '0': 'Misiles', '6': 'Granada'}
marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('e16t-*.txt')
              if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
escr = [t for t, _ in regs]
print('| Arma (tier 6, 8 tiradores) | fps | mediana | p99 | máx. | balas/s (8) | en 1,5 s (8) | balas/s por tirador | vivas máx. | enemigos al final |')
print('|---|---|---|---|---|---|---|---|---|---|')
prev = None
for t, x in regs:
    v = dict(zip(x.split()[0::2], x.split()[1::2]))
    if prev and x.startswith('escalon') and v.get('tiradores') != '0':
        t0, tj0 = prev
        xs = sorted(ms for c, ms in cuadros if t0 + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
        q = lambda p: xs[min(len(xs) - 1, int(p * len(xs)))]
        seg = float(v['t']) - tj0
        b = int(v['balas']) / seg if 'balas' in v else float('nan')
        print(f"| {NOM[v['cat']]} | {len(xs) / sum(xs) * 1000:.1f} | {q(.5):.1f} ms | {q(.99):.0f} | {xs[-1]:.0f} | {b:.1f} | {b * 1.5:.0f} | "
              f"{b / int(v['tiradores']):.2f} | {v['maxvivas']} | {v['oleada']} |")
    if 't' in v:
        prev = (t, float(v['t']))
