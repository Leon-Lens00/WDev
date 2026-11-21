#!/usr/bin/env python3
"""Sonidos de armas (14/11/2026): varias tomas por arma, de cerca (propias) y a media distancia (ajenas).

Leon: "suenan bien, lograras ubicar unas mas realistas?" → misma biblioteca (grabaciones reales), con variación y
distancia. De cada grabación se sacan los disparos fuertes (a menos de 4 dB del más fuerte, separados 0,5 s), se
recortan con su cola, se pasan a WAV 22050 Hz 16 bits mono y se igualan de pico; las de cerca llevan +3 dB de graves.
Uso: sonidos_tomas.py "Prepared SFX Library" SALIDA
"""
from pathlib import Path
import math, struct, subprocess, sys

lib, sal = Path(sys.argv[1]), Path(sys.argv[2])
sal.mkdir(parents=True, exist_ok=True)
SR = 22050
# arma: (cerca, lejos, duración del recorte)
ARMAS = {
    'Sub': ('Carl Gustav M45/G_31P.wav', 'Carl Gustav M45/G_20P.wav', 0.45),
    'Fus': ('AR-15/D_32P.wav', 'AR-15/D_24P.wav', 0.55),
    'Fra': ('Tikka/W_29P.wav', 'Tikka/W_24P.wav', 1.0),
    'Esc': ('Model 12/K_17P.wav', 'Model 12/K_17P.wav', 1.1),
}


def disparos(f):
    d = subprocess.run(['ffmpeg', '-v', 'error', '-i', str(f), '-f', 's16le', '-ac', '1', '-ar', str(SR), '-'],
                       capture_output=True, check=True).stdout
    s = struct.unpack('<%dh' % (len(d) // 2), d)
    w = SR // 100
    db = [20 * math.log10(max(1, max(abs(x) for x in s[i:i + w])) / 32768) for i in range(0, len(s) - w, w)]
    mx, ev, ult = max(db), [], -999
    for i in range(5, len(db)):
        if db[i] > mx - 4 and db[i] - min(db[i - 5:i]) > 12 and i - ult > 50:
            ev.append(i / 100); ult = i
    return ev


hechas = []
for arma, (cerca, lejos, dur) in ARMAS.items():
    for dist, f in (('cerca', cerca), ('lejos', lejos)):
        ev = disparos(lib / f)[:3]
        for n, t in enumerate(ev, 1):
            af = [f'afade=t=out:st={dur * 0.7:.3f}:d={dur * 0.3:.3f}']
            if arma == 'Esc' and dist == 'cerca':
                af.append("volume='if(gt(t,0.3),3,1)':eval=frame")   # bombeo ×3 tras el disparo
            if dist == 'cerca':
                af.append('bass=g=3:f=120')
            else:
                af.append('lowpass=f=6000')
            af.append('alimiter=limit=0.89:level=false')
            o = sal / f'{arma}_{dist}_{n}.wav'
            subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', f'{max(0, t - 0.03):.3f}', '-t', str(dur), '-i', str(lib / f),
                            '-af', ','.join(af), '-ac', '1', '-ar', str(SR), '-c:a', 'pcm_s16le', str(o)], check=True)
            hechas.append(f'{o.name} <- {f} @ {t:.2f} s')
print('\n'.join(hechas))
