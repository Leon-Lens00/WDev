#!/usr/bin/env python3
"""Tabla de la prueba de dibujo (dibujo_v16t.py). Uso: analizar_dibujo_v16t.py CARPETA (con dib/ y dibp/ dentro), o CARPETA lig para la prueba de bala ligera (lig/ dentro)
Por tramo: fps, p99, CPU del hilo principal, balas/s. Sin los 2 s primeros ni ±0,15 s de cada registro.
Al final, media de las dos vueltas por modo y mapa, y diferencia con el modo 1 (normal) de ese mapa.
"""
from pathlib import Path
import csv, os, re, sys

NOM = {0: 'nadie dispara', 1: 'normal', 2: 'sin inclinar', 3: 'sin inclinar ni girar', 4: 'sin barras al golpear',
       5: 'bala sin modelo', 6: 'todo quitado'}


def tramos(d, pre):
    marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
    cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
    mu = [(float(x['t']), float(x['principal'])) for x in csv.DictReader(open(d / 'muestras.csv'))]
    regs = sorted((os.path.getmtime(f), m.group(1)) for f in (d / 'lat').glob(pre + '-*.txt')
                  if (m := re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))))
    escr = [t for t, _ in regs]
    fil, prev = [], None
    for t, x in regs:
        v = dict(zip(x.split()[0::2], x.split()[1::2]))
        if prev and v.get('fase') == '1':
            xs = sorted(ms for c, ms in cuadros if prev + 2 <= c <= t and all(abs(c - e) > 0.15 for e in escr))
            cpu = [p for c, p in mu if prev + 2 <= c <= t]
            if xs:
                fil.append(dict(modo=int(v['modo']), vuelta=int(v['vuelta']), fps=len(xs) / sum(xs) * 1000,
                                p99=xs[min(len(xs) - 1, int(.99 * len(xs)))], cpu=sum(cpu) / len(cpu) if cpu else float('nan'),
                                balas=int(v['balas']) / 10, vivas=int(v['maxvivas']), golpes=int(v['golpes']) / 10,
                                en=int(v['oleada'])))
        if 't' in v:
            prev = t
    completo = any('COMPLETE' in x for _, x in regs)
    return fil, completo


base = Path(sys.argv[1])
res = {}
mapas = (('dib', 'dummy normal'), ('dibp', 'dummy plano'))
if sys.argv[2:] == ['lig']:
    NOM = {0: 'nadie dispara', 1: 'Shot (actual)', 2: 'Toy Bullet2', 3: 'ligera1 sin partículas',
           4: 'ligera2 un cuadrado', 5: 'sin modelo'}
    mapas = (('lig', 'bala ligera'),)
for pre, nom in mapas:
    if not (base / pre / 'cuadros.txt').exists():
        print(f'\n{nom}: sin datos')
        continue
    fil, completo = tramos(base / pre, pre)
    res[pre] = fil
    print(f'\n## {nom} ({"COMPLETE" if completo else "INCOMPLETO"})\n')
    print('| Vuelta | Modo | fps | p99 | CPU hilo | balas/s | vivas máx. | golpes/s | enemigos |')
    print('|---|---|---|---|---|---|---|---|---|')
    for r in fil:
        print(f"| {r['vuelta']} | {r['modo']} {NOM[r['modo']]} | {r['fps']:.1f} | {r['p99']:.0f} ms | {r['cpu']:.0f} % | "
              f"{r['balas']:.0f} | {r['vivas']} | {r['golpes']:.0f} | {r['en']} |")
print('\n| Modo | ' + ' | '.join(f'{p} fps | {p} CPU' for p in res) + ' |')
print('|---|' + '---|---|' * len(res))
for m in NOM:
    cel = []
    for p, fil in res.items():
        rs = [r for r in fil if r['modo'] == m]
        cel.append(f"{sum(r['fps'] for r in rs) / len(rs):.1f} | {sum(r['cpu'] for r in rs) / len(rs):.0f} %" if rs else '- | -')
    print(f'| {m} {NOM[m]} | ' + ' | '.join(cel) + ' |')
