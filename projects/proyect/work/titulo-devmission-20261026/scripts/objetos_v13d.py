#!/usr/bin/env python3
"""Objects for v13d (Dev Mission, 01/11/2026): the swamp wave units.

Each bolt deals 25, so life sets the hits to kill. Damage is lowered too: the hero has 90 life. Abilities are cleared: waves only attack.
Usage: objetos_v13d.py IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys

# type: life, base damage, dice, sides. Damage per hit is base + dice * 1..sides.
UNIDADES = {
    b'nmcf': (60, 9, 1, 2),
    b'nlpr': (50, 9, 1, 2),
    b'ntrh': (50, 5, 1, 2),
    b'nmtw': (105, 13, 1, 2),
    b'nmsn': (80, 7, 1, 2),
    b'nmmu': (190, 13, 1, 3),
    b'nlds': (100, 8, 1, 2),
    b'ntrg': (310, 17, 1, 3),
    b'nnsw': (75, 6, 1, 2),
    b'ntrd': (600, 29, 1, 6),
}


def entero(campo, v):
    return campo + struct.pack('<Ii', 0, v) + b'\0\0\0\0'


def fila(tipo, vida, base, dados, caras):
    campos = [entero(b'uhpm', vida), entero(b'ua1b', base), entero(b'ua1d', dados), entero(b'ua1s', caras),
              b'uabi' + struct.pack('<I', 3) + b'\0' + b'\0\0\0\0']
    return tipo + b'\0\0\0\0' + struct.pack('<I', len(campos)) + b''.join(campos)


if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, originales = struct.unpack_from('<II', src, 0)
    assert not any(t + b'\0\0\0\0' in src for t in UNIDADES)
    filas = b''.join(fila(t, *v) for t, v in UNIDADES.items())
    Path(sys.argv[2]).write_bytes(struct.pack('<II', version, originales + len(UNIDADES)) + filas + src[8:])
    print('ok', len(UNIDADES))
