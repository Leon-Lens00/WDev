#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): copia de dummy.mdx (Vexorian) sin la rotación de Bone_Chest (KGRT, 180 claves).
Conserva las 181 secuencias, los huesos, las tres uniones y los pivotes: el motor ya no tiene nada que animar.
Uso: dummy_plano.py dummy.mdx SALIDA.mdx
"""
from pathlib import Path
import struct, sys

b = Path(sys.argv[1]).read_bytes()
assert b[:4] == b'MDLX'
out, i = [b[:4]], 4
while i < len(b):
    tag, n = b[i:i + 4], struct.unpack_from('<I', b, i + 4)[0]
    d = b[i + 8:i + 8 + n]
    if tag == b'HELP':
        nd, o = [], 0
        while o < len(d):
            sz = struct.unpack_from('<I', d, o)[0]
            nodo = d[o:o + sz]
            if len(nodo) > 96:
                assert nodo[96:100] == b'KGRT' and nodo[4:14] == b'Bone_Chest', nodo[:20]
                nodo = struct.pack('<I', 96) + nodo[4:96]
            nd.append(nodo)
            o += sz
        d = b''.join(nd)
    out.append(tag + struct.pack('<I', len(d)) + d)
    i += 8 + n
Path(sys.argv[2]).write_bytes(b''.join(out))
print('dummy plano:', len(b), '->', sum(map(len, out)), 'bytes')
