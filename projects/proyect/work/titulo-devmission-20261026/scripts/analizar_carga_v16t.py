#!/usr/bin/env python3
"""Tablas de la prueba de carga (carga_v16t.py). Uso: analizar_carga_v16t.py CARPETA [CARPETA2]
Por tramo: fps medios, p99 y CPU del hilo principal (muestras.csv), sin los 2 s primeros ni ±0,15 s de cada registro.
Con dos carpetas (antes y después) añade la diferencia de fps.
"""
from pathlib import Path
import csv, os, re, sys


def leer(d):
    d = Path(d)
    marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
    cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
    mu = [(float(x['t']), float(x['principal'])) for x in csv.DictReader(open(d / 'muestras.csv'))]
    regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('carga-*.txt')
                  if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
    escr = [t for t, _ in regs]
    out, prev = {}, None
    for t, x in regs:
        v = dict(zip(x.split()[0::2], x.split()[1::2]))
        if prev and v.get('fase') == '1':
            xs = sorted(ms for c, ms in cuadros if prev + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
            cpu = [p for c, p in mu if prev + 2 <= c <= t]
            if xs:
                out[(int(v['pob']), int(v['tiradores']))] = dict(
                    fps=len(xs) / sum(xs) * 1000, p99=xs[min(len(xs) - 1, int(.99 * len(xs)))], max=xs[-1],
                    cpu=sum(cpu) / len(cpu) if cpu else float('nan'), en=int(v['oleada']), balas=int(v['balas']) / 10)
        if 't' in v:
            prev = t
    return out


ds = [leer(d) for d in sys.argv[1:]]
for nombre, d in zip(sys.argv[1:], ds):
    pobs = sorted({p for p, _ in d})
    print(f'\n{nombre}\n')
    print('| Tiradores | ' + ' | '.join(f'{p} enemigos' for p in pobs) + ' |')
    print('|---|' + '---|' * len(pobs))
    for n in range(9):
        celdas = []
        for p in pobs:
            r = d.get((p, n))
            celdas.append(f"{r['fps']:.0f} fps, p99 {r['p99']:.0f} ms, CPU {r['cpu']:.0f} %" if r else '-')
        print(f'| {n} | ' + ' | '.join(celdas) + ' |')
    vivos = {p: [r['en'] for (q, _), r in d.items() if q == p] for p in pobs}
    print('\nEnemigos medidos por escalón:', {p: (min(v), max(v)) for p, v in vivos.items()})
if len(ds) == 2:
    a, b = ds
    print('\nDiferencia de fps (segunda menos primera)\n')
    pobs = sorted({p for p, _ in a} & {p for p, _ in b})
    print('| Tiradores | ' + ' | '.join(f'{p}' for p in pobs) + ' |')
    print('|---|' + '---|' * len(pobs))
    for n in range(9):
        print(f'| {n} | ' + ' | '.join(f"{b[(p, n)]['fps'] - a[(p, n)]['fps']:+.1f}" if (p, n) in a and (p, n) in b else '-' for p in pobs) + ' |')
