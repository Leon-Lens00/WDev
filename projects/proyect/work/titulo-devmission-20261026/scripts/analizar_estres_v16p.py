#!/usr/bin/env python3
"""Cuadros por escalón de la prueba de estrés v16p (entrar-estres-v16p.sh). Uso: analizar_estres_v16p.py CARPETA

Cada registro lat/e16-N.txt cierra un escalón; su fecha es el reloj real del cierre. El escalón K va del cierre del K-1
al del K. Se miden sus cuadros quitando los 2 s primeros (cambio de tiradores) y ±0,15 s de cada escritura de registro.
Ralentización: tiempo de juego (t del registro) entre tiempo real del mismo tramo (1,00 = juego a tiempo real).
"""
from pathlib import Path
import os, re, sys

d = Path(sys.argv[1])
marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
regs = []
for f in (d / 'lat').glob('e16-*.txt'):
    m = re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))
    if m:
        regs.append((os.path.getmtime(f), m.group(1)))
regs.sort()
escr = [t for t, _ in regs]
for t, x in regs:
    print(f'{t - regs[0][0]:7.1f} s  {x}')
print()
prev = None
for t, x in regs:
    v = dict(zip(x.split()[0::2], x.split()[1::2]))
    tj = float(v['t']) if 't' in v else None
    if prev and x.startswith('escalon'):
        t0, tj0 = prev
        xs = sorted(ms for (c, ms) in cuadros if t0 + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
        if xs:
            q = lambda p: xs[min(len(xs) - 1, int(p * len(xs)))]
            fps = len(xs) / sum(xs) * 1000
            ral = (tj - tj0) / (t - t0) if tj is not None and tj0 is not None else float('nan')
            seg = t - t0
            print(f"tiradores {v['tiradores']}: {fps:5.1f} fps, mediana {q(.5):.1f} ms, p99 {q(.99):.1f}, máx {xs[-1]:.0f}, "
                  f">50 ms {sum(m > 50 for m in xs)}, >100 ms {sum(m > 100 for m in xs)}; juego/real {ral:.2f}; "
                  f"pasos/s {int(v['pasos']) / seg:.0f}, enums/s {int(v['enums']) / seg:.0f}, cortes {v['cortes']}, "
                  f"balas vivas máx {v['maxvivas']}, oleada {v['oleada']}")
    if tj is not None:
        prev = (t, tj)
