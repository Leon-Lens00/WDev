#!/usr/bin/env python3
"""v18a (15/11/2026): un solo tic de la tirada de "Super Creep Random Boost" (Dark Moon), sacado del vídeo de Leon.

En la grabación (Videocaptura de pantalla_20261115_002900.mp4) las cartas cambian cada 0,2 s y cada cambio suena un tic
(3-14 kHz). De 23,0 a 24,2 s sólo se oye eso más el ruido de fondo del juego (graves). Método, sin inventar sonido:
1. Paso alto 900 Hz (quita el ruido grave del juego; el tic no tiene energía útil debajo).
2. Busca cada tic cerca de los cambios de carta medidos en el vídeo y lo alinea con el primero por correlación.
3. Promedia los tics alineados: el tic se repite igual y el ruido no, así que el ruido baja ~sqrt(N).
4. Puerta suave al final (fundido) y normaliza a −1 dBFS; 22050 Hz mono 16 bits, como los sonidos del mapa.
Escribe un JSON con la correlación de cada tic con el promedio (para ver que es el mismo sonido).

Uso (Python con numpy/scipy): sonido_v18a.py TRAMO.wav (48 kHz, desde 22,85 s del vídeo) SALIDA.wav
"""
import json, sys, wave
import numpy as np
from scipy.signal import butter, sosfiltfilt, resample_poly

T0 = 22.85
CAMBIOS = [23.00, 23.20, 23.40, 23.63, 23.80, 24.00, 24.18]   # cambios de carta medidos a 60 fps (sin el final)
ANTES, DESPUES = 0.02, 0.17

with wave.open(sys.argv[1]) as w:
    r = w.getframerate()
    a = np.frombuffer(w.readframes(w.getnframes()), dtype='<i2').reshape(-1, w.getnchannels()).astype(np.float64)
x = a.mean(axis=1) / 32768.
x = sosfiltfilt(butter(4, 900, 'highpass', fs=r, output='sos'), x)
env = np.convolve(np.abs(x), np.ones(int(0.004 * r)) / int(0.004 * r), 'same')

# Inicio de cada tic: subida de la envolvente dentro de ±60 ms del cambio de carta.
ini = []
for c in CAMBIOS:
    i0, i1 = int((c - T0 - 0.06) * r), int((c - T0 + 0.06) * r)
    seg = env[i0:i1]
    base = np.percentile(seg, 20)
    k = np.argmax(seg > base + 0.5 * (seg.max() - base))
    ini.append(i0 + k)

n = int((ANTES + DESPUES) * r)
ventana = lambda i: x[i - int(ANTES * r): i - int(ANTES * r) + n]
ref = ventana(ini[0])
lag = int(0.008 * r)
alineados = []
for i in ini:
    mejor = max(range(-lag, lag + 1), key=lambda d: float(np.dot(ref, ventana(i + d))))
    alineados.append(ventana(i + mejor))
prom = np.mean(alineados, axis=0)
corr = [float(np.corrcoef(prom, s)[0, 1]) for s in alineados]
# Segunda pasada: fuera los tics mal detectados (correlación < 0,5) y se realinean con el promedio limpio.
buenos = [i for i, c in zip(ini, corr) if c >= 0.5]
alineados = []
for i in buenos:
    mejor = max(range(-lag, lag + 1), key=lambda d: float(np.dot(prom, ventana(i + d))))
    alineados.append(ventana(i + mejor))
prom = np.mean(alineados, axis=0)
corr2 = [float(np.corrcoef(prom, s)[0, 1]) for s in alineados]

# Fundido de entrada 2 ms y de salida en los últimos 50 ms.
fi, fo = int(0.002 * r), int(0.05 * r)
prom[:fi] *= np.linspace(0, 1, fi)
prom[-fo:] *= np.linspace(1, 0, fo) ** 2
y = resample_poly(prom, 147, 320)            # 48000 → 22050
y = y / np.max(np.abs(y)) * 10 ** (-1 / 20)
with wave.open(sys.argv[2], 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(22050)
    w.writeframes((y * 32767).astype('<i2').tobytes())
ruido = np.std(x[int((23.12 - T0) * r): int((23.17 - T0) * r)])
print(json.dumps({'tics': len(alineados), 'inicios_s': [round(T0 + i / r, 3) for i in ini],
                  'correlacion_1': [round(c, 2) for c in corr], 'usados': len(buenos), 'correlacion_2': [round(c, 2) for c in corr2],
                  'duracion_s': round(len(y) / 22050, 3), 'pico_tic_sobre_ruido_db':
                  round(20 * np.log10(np.max(np.abs(alineados[0])) / ruido), 1)}))
