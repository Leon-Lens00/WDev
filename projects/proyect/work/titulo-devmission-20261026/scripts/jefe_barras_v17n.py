#!/usr/bin/env python3
"""Barras del jefe que crecen de derecha a izquierda, v17n (14/11/2026).

En HealthJefe{n}.mdx (v17m) el hueso Life escala en Y (la horizontal de la pantalla) el relleno, con el pivote en el
extremo izquierdo (y 7,635). Con el pivote en el extremo derecho (y 125,799, el borde del relleno junto al icono) crece
y se vacía hacia la izquierda, al contrario que la barra del jugador. Sólo cambia ese float del PIVT.
Uso: jefe_barras_v17n.py DIR_CON_HealthJefe{n}.mdx SALIDA_DIR
"""
from pathlib import Path
import struct, sys

RONDAS = '23456789A'
IZQ, DER = 7.635201454162598, 125.79903411865234
out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
for c in RONDAS:
    b = bytearray(Path(sys.argv[1], f'HealthJefe{c}.mdx').read_bytes())
    o, piv = 4, None
    while o < len(b):
        t, n = bytes(b[o:o + 4]), struct.unpack_from('<I', b, o + 4)[0]
        if t == b'PIVT':
            assert n == 24
            piv = o + 8
        o += 8 + n
    assert struct.unpack_from('<3f', b, piv + 12) == struct.unpack('<3f', struct.pack('<3f', 0., IZQ, -11.963536262512207))
    struct.pack_into('<f', b, piv + 16, DER)
    (out / f'HealthJefe{c}.mdx').write_bytes(bytes(b))
    print(c, 'pivote', DER)
