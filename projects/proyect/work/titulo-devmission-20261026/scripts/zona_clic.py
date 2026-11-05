"""Invisible rectangles that catch the title screen's trackable events (Dev Mission title, 26/10/2026).

Copy of negro-terreno-20261026/scripts/negro_plano.py generalised to a rectangle: one quad on the XY plane at
height Z, textured with TitleHit.blp (alpha 0 everywhere) under filter blend (2), so it is not drawn but its
geometry is still there for the trackable. The Start rectangle sits at z 20 and the background one at z 8, so
the Start one is nearer the top-down camera where they overlap.

Usage: zona_clic.py BASE_MDX OUT_MDX HALF_X HALF_Y Z [TEXTURE] [FILTER] [LAYER_FLAGS]
(v14k: LAYER_FLAGS opcional, para las zonas pintadas de prueba; sin él, el valor de siempre.)
"""
from pathlib import Path
import json, struct, sys

BASE, OUT = Path(sys.argv[1]), Path(sys.argv[2])
HX, HY, Z = float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5])
TEX = sys.argv[6] if len(sys.argv) > 6 else 'war3mapImported\\TitleHit.blp'
FILTER = int(sys.argv[7]) if len(sys.argv) > 7 else 2
FLAGS = int(sys.argv[8], 0) if len(sys.argv) > 8 else 0x1 | 0x10 | 0x20   # unshaded, two sided, unfogged
RADIUS = (HX * HX + HY * HY + Z * Z) ** 0.5
EXT = struct.pack('<7f', RADIUS, -HX, -HY, Z, HX, HY, Z)


def chunks(b):
    i, out = 4, []
    while i < len(b):
        t, n = b[i:i + 4], struct.unpack('<I', b[i + 4:i + 8])[0]
        out.append([t, bytearray(b[i + 8:i + 8 + n])])
        i += 8 + n
    return out


def model():
    cs = chunks(BASE.read_bytes())
    for c in cs:
        t, body = c
        if t == b'MODL':
            body[80 + 260:80 + 260 + 28] = EXT
        elif t == b'SEQS':
            assert len(body) % 132 == 0
            for k in range(0, len(body), 132):
                body[k + 104:k + 132] = EXT
        elif t == b'TEXS':
            c[1] = bytearray(struct.pack('<I256sII', 0, TEX.encode(), 0, 0))
        elif t == b'MTLS':
            assert body[12:16] == b'LAYS' and struct.unpack('<2I', body[16:24]) == (1, 0x1c)
            body[24:28] = struct.pack('<I', FILTER)     # 0 none (opaque), 2 blend
            body[28:32] = struct.pack('<I', FLAGS)
            body[32:36] = struct.pack('<I', 0)          # texture 0
        elif t == b'GEOS':
            assert body[4:8] == b'VRTX' and struct.unpack('<I', body[8:12])[0] == 4
            # Same order as the base quad, whose faces are (0, 1, 2) and (3, 2, 1): 0 top left, 1 bottom left,
            # 2 top right, 3 bottom right, seen from above with +Y up.
            quad = [(-HX, HY, Z), (-HX, -HY, Z), (HX, HY, Z), (HX, -HY, Z)]
            body[12:60] = b''.join(struct.pack('<3f', *v) for v in quad)
            assert body[60:64] == b'NRMS' and struct.unpack('<I', body[64:68])[0] == 4
            body[68:116] = struct.pack('<3f', 0, 0, 1) * 4
            k = body.find(b'PVTX')
            assert struct.unpack('<6H', body[k + 8:k + 20]) == (0, 1, 2, 3, 2, 1)
            k = body.find(b'UVBS')
            assert struct.unpack('<I', body[k + 4:k + 8])[0] == 4
            body[k + 8:k + 40] = struct.pack('<8f', 0, 0, 0, 1, 1, 0, 1, 1)
            k = body.find(b'MATS')
            nm = struct.unpack('<I', body[k + 4:k + 8])[0]
            k += 8 + 4 * nm + 12
            body[k:k + 28] = EXT
            n = struct.unpack('<I', body[k + 28:k + 32])[0]
            for j in range(n):
                body[k + 32 + 28 * j:k + 60 + 28 * j] = EXT
    return b'MDLX' + b''.join(t + struct.pack('<I', len(b)) + bytes(b) for t, b in cs)


if __name__ == '__main__':
    blob = model()
    OUT.write_bytes(blob)
    print(json.dumps({'mdx': str(OUT), 'bytes': len(blob), 'size': [2 * HX, 2 * HY], 'z': Z, 'texture': TEX,
                      'filter': FILTER, 'layer_flags': hex(FLAGS)}, indent=2))
