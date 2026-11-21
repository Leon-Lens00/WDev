#!/usr/bin/env python3
"""LinternaHaz.blp: abanico de la linterna visto desde arriba, para un cuadro aditivo (sin alfa; negro = nada).
Eje u (columnas) a lo largo del haz, 0..L; eje v (filas) a lo ancho, -W..W. Vértice del cono en X0; semiángulo A.
Uso: linterna_haz.py SALIDA.blp [VISTA.png]"""
from pathlib import Path
import math
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from PIL import Image
from efectos_v14h import blp1

L, W, X0, A, N = 1400., 700., 20., math.radians(26), 256


def suave(a, b, t):
    t = min(1., max(0., (t - a) / (b - a)))
    return t * t * (3 - 2 * t)


im = Image.new('RGB', (N, N))
px = im.load()
for i in range(N):
    x = (i + .5) / N * L
    for j in range(N):
        y = ((j + .5) / N * 2 - 1) * W
        ang = math.atan2(abs(y), max(1e-3, x - X0))
        borde = 1 - suave(A * .7, A, ang) if x > X0 else 0
        largo = suave(X0, X0 + 90, x) * (1 - x / L) ** 1.2
        nucleo = .55 + .45 * (1 - suave(0, A * .6, ang))
        k = .85 * borde * largo * nucleo
        px[i, j] = tuple(round(255 * min(1, k * c)) for c in (1., .9, .7))
Path(sys.argv[1]).write_bytes(blp1(im))
if len(sys.argv) > 2:
    im.save(sys.argv[2])
