#!/usr/bin/env python3
"""Tabla de la prueba de cámara y armas solas (camara_v16t.py). Uso: analizar_camara_v16t.py CARPETA
Por tramo: fps, p99, CPU del hilo principal, balas/s, balas vivas máx. Sin los 2 s primeros ni ±0,15 s de cada registro.
Al final la media de las dos vueltas por población y modo, y la diferencia con el modo 1 (normal).
"""
from pathlib import Path
import csv, os, re, sys

d = Path(sys.argv[1])
NOM = {0: 'nadie, cámara en el héroe', 1: '8 MP5, cámara en el héroe', 2: 'nadie, cámara lejos', 3: '8 MP5, cámara lejos'}
NOM.update({10 + n: f'{n} MP5 sin enemigos' for n in range(1, 9)})
NOM.update({20 + n: f'{n} SCAR sin enemigos' for n in range(1, 9)})
marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
mu = [(float(x['t']), float(x['principal'])) for x in csv.DictReader(open(d / 'muestras.csv'))]
regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob('cam-*.txt')
              if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
escr = [t for t, _ in regs]
fil, prev = [], None
for t, x in regs:
    v = dict(zip(x.split()[0::2], x.split()[1::2]))
    if prev and v.get('fase') in ('1', '2', '3'):
        xs = sorted(ms for c, ms in cuadros if prev + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
        cpu = [p for c, p in mu if prev + 2 <= c <= t]
        if xs:
            fil.append(dict(fase=int(v['fase']), pob=int(v['pob']), modo=int(v['modo']), fps=len(xs) / sum(xs) * 1000,
                            p99=xs[min(len(xs) - 1, int(.99 * len(xs)))], cpu=sum(cpu) / len(cpu) if cpu else float('nan'),
                            balas=int(v['balas']) / 10, vivas=int(v['maxvivas']), golpes=int(v['golpes']) / 10,
                            en=int(v['oleada']), nuevas=int(v['nuevas'])))
    if 't' in v:
        prev = t
print('| Enemigos | Modo | fps | p99 | CPU hilo | balas/s | vivas máx. | golpes/s | enemigos | nuevas |')
print('|---|---|---|---|---|---|---|---|---|---|')
ant = 0
for r in fil:
    print(f"| {r['pob']} | {r['modo']} {NOM[r['modo']] if r['fase'] < 2 or r['modo'] else 'nadie, sin enemigos'} | {r['fps']:.1f} | {r['p99']:.0f} ms | {r['cpu']:.0f} % | "
          f"{r['balas']:.0f} | {r['vivas']} | {r['golpes']:.0f} | {r['en']} | {r['nuevas'] - ant} |")
    ant = r['nuevas']
print('\n| Fase 1 (120 enemigos) | fps (media) | CPU hilo |')
print('|---|---|---|')
for m in range(4):
    rs = [r for r in fil if r['fase'] == 1 and r['modo'] == m]
    if rs:
        print(f"| {NOM[m]} | {sum(r['fps'] for r in rs) / len(rs):.1f} | {sum(r['cpu'] for r in rs) / len(rs):.0f} % |")
print('\n| Tiradores sin enemigos | MP5 fps | MP5 CPU | SCAR fps | SCAR CPU |')
print('|---|---|---|---|---|')
for n in range(0, 9):
    f = lambda m: [r for r in fil if r['fase'] >= 2 and r['modo'] == m]
    a_ = f(10 + n) if n else [r for r in fil if r['fase'] == 2 and r['modo'] == 0]
    b_ = f(20 + n) if n else a_
    cel = lambda rs: (f"{rs[0]['fps']:.1f} | {rs[0]['cpu']:.0f} %" if rs else '- | -')
    print(f"| {n} | {cel(a_)} | {cel(b_)} |")
