#!/usr/bin/env python3
"""Muestra 4 (14/11/2026): arma distinta por tier, impactos por material, cajas de recarga y truenos mejorados.

Leon: "en audio clip lleva diferentes audios, podria ayudar para ciertas armas tier de diferente sonido, lleva tambien
de impactos?", "lleva un sonido de recharge o recarga que podria ir bien ahi" y "los rayos … tienes la capacidad de
mejorar su sonido? ya que se escucha muy de mala calidad".
Truenos: los StormT1-3 de Storm 1.3.1 son PCM 8 bits 22 kHz mono; la versión "restaurada" quita el siseo de 8 bits
(afftdn + paso bajo), da graves y comprime. Los nuevos salen de AudioClip en estéreo 44,1 kHz (no son 3D en Storm).
Uso: sonidos_muestra4.py AUDIOCLIP STORMT_DIR SALIDA
"""
from pathlib import Path
import array, random, subprocess, sys, wave

SR = 44100
src, storm, sal = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
(sal / 'tomas4').mkdir(parents=True, exist_ok=True); random.seed(5)


def prep(nombre, salida, ini=0., dur=None, filtros=(), base=src):
    af = list(filtros)
    if dur: af.append(f'afade=t=out:st={dur * 0.75:.3f}:d={dur * 0.25:.3f}')
    af.append('alimiter=limit=0.89:level=false')
    o = sal / 'tomas4' / salida
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', str(ini)] + (['-t', str(dur)] if dur else []) +
                   ['-i', str(base / nombre), '-af', ','.join(af), '-ac', '1', '-ar', str(SR), '-c:a', 'pcm_s16le', str(o)], check=True)
    with wave.open(str(o)) as w:
        a = array.array('h'); a.frombytes(w.readframes(w.getnframes()))
    return [x / 32768 for x in a]


mu = [0.0] * (SR * 260); pos = int(0.3 * SR); orden = []


def poner(s, p, g=1.0, f=1.0):
    n = int(len(s) / f)
    for i in range(n):
        j = i * f; a = int(j)
        mu[p + i] += (s[a] * (1 - j + a) + (s[a + 1] if a + 1 < len(s) else 0) * (j - a)) * g
    return n


def sec(t): orden.append(f'{pos / SR:6.1f} s  {t}')


def tanda(s, rps, n, g=1.0):
    global pos
    for k in range(n): poner(s, pos + round(k * SR / rps), g, random.uniform(0.97, 1.03))
    pos += round((n - 1) * SR / rps) + len(s) + int(0.35 * SR)


# --- armas por tier: (tier, archivo, duración del recorte, rps del tier, disparos) ---
SUB = [('Mac.wav', 6), ('MP40.wav', 7), ('Thompson.wav', 8), ('UMP9.wav', 9), ('MP5N.wav', 10), ('P90.wav', 11)]
FUS = [('MP44_AKM.wav', 7), ('FAMAS.wav', 7.5), ('M4A1.wav', 8), ('G11.wav', 8.5), ('SCAR.wav', 9), ('Bren.wav', 10)]
for arma, lista in (('Subfusil', SUB), ('Fusil', FUS)):
    for t, (f, r) in enumerate(lista, 1):
        sec(f'{arma} T{t}: {f[:-4]} ({r:g} rps)'); tanda(prep(f, f'{arma}_T{t}.wav', dur=0.5), r, int(r * 1.2))
ESC = [('Boomstick.wav', None, 0), ('Remington.wav', 'RemingtonPump.wav', 0.30), ('Benelli.wav', 'BenelliCocking.wav', 0.22),
       ('SPAS.wav', 'SpasPump.wav', 0.25), ('Pancor.wav', None, 0), ('Puntgun.wav', None, 0)]
for t, (f, b, en) in enumerate(ESC, 1):
    s = prep(f, f'Escopeta_T{t}.wav', dur=0.95)
    if b:
        bb = prep(b, f'Escopeta_T{t}_bombeo.wav')
        s = s + [0.0] * max(0, int(en * SR) + len(bb) - len(s))
        for i, x in enumerate(bb): s[int(en * SR) + i] += x * 0.9
        s = s[:SR]
    sec(f'Escopeta T{t}: {f[:-4]}' + (' + bombeo' if b else '')); tanda(s, 1.0, 2)
for t, f in ((1, 'Kar98k.wav'), (3, 'M1Garand.wav'), (6, 'Barrett M82.wav')):
    sec(f'Francotirador T{t}: {f[:-4]}'); tanda(prep(f, f'Francotirador_T{t}.wav', dur=1.3), 1.0, 2)
for t, f in ((1, 'Panzerfaust.wav'), (3, 'Panzerschreck.wav'), (6, 'Warhawk.wav')):
    sec(f'Misiles T{t}: {f[:-4]}'); tanda(prep(f, f'Misiles_T{t}.wav', dur=1.2), 1.0, 2)
sec('Granada: Milkor (lanzagranadas) + Granada (Explosion)')
tanda(prep('Milkor.wav', 'Granada_lanzar.wav'), 3, 1); pos += poner(prep('Granada (Explosion).wav', 'Granada_explota.wav', dur=2.0), pos) + int(0.5 * SR)
# --- impactos por material (4 tomas cada uno) ---
for mat, fs in (('carne', [f'flesh{k}.wav' for k in (1, 2, 3, 4)]), ('cuerpo', [f'BodyHit{k}.wav' for k in (1, 2, 3, 4)]),
                ('metal', [f'metal{k}.wav' for k in (1, 2, 3, 4)]), ('piedra', [f'stone{k}.wav' for k in (1, 2, 3, 4)]),
                ('madera', [f'wood{k}.wav' for k in (1, 2, 3)]), ('arena', [f'sand{k}.wav' for k in (1, 2, 3)]),
                ('agua', [f'water{k}.wav' for k in (1, 2, 3)]), ('cristal', [f'Glass{k}.wav' for k in (1, 2)])):
    sec(f'Impacto {mat}: ' + ', '.join(x[:-4] for x in fs))
    for f in fs:
        s = prep(f, f'Imp_{f}', dur=0.6); poner(s, pos); pos += int(0.38 * SR)
    pos += int(0.5 * SR)
sec('Acierto: headshot, headshot2, headshot3')
for f in ('headshot.wav', 'headshot2.wav', 'headshot3.wav'):
    s = prep(f, f'Golpe_{f}', dur=1.0); poner(s, pos); pos += len(s) + int(0.3 * SR)
# --- cajas verdes ---
for f, ini, dur in (('ammobox.wav', 0, None), ('equipamiento.wav', 0, None), ('armasligeras.wav', 0, None), ('switch.wav', 0, None),
                    ('ikarchargeup.wav', 0, 1.6), ('MedkitHeal.wav', 0, 1.5), ('t5rel.wav', 0, None), ('M4A1 (Reload).wav', 1.25, 0.85)):
    sec(f'Caja verde: {f[:-4]}' + (f' ({ini:g}–{ini + dur:g} s)' if dur else ''))
    s = prep(f, f'Caja_{f}', ini, dur); poner(s, pos); pos += len(s) + int(0.6 * SR)
# --- truenos ---
REST = 'afftdn=nf=-30,lowpass=f=7000,bass=g=5:f=90,acompressor=threshold=-26dB:ratio=5:attack=5:release=400:makeup=5'
for k in (1, 2, 3):
    sec(f'Trueno StormT{k} actual'); pos += poner(prep(f'StormT{k}.wav', f'StormT{k}_actual.wav', base=storm, filtros=['volume=0dB']), pos, 0.7) + int(0.5 * SR)
    sec(f'Trueno StormT{k} restaurado'); pos += poner(prep(f'StormT{k}.wav', f'StormT{k}_restaurado.wav', base=storm, filtros=[REST]), pos) + int(0.5 * SR)
for nom, f, ini, dur in (('nuevo T1: Thunder 5', 'Thunder 5.wav', 0, 2.06), ('nuevo T2: truenolobo2', 'truenolobo2.wav', 0.4, 5.0),
                         ('nuevo T3: truenolobo4', 'truenolobo4.wav', 0.5, 6.5), ('nuevo extra: lluvia y trueno', 'thunder_with_light_rain_003.wav', 24.2, 6.0)):
    sec(f'Trueno {nom}'); pos += poner(prep(f, f'Trueno_{f}', ini, dur, filtros=['acompressor=threshold=-24dB:ratio=4:makeup=3']), pos) + int(0.5 * SR)

m = max(abs(x) for x in mu[:pos])
with wave.open(str(sal / 'muestra4-audioclip.wav'), 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(array.array('h', (int(x / m * 0.89 * 32767) for x in mu[:pos])).tobytes())
(sal / 'muestra4-orden.txt').write_text('\n'.join(orden) + f'\n fin {pos / SR:.1f} s\n')
print('\n'.join(orden), f'\n fin {pos / SR:.1f} s')
