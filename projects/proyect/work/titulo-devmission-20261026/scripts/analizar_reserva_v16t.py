#!/usr/bin/env python3
"""Tabla de la prueba de reserva del reciclador (reserva_v16t.py). Uso: analizar_reserva_v16t.py CARPETA (con res0, res12, res32)
Por tramo: fps, p99, CPU del hilo principal, balas/s, balas vivas máx. Sin los 2 s primeros ni ±0,15 s de cada registro.
Al final la media de las tres vueltas por población y modo, y la diferencia con el modo 1 (normal).
"""
from pathlib import Path
import csv, os, re, sys

def tabla(d):
    NOM = {0: 'nadie dispara', 1: 'apuntado normal', 2: 'cada uno en su dirección', 3: 'todos a la misma dirección'}
    marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
    cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
    mu = [(float(x['t']), float(x['principal'])) for x in csv.DictReader(open(d / 'muestras.csv'))]
    regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('res*-*.txt')
                  if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
    escr = [t for t, _ in regs]
    fil, prev = [], None
    for t, x in regs:
        v = dict(zip(x.split()[0::2], x.split()[1::2]))
        if prev and v.get('fase') == '1':
            xs = sorted(ms for c, ms in cuadros if prev + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
            cpu = [p for c, p in mu if prev + 2 <= c <= t]
            if xs:
                fil.append(dict(pob=int(v['pob']), modo=int(v['modo']), fps=len(xs) / sum(xs) * 1000,
                                p99=xs[min(len(xs) - 1, int(.99 * len(xs)))], cpu=sum(cpu) / len(cpu) if cpu else float('nan'),
                                balas=int(v['balas']) / 10, vivas=int(v['maxvivas']), golpes=int(v['golpes']) / 10,
                                en=int(v['oleada']), nuevas=int(v['nuevas']), reusadas=int(v['reusadas'])))
        if 't' in v:
            prev = t
    print(f'\n### {d.name}\n')
    print('| Enemigos | Modo | fps | p99 | CPU hilo | balas/s | vivas máx. | nuevas | reusadas |')
    print('|---|---|---|---|---|---|---|---|---|')
    ant = (0, 0)
    for r in fil:
        print(f"| {r['pob']} | {r['modo']} {NOM[r['modo']]} | {r['fps']:.1f} | {r['p99']:.0f} ms | {r['cpu']:.0f} % | "
              f"{r['balas']:.0f} | {r['vivas']} | {r['nuevas'] - ant[0]} | {r['reusadas'] - ant[1]} |")
        ant = (r['nuevas'], r['reusadas'])
    print('\n| Enemigos | Modo | fps (media) | dif. con normal | CPU hilo |')
    print('|---|---|---|---|---|')
    for p in sorted({r['pob'] for r in fil}):
        med = {}
        for m in range(4):
            rs = [r for r in fil if r['pob'] == p and r['modo'] == m]
            if rs:
                med[m] = (sum(r['fps'] for r in rs) / len(rs), sum(r['cpu'] for r in rs) / len(rs))
        for m, (f, c) in med.items():
            print(f"| {p} | {m} {NOM[m]} | {f:.1f} | {f - med[1][0]:+.1f} | {c:.0f} % |" if 1 in med else f"| {p} | {m} | {f:.1f} | - | {c:.0f} % |")


for d in sorted(Path(sys.argv[1]).glob('res*'), key=lambda p: int(p.name[3:])):
    tabla(d)
