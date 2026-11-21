#!/usr/bin/env python3
"""Muestra 2 (14/11/2026): disparos con toma al azar y tono ±4 %, propios (cerca) y de otro jugador (lejos, −9 dB).
Uso: sonidos_muestra2.py TOMAS SALIDA.wav
"""
from pathlib import Path
import array, random, sys, wave

SR = 22050
tom = Path(sys.argv[1]); random.seed(7)


def leer(p):
    with wave.open(str(p)) as w:
        a = array.array('h'); a.frombytes(w.readframes(w.getnframes()))
    return [x / 32768 for x in a]


T = {}
for p in sorted(tom.glob('*.wav')):
    arma, dist, _ = p.stem.split('_')
    T.setdefault((arma, dist), []).append(leer(p))


def tono(s, f):
    n = int(len(s) / f)
    return [s[min(len(s) - 1, int(i * f))] * (1 - (i * f) % 1) + s[min(len(s) - 1, int(i * f) + 1)] * ((i * f) % 1) for i in range(n)]


mu = [0.0] * (SR * 60)
pos = int(0.3 * SR)
orden = []


def tiros(arma, dist, intervalo, n, g=1.0, pausa=0.8):
    global pos
    for k in range(n):
        s = tono(random.choice(T[(arma, dist)]), random.uniform(0.96, 1.04))
        p = pos + round(k * intervalo * SR)
        for i, x in enumerate(s):
            mu[p + i] += x * g
    pos += round((n - 1) * intervalo * SR) + int(len(T[(arma, dist)][0]) + pausa * SR)


for nombre, arma, intervalo, n in (('Subfusil T6 (11 rps)', 'Sub', 1 / 11, 22), ('Fusil T3 (8 rps)', 'Fus', 1 / 8, 16),
                                   ('Escopeta', 'Esc', 1.0, 3), ('Francotirador', 'Fra', 1.0, 3)):
    orden.append(f'{nombre}, tuyo @ {pos / SR:.1f} s'); tiros(arma, 'cerca', intervalo, n)
    orden.append(f'{nombre}, de otro jugador @ {pos / SR:.1f} s'); tiros(arma, 'lejos', intervalo, n, g=0.35, pausa=1.2)
m = max(abs(x) for x in mu[:pos])
with wave.open(sys.argv[2], 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(array.array('h', (int(x / m * 0.89 * 32767) for x in mu[:pos])).tobytes())
print('\n'.join(orden), f'\nfin {pos / SR:.1f} s')
