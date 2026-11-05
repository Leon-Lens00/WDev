#!/usr/bin/env python3
"""Minimapa BLP1 paletizado de 256x256 desde una imagen PPM P6 ya reducida a 255 colores. Uso: minimapa_v13a.py IN_PPM OUT_BLP"""
from pathlib import Path
import re
import struct
import sys

b = Path(sys.argv[1]).read_bytes()
m = re.match(rb'P6\s+(\d+)\s+(\d+)\s+255\s', b)
w, h = int(m[1]), int(m[2])
assert (w, h) == (256, 256)
d = b[m.end():]
pal, idx = {}, bytearray()
for i in range(0, len(d), 3):
    c = d[i:i + 3]
    idx.append(pal.setdefault(c, len(pal)))
assert len(pal) <= 256, len(pal)
paleta = b''.join(bytes((c[2], c[1], c[0], 255)) for c in pal) + b'\0' * (4 * (256 - len(pal)))
off = [156 + 1024] + [0] * 15
siz = [len(idx)] + [0] * 15
Path(sys.argv[2]).write_bytes(b'BLP1' + struct.pack('<IIIIII', 1, 0, 256, 256, 5, 0)
                              + struct.pack('<16I', *off) + struct.pack('<16I', *siz) + paleta + bytes(idx))
