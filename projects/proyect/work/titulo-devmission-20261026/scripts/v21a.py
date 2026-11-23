#!/usr/bin/env python3
"""v21a (21/11/2026): Leon: vidas base a 25 (Vidas_INICIO 3 -> 25). Nada más cambia.
Uso: v21a.py ENTRADA.j SALIDA.j [prueba]   (normal de v20z; prueba de v20z-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
viejo = 'constant integer Vidas_INICIO = 3\r\n' if '\r\n' in src else 'constant integer Vidas_INICIO = 3\n'
assert src.count(viejo) == 1
src = src.replace(viejo, viejo.replace('= 3', '= 25'))
if prueba:
    for v, n in (('lat\\\\v20z-', 'lat\\\\v21a-'), ('v20z-don.txt', 'v21a-don.txt')):
        assert v in src, v
        src = src.replace(v, n)
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21a', 'prueba' if prueba else 'normal')
