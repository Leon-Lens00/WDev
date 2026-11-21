#!/usr/bin/env python3
"""Tabla por modo de la prueba de oleadas (oleadas_v16t.py). Uso: analizar_oleadas_v16t.py CARPETA
Cuadros del tramo sin los 2 s primeros ni ±0,15 s de cada registro; CPU del hilo principal de muestras.csv. Contadores
por segundo: piensa (WaveAI), ataques y esperas (órdenes de la IA), ordenes (eventos de orden de cualquier unidad).
Al final la media de las dos vueltas por modo y la diferencia con el modo 0.
"""
from pathlib import Path
import csv, os, re, sys

d = Path(sys.argv[1])
NOM = {'0': 'normal, sin disparos', '1': 'sin interfaz (reloj 100 Hz)', '2': 'sin IA', '3': 'enemigos en pausa, sin IA',
       '4': 'sin interfaz, cámara lejos', '5': '8 tiradores MP5', '6': '8 tiradores, sin IA', '9': 'llenado'}
marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
mu = [(float(x['t']), float(x['principal'])) for x in csv.DictReader(open(d / 'muestras.csv'))]
regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('olas-*.txt')
              if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
escr = [t for t, _ in regs]
fil = []
print('| # | Modo | fps | mediana | p99 | máx. | CPU hilo | enemigos | piensa/s | ataques/s | esperas/s | órdenes/s | balas/s |')
print('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
prev = None
for t, x in regs:
    v = dict(zip(x.split()[0::2], x.split()[1::2]))
    if prev and x.startswith('seg'):
        t0, tj0 = prev
        xs = sorted(ms for c, ms in cuadros if t0 + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
        cpu = [p for c, p in mu if t0 + 2 <= c <= t]
        seg = float(v['t']) - tj0
        if not xs or seg <= 0:
            continue
        q = lambda p: xs[min(len(xs) - 1, int(p * len(xs)))]
        r = dict(modo=v['modo'], fps=len(xs) / sum(xs) * 1000, med=q(.5), p99=q(.99), max=xs[-1],
                 cpu=sum(cpu) / len(cpu) if cpu else float('nan'), en=int(v['oleada']),
                 **{k: int(v[k]) / seg for k in ('piensa', 'ataques', 'esperas', 'ordenes', 'balas')})
        fil.append(r)
        print(f"| {v['seg']} | {r['modo']} {NOM.get(r['modo'], '?')} | {r['fps']:.1f} | {r['med']:.1f} ms | {r['p99']:.0f} | "
              f"{r['max']:.0f} | {r['cpu']:.0f} % | {r['en']} | {r['piensa']:.0f} | {r['ataques']:.1f} | {r['esperas']:.1f} | "
              f"{r['ordenes']:.1f} | {r['balas']:.0f} |")
    if 't' in v:
        prev = (t, float(v['t']))
print()
print('| Modo | fps (media) | dif. con modo 0 | CPU hilo | órdenes/s |')
print('|---|---|---|---|---|')
med = {}
for m in sorted({r['modo'] for r in fil if r['modo'] != '9'}):
    rs = [r for r in fil if r['modo'] == m]
    med[m] = tuple(sum(r[k] for r in rs) / len(rs) for k in ('fps', 'cpu', 'ordenes'))
for m, (f, c, o) in med.items():
    dif = f - med['0'][0] if '0' in med else float('nan')
    print(f"| {m} {NOM.get(m, '?')} | {f:.1f} | {dif:+.1f} | {c:.0f} % | {o:.1f} |")
