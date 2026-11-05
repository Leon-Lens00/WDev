"""Objects for v12s (Dev Mission, 31/10/2026): dash on D and S in the middle of the card, Shots Vol. I in the top right corner.

Usage: objetos_v12s.py IN_W3A OUT_W3A
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

NONE = b'\0\0\0\0'
CAMBIOS = {b'Ard1': (b'D', b'Dash (|cffffcc00D|r)', 1, 1), b'Ard2': (b'S', b'Dash atras (|cffffcc00S|r)', 2, 1), b'Arp1': (b'W', None, 3, 0)}

if __name__ == '__main__':
    a_in, a_out = sys.argv[1:3]
    src = Path(a_in).read_bytes()
    version, tables = parse_w3a(src)
    assert encode_w3a(version, tables) == src, 'round trip differs'
    hechos = 0
    for t in tables:
        for k, (base, new, fields) in enumerate(t):
            if new not in CAMBIOS:
                continue
            key, tip, px, py = CAMBIOS[new]
            out = []
            for f in fields:
                f = list(f)
                if f[0] == b'ahky':
                    f[4] = key
                elif f[0] == b'atp1' and tip:
                    f[4] = tip
                elif f[0] == b'abpx':
                    f[4] = struct.pack('<i', px)
                elif f[0] == b'abpy':
                    f[4] = struct.pack('<i', py)
                out.append(tuple(f))
            t[k] = (base, new, out)
            hechos += 1
    assert hechos == 3
    Path(a_out).write_bytes(encode_w3a(version, tables))
    print('ok')
