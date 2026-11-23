#!/usr/bin/env python3
"""v21e: añade al war3map.imp (lista de imports del editor) las rutas de los TSV (ruta del MPQ <tab> archivo).
Uso: imp_v21e.py ENTRADA.imp SALIDA.imp TSV...
"""
import struct, sys
from pathlib import Path

imp = Path(sys.argv[1]).read_bytes()
iv, n = struct.unpack_from('<II', imp, 0)
assert iv == 1
i, ent = 8, []
for _ in range(n):
    j = imp.index(b'\0', i + 1)
    ent.append((imp[i], imp[i + 1:j].decode('utf-8')))
    i = j + 1
assert i == len(imp)
ya = {p.lower() for _, p in ent}
nuevos = 0
for tsv in sys.argv[3:]:
    for l in open(tsv, encoding='utf-8'):
        p = l.rstrip('\n').split('\t')[0]
        if p and p.lower() not in ya:
            ent.append((13, p))
            ya.add(p.lower())
            nuevos += 1
Path(sys.argv[2]).write_bytes(struct.pack('<II', 1, len(ent)) + b''.join(bytes([f]) + p.encode() + b'\0' for f, p in ent))
print('imp', n, '->', len(ent), '(', nuevos, 'nuevos )')
