#!/usr/bin/env python3
"""Añade a un cuadrado de zona_clic un GEOA con alfa 0 desde Death y acorta Death, para que DestroyEffect lo quite de golpe.

Uso: muerte_rapida.py ENTRADA.mdx SALIDA.mdx
"""
from pathlib import Path
import struct, sys

b = Path(sys.argv[1]).read_bytes()
cs, i = [], 4
while i < len(b):
    t, n = b[i:i + 4], struct.unpack('<I', b[i + 4:i + 8])[0]
    cs.append([t, bytearray(b[i + 8:i + 8 + n])])
    i += 8 + n
assert b'GEOA' not in [c[0] for c in cs]
salida = []
for t, body in cs:
    if t == b'SEQS':
        for k in range(0, len(body), 132):
            nombre = bytes(body[k:k + 80]).split(b'\0')[0]
            ini, fin = struct.unpack('<2I', body[k + 80:k + 88])
            if nombre == b'Death':
                muerte = ini
                body[k + 84:k + 88] = struct.pack('<I', ini + 33)
    salida.append([t, body])
    if t == b'GEOS':
        llaves = [(0, 1.0), (muerte, 0.0)]
        pista = b'KGAO' + struct.pack('<IiI', len(llaves), 0, 0xffffffff) + b''.join(struct.pack('<If', *l) for l in llaves)
        cuerpo = struct.pack('<fI3fI', 1.0, 0, 1.0, 1.0, 1.0, 0) + pista
        salida.append([b'GEOA', bytearray(struct.pack('<I', len(cuerpo) + 4) + cuerpo)])
Path(sys.argv[2]).write_bytes(b'MDLX' + b''.join(t + struct.pack('<I', len(c)) + bytes(c) for t, c in salida))
