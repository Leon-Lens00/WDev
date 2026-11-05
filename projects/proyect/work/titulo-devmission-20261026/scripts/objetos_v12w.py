"""Objects for v12w (Dev Mission, 31/10/2026): 'Ard1' becomes a point cast, with the range of Shots so the controller never walks.

Usage: objetos_v12w.py IN_W3A OUT_W3A
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

TEXTO = b'Avanza 450 en 0.50 s hacia el punto elegido. La distancia es siempre la misma.'
CAMBIOS = {b'aran': struct.pack('<f', 90000.), b'Ncl2': struct.pack('<i', 2), b'Ncl6': b'shockwave', b'aub1': TEXTO}

if __name__ == '__main__':
    a_in, a_out = sys.argv[1:3]
    src = Path(a_in).read_bytes()
    version, tables = parse_w3a(src)
    assert encode_w3a(version, tables) == src, 'round trip differs'
    hechos = 0
    for t in tables:
        for k, (base, new, fields) in enumerate(t):
            if new != b'Ard1':
                continue
            out = []
            for f in fields:
                f = list(f)
                if f[0] in CAMBIOS:
                    f[4] = CAMBIOS[f[0]]
                    hechos += 1
                out.append(tuple(f))
            t[k] = (base, new, out)
    assert hechos == len(CAMBIOS)
    Path(a_out).write_bytes(encode_w3a(version, tables))
    print('ok')
