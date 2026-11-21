#!/usr/bin/env python3
"""Sonidos de armas (14/11/2026): bucles por tier y audio de muestra a partir de las candidatas elegidas.

Leon: "elige tu y me preparas un audio de muestra uniendolas con loop para oirlas".
Elección: subfusil Carl Gustav M45 (9 mm), fusil AR-15 (5,56), francotirador Tikka T3, escopeta Winchester Model 12
con el bombeo subido. Fuente: The Free Firearm Sound Library (CC0), fuentes/free-firearm-sfx/candidatas.
Bucles: un disparo repetido a 1/rps y mezclado en círculo (el final se suma al principio) para que el bucle no corte.
Uso: sonidos_muestra.py CANDIDATAS SALIDA
"""
from pathlib import Path
import array, sys, wave

SR = 22050
cand, sal = Path(sys.argv[1]), Path(sys.argv[2])
(sal / 'bucles').mkdir(parents=True, exist_ok=True)


def leer(n):
    with wave.open(str(cand / f'{n}.wav')) as w:
        assert (w.getframerate(), w.getnchannels(), w.getsampwidth()) == (SR, 1, 2)
        a = array.array('h'); a.frombytes(w.readframes(w.getnframes()))
    return [x / 32768 for x in a]


def escribir(nombre, s, pico=0.89):
    m = max(abs(x) for x in s) or 1
    a = array.array('h', (int(x / m * pico * 32767) for x in s))
    with wave.open(str(sal / nombre), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(a.tobytes())


def mezclar(dst, src, pos, g=1.0):
    for i, x in enumerate(src):
        if pos + i >= len(dst): break
        dst[pos + i] += x * g


sub, fus, fra, esc = leer('Sub2_CarlGustav'), leer('Fus2_AR15'), leer('Fra1_Tikka'), leer('Esc2_Model12_bombeo')
# escopeta: bombeo (desde 0,3 s) ×3, con entrada suave
esc = [x * (1 + 2 * min(1, max(0, (i / SR - 0.3) / 0.05))) for i, x in enumerate(esc)]
escribir('Esc_Model12.wav', esc); escribir('Sub_CarlGustav.wav', sub); escribir('Fus_AR15.wav', fus); escribir('Fra_Tikka.wav', fra)

RPS = {'Sub': (sub, [6, 7, 8, 9, 10, 11]), 'Fus': (fus, [7, 7.5, 8, 8.5, 9, 10])}
for arma, (s, lista) in RPS.items():
    for t, r in enumerate(lista, 1):
        paso = SR / r
        n = max(1, round(len(s) / paso)) + 1          # disparos por vuelta, al menos lo que dura el disparo
        largo = round(n * paso)
        b = [0.0] * largo
        for k in range(n):
            p = round(k * paso)
            for i, x in enumerate(s):
                b[(p + i) % largo] += x
        escribir(f'bucles/{arma}_T{t}_{r:g}rps.wav', b)

# muestra: 2 s de ráfaga por tier extremo + disparos sueltos, con su cola natural
mu = [0.0] * (SR * 40)
pos = int(0.3 * SR)


def rafaga(s, r, seg):
    global pos
    k = 0
    while k / r < seg:
        mezclar(mu, s, pos + round(k * SR / r)); k += 1
    pos += round(seg * SR) + int(0.9 * SR)


def sueltos(s, n, intervalo):
    global pos
    for k in range(n):
        mezclar(mu, s, pos + round(k * intervalo * SR))
    pos += round((n - 1) * intervalo * SR) + len(s) + int(0.6 * SR)


orden = []
for arma, (s, lista) in RPS.items():
    for t in (1, 6):
        orden.append(f'{arma} T{t} {lista[t-1]:g} rps @ {pos / SR:.1f} s'); rafaga(s, lista[t - 1], 2.0)
orden.append(f'Escopeta x3 (cada 1,4 s) @ {pos / SR:.1f} s'); sueltos(esc, 3, 1.4)
orden.append(f'Francotirador x3 (cada 1 s) @ {pos / SR:.1f} s'); sueltos(fra, 3, 1.0)
escribir('muestra-armas.wav', mu[:pos])
print('\n'.join(orden), f'\nfin {pos / SR:.1f} s')
