#!/usr/bin/env python3
"""Sonidos desde la carpeta AudioClip de Leon (14/11/2026): tomas en formato 3D de Warcraft y muestra 3.

Leon: "te dare la ruta de una carpeta, es de un juego que ya tiene los sonidos para oirlos" (~/Descargas/AudioClip,
clips de un juego Unity; procedencia y licencia sin confirmar) y "los rayos … subemos mas su audio … en las cajas
verdes debera sonar un sonido de recarga y mas fuerte".
Uso: sonidos_audioclip.py AUDIOCLIP STORMT_DIR SALIDA
"""
from pathlib import Path
import array, math, random, subprocess, sys, wave

SR = 22050
src, storm, sal = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
(sal / 'tomas').mkdir(parents=True, exist_ok=True); random.seed(3)


def prep(nombre, salida, ini=0., dur=None, filtros=(), lejos=False):
    af = list(filtros)
    if dur: af.append(f'afade=t=out:st={dur * 0.75:.3f}:d={dur * 0.25:.3f}')
    af += ['lowpass=f=5500', 'volume=-3dB'] if lejos else []
    af.append('alimiter=limit=0.89:level=false')
    cmd = ['ffmpeg', '-v', 'error', '-y', '-ss', str(ini)] + (['-t', str(dur)] if dur else []) + [
        '-i', str(src / nombre), '-af', ','.join(af), '-ac', '1', '-ar', str(SR), '-c:a', 'pcm_s16le', str(sal / 'tomas' / salida)]
    subprocess.run(cmd, check=True)
    return leer(sal / 'tomas' / salida)


def leer(p):
    with wave.open(str(p)) as w:
        a = array.array('h'); a.frombytes(w.readframes(w.getnframes()))
    return [x / 32768 for x in a]


# --- armas (propias y lejanas) ---
A = {
    'Sub': prep('MP5N.wav', 'Sub_MP5N.wav', dur=0.5), 'SubL': prep('MP5N.wav', 'Sub_MP5N_lejos.wav', dur=0.5, lejos=True),
    'Fus': prep('SCAR.wav', 'Fus_SCAR.wav', dur=0.55), 'FusL': prep('SCAR.wav', 'Fus_SCAR_lejos.wav', dur=0.55, lejos=True),
    'Fra': prep('Barrett M82.wav', 'Fra_Barrett.wav', dur=1.4), 'FraL': prep('Barrett M82.wav', 'Fra_Barrett_lejos.wav', dur=1.4, lejos=True),
}
# escopetas: disparo + bombeo dentro de 1 s (el intervalo de la escopeta)
ESC = {}
for nom, tiro, bomba, en in (('Remington', 'Remington.wav', 'RemingtonPump.wav', 0.30),
                              ('SPAS', 'SPAS.wav', 'SpasPump.wav', 0.25), ('Benelli', 'Benelli.wav', 'BenelliCocking.wav', 0.22)):
    t = prep(tiro, f'Esc_{nom}_tiro.wav', dur=0.9); b = prep(bomba, f'Esc_{nom}_bombeo.wav')
    m = [0.0] * int(1.0 * SR)
    for i, x in enumerate(t[:len(m)]): m[i] += x
    for i, x in enumerate(b):
        p = int(en * SR) + i
        if p < len(m): m[p] += x * 0.9
    ESC[nom] = m
    escribir = None
# impactos y golpes
IMP = [prep(f'BodyHit{k}.wav', f'Imp_BodyHit{k}.wav') for k in (1, 2, 3, 4)]
CARNE = [prep(f'flesh{k}.wav', f'Imp_flesh{k}.wav') for k in (1, 2, 3, 4)]
HS = prep('headshot2.wav', 'Golpe_headshot2.wav')
# cajas verdes
CAJ = {'ammobox': prep('ammobox.wav', 'Caja_ammobox.wav'), 'PelletReload': prep('PelletReload.wav', 'Caja_PelletReload.wav', filtros=['volume=8dB']),
       'M4A1 recarga': prep('M4A1 (Reload).wav', 'Caja_M4A1_recarga.wav', ini=1.25, dur=0.85)}
# truenos: actuales StormT (8 bits) subidos con compresión, y Thunder 5 / stormimpact
TR = {}
for k in (1, 2, 3):
    o = sal / 'tomas' / f'StormT{k}_fuerte.wav'
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(storm / f'StormT{k}.wav'), '-af',
                    'acompressor=threshold=-24dB:ratio=6:attack=5:release=300:makeup=4,alimiter=limit=0.95:level=false',
                    '-ac', '1', '-ar', str(SR), '-c:a', 'pcm_s16le', str(o)], check=True)
    TR[f'StormT{k} subido'] = leer(o); TR[f'StormT{k} actual'] = prep(str(storm / f'StormT{k}.wav'), f'StormT{k}_actual.wav', filtros=['volume=0dB'])
TR['Thunder 5'] = prep('Thunder 5.wav', 'Trueno_Thunder5.wav', filtros=['acompressor=threshold=-24dB:ratio=6:makeup=3'])
TR['stormimpact'] = prep('stormimpact.wav', 'Trueno_stormimpact.wav')

# --- muestra 3 ---
mu = [0.0] * (SR * 120); pos = int(0.3 * SR); orden = []


def poner(s, p, g=1.0, f=1.0):
    n = int(len(s) / f)
    for i in range(n):
        j = i * f; a = int(j)
        x = s[a] * (1 - j + a) + (s[a + 1] if a + 1 < len(s) else 0) * (j - a)
        mu[p + i] += x * g
    return n


def seccion(t):
    orden.append(f'{pos / SR:5.1f} s  {t}')


def rafaga(s, rps, seg, g=1.0, impactos=False):
    global pos
    k = 0
    while k / rps < seg:
        p = pos + round(k * SR / rps)
        poner(s, p, g, random.uniform(0.96, 1.04))
        if impactos:   # el impacto llega ~0,15 s después
            poner(random.choice(CARNE), p + int(0.15 * SR), 0.5, random.uniform(0.9, 1.1))
            if k % 4 == 3: poner(random.choice(IMP), p + int(0.15 * SR), 0.45)
        k += 1
    pos += round(seg * SR) + int(0.9 * SR)


seccion('Subfusil MP5 T6 (11 rps), tuyo'); rafaga(A['Sub'], 11, 2.0)
seccion('Subfusil MP5 T6, de otro jugador'); rafaga(A['SubL'], 11, 2.0, g=0.4)
seccion('Fusil SCAR T3 (8 rps), tuyo'); rafaga(A['Fus'], 8, 2.0)
seccion('Fusil SCAR T3, de otro jugador'); rafaga(A['FusL'], 8, 2.0, g=0.4)
for nom, m in ESC.items():
    seccion(f'Escopeta {nom} ×3 (cada 1 s)')
    for k in range(3): poner(m, pos + k * SR)
    pos += 3 * SR + int(0.6 * SR)
seccion('Francotirador Barrett ×3 (cada 1 s)')
for k in range(3): poner(A['Fra'], pos + k * SR)
pos += 3 * SR + int(1.0 * SR)
seccion('Subfusil con impactos en carne'); rafaga(A['Sub'], 9, 2.0, impactos=True)
seccion('Golpe de acierto (headshot2)'); poner(HS, pos); pos += len(HS) + int(0.6 * SR)
for nom, c in CAJ.items():
    seccion(f'Caja verde: {nom}'); poner(c, pos); pos += len(c) + int(0.8 * SR)
for nom in ('StormT1 actual', 'StormT1 subido', 'StormT3 actual', 'StormT3 subido', 'Thunder 5', 'stormimpact'):
    seccion(f'Trueno: {nom}'); pos += poner(TR[nom], pos) + int(0.7 * SR)
m = max(abs(x) for x in mu[:pos])
with wave.open(str(sal / 'muestra3-audioclip.wav'), 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(array.array('h', (int(x / m * 0.89 * 32767) for x in mu[:pos])).tobytes())
print('\n'.join(orden), f'\n fin {pos / SR:.1f} s')
