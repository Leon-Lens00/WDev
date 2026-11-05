#!/usr/bin/env python3
"""Cruza cuadros, muestras del proceso y registros del juego. Uso: informe_lag.py CARPETA. Escribe CARPETA/informe.txt."""
from pathlib import Path
import csv
import glob
import os
import re
import sys

D = Path(sys.argv[1])
COLS = 'fire pair conv aitk wave barr spwn muer pens hide orden'.split()
UMBRALES = (33, 50, 100, 250, 500)
salida = []


def p(x=''):
    salida.append(x)


cuadros = []
if (D / 'cuadros.txt').exists():
    for l in (D / 'cuadros.txt').read_text().splitlines():
        c = l.split()
        if len(c) == 2:
            cuadros.append((int(c[0]) / 1e6, int(c[1]) / 1000))
registros = []
for f in glob.glob(str(D / 'lat/j1-*.txt')):
    m = re.search(r'Preload\( "(.*?)" \)', Path(f).read_text(encoding='latin-1', errors='replace'))
    if m:
        registros.append((os.path.getmtime(f), m.group(1)))
registros.sort()
pulsos, eventos = [], []
for t, l in registros:
    if l.startswith('pulso'):
        v = l.split()
        pulsos.append((t, dict(zip(v[1:19:2], map(int, v[2:19:2]))), dict(zip(COLS, map(int, v[19:])))))
    elif not l.startswith(('muestra', 'fin dash')):
        eventos.append((t, l))
muestras = []
if (D / 'muestras.csv').exists():
    muestras = [{k: float(v) for k, v in r.items()} for r in csv.DictReader((D / 'muestras.csv').open())]


def pulso_en(t):
    r = None
    for q in pulsos:
        if q[0] > t + 0.5:
            break
        r = q
    return r


def muestra_en(t):
    return min(muestras, key=lambda m: abs(m['t'] - t)) if muestras else None


def resumen(nombre, dts):
    if len(dts) < 2:
        return
    o = sorted(dts)
    total = sum(dts) / 1000
    peor = o[-max(1, len(o) // 100):]
    p(f'{nombre:12} {total:7.1f}s  {len(dts) / total:6.1f} fps  1% bajo {1000 * len(peor) / sum(peor):6.1f} fps  mediana {o[len(o) // 2]:5.1f} ms  máx {o[-1]:7.1f} ms  ' +
      ' '.join(f'≥{u}:{sum(d >= u for d in dts)}' for u in UMBRALES))


if len(cuadros) < 2:
    p('Sin cuadros: la capa no se cargó o la partida no llegó a dibujar.')
else:
    pares = [(cuadros[i][0], (cuadros[i][0] - cuadros[i - 1][0]) * 1000) for i in range(1, len(cuadros))]
    espera = {cuadros[i][0]: cuadros[i - 1][1] for i in range(1, len(cuadros))}
    inicio = pulsos[0][0] if pulsos else cuadros[0][0]
    fin = pulsos[-1][0] + 1 if pulsos else cuadros[-1][0]
    juego = [x for x in pares if inicio <= x[0] <= fin]
    p(f'Cuadros {len(cuadros)}, pulsos {len(pulsos)}, eventos {len(eventos)}, muestras {len(muestras)}')
    p()
    resumen('carga+total', [d for _, d in pares])
    resumen('partida', [d for _, d in juego])
    p()
    for nombre, cond in (('ronda', lambda q: not q[1]['d']), ('descanso', lambda q: q[1]['d'])):
        for r in sorted({q[1]['r'] for q in pulsos}):
            tt = [q[0] for q in pulsos if q[1]['r'] == r and cond(q)]
            if tt:
                resumen(f'{nombre} {r}', [d for t, d in juego if min(tt) <= t <= max(tt) + 1])
    p()
    p('Cuadros por carga de enemigos activos (partida):')
    for a, b in ((0, 0), (1, 6), (7, 12), (13, 18), (19, 24), (25, 999)):
        tt = [q[0] for q in pulsos if a <= q[1]['ai'] <= b]
        ds = [d for t, d in juego if any(x <= t < x + 1 for x in tt)] if tt else []
        resumen(f'ai {a}-{b}', ds)
    p()
    largos = [(t, d) for t, d in juego if d >= 100]
    if largos:
        p(f'Tiempo en cuadros de 100 ms o más: {sum(d for _, d in largos) / 1000:.1f} s; dentro de present: {sum(espera[t] for t, _ in largos) / 1000:.1f} s.')
    if muestras and 'foco' in muestras[0]:
        p(f"Muestras con foco {sum(m['foco'] == 1 for m in muestras)} de {len(muestras)}, visibles {sum(m['visible'] == 1 for m in muestras)}.")
    p()
    p('Peores cuadros de la partida (t = segundos desde el primer pulso):')
    for t, d in sorted(sorted(juego, key=lambda x: -x[1])[:25]):
        q = pulso_en(t)
        m = muestra_en(t)
        cerca = [l[:40] for e, l in eventos if abs(e - t) <= 1]
        p(f'  t {t - inicio:7.2f}  {d:7.1f} ms' +
          (f"  juego {q[1]['t']}s r{q[1]['r']} d{q[1]['d']} ai {q[1]['ai']} mis {q[1]['mis']} spwn {q[2]['spwn']} orden {q[2]['orden']}" if q else '') +
          f'  present {espera[t]:6.1f} ms' +
          (f"  cpu {m['principal']:.0f}% dxvk {m['dxvk']:.0f}% rss {m['rss']:.0f} foco {m.get('foco', -1):.0f} visible {m.get('visible', -1):.0f}" if m else '') +
          (f'  cerca {cerca}' if cerca else ''))
if muestras:
    p()
    p(f"Hilo principal máx {max(m['principal'] for m in muestras):.0f}%, media {sum(m['principal'] for m in muestras) / len(muestras):.0f}%. RSS {muestras[0]['rss']:.0f} -> {muestras[-1]['rss']:.0f} MB, máx {max(m['rss'] for m in muestras):.0f}. Fallos mayores {sum(m['fallos'] for m in muestras):.0f}. Leído {(muestras[-1]['leido'] - muestras[0]['leido']) / 1e6:.1f} MB.")
if pulsos:
    p(f"Handles {pulsos[0][1]['h']} -> {pulsos[-1][1]['h']}. Dummies nuevos {pulsos[-1][1]['dn']}, tiros {pulsos[-1][1]['tir']}.")
    p('Medias por pulso: ' + ' '.join(f"{c} {sum(q[2][c] for q in pulsos) / len(pulsos):.1f}" for c in COLS))
texto = '\n'.join(salida) + '\n'
(D / 'informe.txt').write_text(texto)
print(texto)
