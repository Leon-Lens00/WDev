#!/usr/bin/env python3
"""Medición por modos de v16q (entrar-perfil-v16q.sh). Uso: analizar_perfil_v16q.py CARPETA

Cada lat/perfil-N.txt cierra un tramo; su fecha es el reloj real del cierre. Se quitan los 2 s primeros de cada tramo y
±0,15 s alrededor de cada escritura. CPU (hilo principal) y memoria salen de muestras.csv. Al final, la media por arma y
modo y la diferencia con el modo 0 (enemigos solos).
"""
from pathlib import Path
import csv, os, re, sys
from collections import defaultdict

d = Path(sys.argv[1])
marcas = [int(l.split()[0]) for l in (d / 'cuadros.txt').read_text().splitlines() if len(l.split()) == 2]
cuadros = [(b / 1e6, (b - a) / 1000) for a, b in zip(marcas, marcas[1:])]
filas = list(csv.DictReader(open(d / 'muestras.csv')))
regs = []
for f in (d / 'lat').glob('perfil-*.txt'):
    m = re.search(r'Preload\( "(.*?)" \)', f.read_text(encoding='latin-1', errors='replace'))
    if m:
        regs.append((os.path.getmtime(f), m.group(1)))
regs.sort()
escr = [t for t, _ in regs]
NOM = {0: 'enemigos solos', 1: 'normal', 2: 'sin colisión', 3: 'sin modelo', 9: 'llenado'}
ARMA = {1: 'MP5', 4: 'SPAS'}


def tramo(t0, t1):
    xs = [ms for c, ms in cuadros if t0 + 2 <= c <= t1 and all(abs(c - e) > 0.15 for e in escr)]
    ss = [x for x in filas if t0 + 2 <= float(x['t']) <= t1]
    cpu = sum(float(x['principal']) for x in ss) / len(ss) if ss else float('nan')
    rss = int(ss[-1]['rss']) if ss else 0
    return xs, cpu, rss


if regs:
    xs, cpu, rss = tramo(regs[0][0] - 12, regs[0][0] - 1)
    if xs:
        print(f'antes de la ronda: {len(xs) / sum(xs) * 1000:5.1f} fps, CPU {cpu:.0f} %, {rss} MB')
media = defaultdict(list)
prev = None
for t, x in regs:
    v = dict(zip(x.split()[0::2], x.split()[1::2]))
    if prev and x.startswith('seg'):
        xs, cpu, rss = tramo(prev, t)
        if xs:
            fps = len(xs) / sum(xs) * 1000
            q = lambda p: xs[min(len(xs) - 1, int(p * len(xs)))]
            seg = t - prev
            mo, ar = int(v['modo']), int(v['arma'])
            if mo != 9:
                media[(ar, mo)].append((fps, cpu))
            print(f"seg {v['seg']:>2} {ARMA.get(ar, ar):4} {NOM.get(mo, mo):14}: {fps:5.1f} fps, mediana {q(.5):5.1f} ms, "
                  f"máx {xs[-1]:4.0f}, >50 ms {sum(m > 50 for m in xs):3}; CPU {cpu:3.0f} %, {rss} MB; "
                  f"enums/s {int(v['enums']) / seg:5.0f}, pasos/s {int(v['pasos']) / seg:5.0f}, fallos {v['fallos']:>5}, "
                  f"cortes {v['cortes']}, balas {v['maxvivas']:>3}, oleada {v['oleada']}, golpes {v['golpes']}"
                  + (f", sondas {v['sondas']}, rescates {v['rescates']}" if 'sondas' in v else ''))
    prev = t
print()
for ar in (1, 4):
    base = media.get((ar, 0))
    for mo in (0, 1, 2, 3):
        m = media.get((ar, mo))
        if not m:
            continue
        fps = sum(a for a, _ in m) / len(m)
        cpu = sum(b for _, b in m) / len(m)
        ms = 1000 / fps
        extra = ''
        if base and mo:
            bms = 1000 / (sum(a for a, _ in base) / len(base))
            extra = f', +{ms - bms:.1f} ms por cuadro sobre enemigos solos'
        print(f'{ARMA[ar]:4} {NOM[mo]:14}: {fps:5.1f} fps ({ms:.1f} ms), CPU {cpu:.0f} %{extra}')
