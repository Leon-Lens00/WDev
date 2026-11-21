#!/usr/bin/env python3
"""v16l (08/11/2026): SueloAzur.blp con el mismo formato que NegroSolido.blp (BLP1 de paleta, 64 x 64, alfa de 8 bits,
7 mipmaps), que ya carga en el juego. Copia NegroSolido.blp y sólo cambia las 256 entradas de la paleta al azul
celeste pastel (180, 220, 245); índices y alfa quedan igual. El BLP de 8 x 8 sin alfa de v16k es sospechoso del cierre
del juego a los ~25 s de la prueba de v16k-prueba.
Uso: suelo_v16l.py NegroSolido.blp SALIDA.blp
"""
from pathlib import Path
import struct, sys

r, g, b = 180, 220, 245
d = bytearray(Path(sys.argv[1]).read_bytes())
assert d[:4] == b'BLP1' and struct.unpack_from('<6I', d, 4) == (1, 8, 64, 64, 4, 1)
d[156:156 + 1024] = bytes((b, g, r, 0)) * 256
Path(sys.argv[2]).write_bytes(bytes(d))
print('SueloAzur v16l', len(d))
