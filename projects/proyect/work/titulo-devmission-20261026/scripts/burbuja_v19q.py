#!/usr/bin/env python3
"""v19q (19/11/2026): las burbujas de v19q con el mismo método de burbuja_v19p.py.
- carta: la carta pasa de 330 × 480 a 330 × 540 px (Leon: "los cuadros podrian ser mas grande o largos"); el contorno
  pasa de 172 × 248 a 172 × 278 (medio ancho y medio alto), con los mismos 7-8 px de margen.
- cabecera: el cuadro del título, de 760 × 80 px (Leon: "en la zona del titulo tambien apliquemos el efecto de contorno
  junto a un cuadro"): contorno de 388 × 48 con esquinas de radio 16. En una forma tan apaisada la escala radial de
  v19p engordaría el anillo en los extremos (× 5,9) y lo afinaría arriba y abajo (× 0,7); aquí la banda exterior del
  disco (r ≥ R − W) se lleva al contorno con un grosor fijo de K px por unidad, y el interior se comprime en lo que queda.
- panel y detalle (v19r): 340 × 310 y 340 × 290 px, contornos 178 × 163 y 178 × 153.
Uso: burbuja_v19q.py carta|cabecera|panel|detalle TIENDA_ESFERA_MDX SALIDA_MDX
"""
from math import atan2, cos, hypot, sin
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import burbuja_v19p as bp  # noqa: E402

W, K = 15., 2.


def forma_banda(y, z):
    r = hypot(y, z)
    if r < 1e-9:
        return 0., 0.
    t = atan2(z, y)
    rh = bp.rho(t)
    q = rh + (r - bp.R) * K if r >= bp.R - W else (rh - W * K) * r / (bp.R - W)
    return q * cos(t), q * sin(t)


def disco_banda(y, z):
    q = hypot(y, z)
    if q < 1e-9:
        return 0., 0.
    t = atan2(z, y)
    rh = bp.rho(t)
    r = bp.R + (q - rh) / K if q >= rh - W * K else q * (bp.R - W) / (rh - W * K)
    return r * cos(t), r * sin(t)


tipo = sys.argv[1]
if tipo == 'carta':
    bp.A, bp.B, bp.RC = 172., 278., 20.
elif tipo == 'cabecera':
    bp.A, bp.B, bp.RC = 388., 48., 16.
    assert min(bp.rho(i / 50) for i in range(315)) - W * K > 10
    bp.forma, bp.disco = forma_banda, disco_banda
    for y, z in ((10., 5.), (60., 30.), (0., 70.), (-50., 50.)):
        a, b = disco_banda(*forma_banda(y, z))
        assert abs(a - y) < 1e-6 and abs(b - z) < 1e-6
elif tipo == 'panel':            # v19r: panel de iconos de 340 × 310
    bp.A, bp.B, bp.RC = 178., 163., 20.
elif tipo == 'detalle':          # v19r: cuadro del detalle de 340 × 290
    bp.A, bp.B, bp.RC = 178., 153., 20.
else:
    sys.exit('carta|cabecera|panel|detalle')
out, info = bp.rehacer(Path(sys.argv[2]).read_bytes())
Path(sys.argv[3]).write_bytes(out)
print('burbuja', tipo, info, 'piezas', len(bp.piezas()))
