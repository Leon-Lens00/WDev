"""Objects for v12r (Dev Mission, 31/10/2026): 'Ard1' and 'Ard2' of the dash, and its 21 imports with their internal names.

Usage: objetos_v12r.py DELIVERY IN_W3A OUT_W3A IN_IMP OUT_IMP
"""
from pathlib import Path
import json
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

NONE = b'\0\0\0\0'


def value(t, v):
    return v.encode() if t == 3 else struct.pack('<f', v) if t == 2 else struct.pack('<i', v)


if __name__ == '__main__':
    delivery, a_in, a_out, imp_in, imp_out = sys.argv[1:6]
    src = Path(a_in).read_bytes()
    version, tables = parse_w3a(src)
    assert encode_w3a(version, tables) == src, 'round trip differs'
    used = {r[1] for t in tables for r in t}
    for row in json.loads(Path(delivery, 'objetos-Ard1-Ard2.json').read_text(encoding='utf-8')):
        new = row['id'].encode()
        assert new not in used, new
        tables[1].append((row['base'].encode(), new, [(f['campo'].encode(), f['tipo'], f['nivel'], f['dato'], value(f['tipo'], f['valor']), NONE)
                                                      for f in row['campos']]))
    Path(a_out).write_bytes(encode_w3a(version, tables))

    imp = Path(imp_in).read_bytes()
    n = struct.unpack_from('<I', imp, 4)[0]
    paths = [e['internal'] for e in json.loads(Path(delivery, 'imports/imports.json').read_text(encoding='utf-8'))['imports']]
    assert not any(p.encode() in imp for p in paths)
    Path(imp_out).write_bytes(struct.pack('<II', 1, n + len(paths)) + imp[8:] + b''.join(bytes([13]) + p.encode() + b'\0' for p in paths))
    print('ok', len(paths))
