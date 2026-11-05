"""Objects for v12x (Dev Mission, 31/10/2026): wave units with 25% of their life. Soldado 420 to 105, Campesino 220 to 55.

Only the two melee types of the waves change; 'dumi' derives from hfoo but sets its own life.
Usage: objetos_v12x.py IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys

VIDA = {b'hfoo': 105, b'hpea': 55}

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, originales = struct.unpack_from('<II', src, 0)
    assert originales == 0, 'the original table is expected empty'
    filas = b''.join(tipo + b'\0\0\0\0' + struct.pack('<I', 1) + b'uhpm' + struct.pack('<Ii', 0, v) + b'\0\0\0\0' for tipo, v in VIDA.items())
    Path(sys.argv[2]).write_bytes(struct.pack('<II', version, len(VIDA)) + filas + src[8:])
    print('ok')
