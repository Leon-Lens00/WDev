#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): versiones ligeras de la bala de Toy Soldiers (Bullet2.mdx, toysoldiers_156 - Open.w3x,
copiada en el laboratorio bench-misiles-toy-20261110 como ToyBench\\Bullet2.mdx).

Bullet2: 2 cuadrados planos (4 vértices cada uno) que giran hacia la cámara (Shot = trazo fino 185 × 3,4;
Shot2 = brillo 255 × 33), y 2 emisores (Explosion, Dust) visibles sólo al morir (≈ 9 partículas por bala).
- ligera1: sin los 2 emisores (son los ObjectId 4 y 5, los últimos: quitarlos no mueve los demás; se quitan sus pivotes).
- ligera2: ligera1 y sólo el brillo (geoset 1): un único cuadrado. El hueso Shot queda sin geoset (-1); Shot2 apunta al 0.
Uso: bala_ligera.py Bullet2.mdx LIGERA1.mdx LIGERA2.mdx
"""
from pathlib import Path
import struct, sys

b = Path(sys.argv[1]).read_bytes()
assert b[:4] == b'MDLX'


def trozos(b):
    i, r = 4, []
    while i < len(b):
        tag, n = b[i:i + 4], struct.unpack_from('<I', b, i + 4)[0]
        r.append([tag, bytearray(b[i + 8:i + 8 + n])])
        i += 8 + n
    return r


def armar(ch):
    return b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in ch)


def lista(d, total_incluye=True):
    o, r = 0, []
    while o < len(d):
        sz = struct.unpack_from('<I', d, o)[0]
        r.append(d[o:o + sz]); o += sz
    return r


ch = trozos(b)
tags = [t for t, _ in ch]
# --- ligera1: sin emisores ---
pre = dict(ch)[b'PRE2']
ids = [struct.unpack_from('<i', e, 4 + 84)[0] for e in lista(pre)]
assert ids == [4, 5], ids
piv = dict(ch)[b'PIVT']
assert len(piv) == 6 * 12
l1 = [[t, d] for t, d in ch if t not in (b'PRE2',)]
for x in l1:
    if x[0] == b'PIVT':
        x[1] = x[1][:4 * 12]
Path(sys.argv[2]).write_bytes(armar(l1))

# --- ligera2: además sólo el geoset 1 ---
l2 = [[t, bytearray(d)] for t, d in l1]
for x in l2:
    t, d = x
    if t == b'GEOS':
        g = lista(d); assert len(g) == 2; x[1] = bytearray(g[1])
    elif t == b'GEOA':
        g = lista(d); assert len(g) == 2
        a = bytearray(g[1]); assert struct.unpack_from('<I', a, 24)[0] == 1
        struct.pack_into('<I', a, 24, 0); x[1] = a
    elif t == b'BONE':
        o, nb = 0, bytearray()
        while o < len(d):
            nsz = struct.unpack_from('<I', d, o)[0]
            gid, ga = struct.unpack_from('<ii', d, o + nsz)
            nuevo = (-1, -1) if gid == 0 else (0, 0)
            assert (gid, ga) in ((0, 0), (1, 1))
            nb += d[o:o + nsz] + struct.pack('<ii', *nuevo); o += nsz + 8
        x[1] = nb
Path(sys.argv[3]).write_bytes(armar(l2))
print('ligera1', len(armar(l1)), 'bytes; ligera2', len(armar(l2)), 'bytes; original', len(b))
