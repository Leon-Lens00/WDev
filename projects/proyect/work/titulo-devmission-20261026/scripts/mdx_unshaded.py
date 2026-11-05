"""Make every material layer of an MDX unshaded and unfogged (Dev Mission title v9z, 29/10/2026).

The hydra is turned to the title camera (mdx_rotar.py), so the faces it shows are lit only by the ambient light
and its body came out black after the reveal. Unshaded layers show the textures' own colours, flat like the
reference's sprite. The team colour and glow (replaceable textures 1/2) become the files of colour 02 (teal,
the hydra's own): the body is team colour under its skin (Blend), and the dummy player's colour made it black
(v10). Pointing that layer to the skin instead (v10b-e) left it black too: the skin is black where it lets the
team colour through. Layers are also unfogged (0x20), as the title's pictures: with the
skin under the body the hydra's far half still came out flat black (v10b), the terrain fog. That was not it
either (v10c): the flat black shape was geoset 3, a plate at the feet (z 3-26, 325 x 223, Transparent with
Textures\\gutz.blp), seen tilted to the camera. HIDE lists geosets whose alpha (GEOA KGAO keys) is set to 0.
Nothing else changes.

Usage: mdx_unshaded.py IN_MDX OUT_MDX [HIDE,...]
"""
from pathlib import Path
import json, struct, sys

if __name__ == '__main__':
    b = bytearray(Path(sys.argv[1]).read_bytes())
    hide = {int(x) for x in sys.argv[3].split(',')} if len(sys.argv) > 3 else set()
    o, layers, team, hidden = 4, 0, 0, 0
    tex = []
    while o < len(b):
        t, n = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
        if t == b'TEXS':
            for k in range(n // 268):
                e = o + 8 + 268 * k
                rid = struct.unpack_from('<I', b, e)[0]
                if rid in (1, 2):
                    name = ('ReplaceableTextures\\TeamColor\\TeamColor02.blp' if rid == 1
                            else 'ReplaceableTextures\\TeamGlow\\TeamGlow02.blp')
                    struct.pack_into('<I', b, e, 0)
                    b[e + 4:e + 264] = name.encode().ljust(260, b'\0')
                    team += 1
        o += 8 + n
    o = 4
    while o < len(b):
        t, n = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
        if t == b'MTLS':
            m = o + 8
            while m < o + 8 + n:
                size = struct.unpack_from('<I', b, m)[0]
                assert b[m + 12:m + 16] == b'LAYS'
                count = struct.unpack_from('<I', b, m + 16)[0]
                l = m + 20
                for _ in range(count):
                    flags = struct.unpack_from('<I', b, l + 8)[0]
                    struct.pack_into('<I', b, l + 8, flags | 0x21)
                    layers += 1
                    l += struct.unpack_from('<I', b, l)[0]
                m += size
            assert m == o + 8 + n
        if t == b'GEOA':
            g = o + 8
            while g < o + 8 + n:
                size = struct.unpack_from('<I', b, g)[0]
                if struct.unpack_from('<I', b, g + 24)[0] in hide:
                    struct.pack_into('<f', b, g + 4, 0.0)
                    k = g + 28
                    assert b[k:k + 4] == b'KGAO'
                    count, interp = struct.unpack_from('<II', b, k + 4)
                    step = 8 if interp < 2 else 16
                    for j in range(count):
                        struct.pack_into('<f', b, k + 16 + step * j + 4, 0.0)
                    hidden += 1
                g += size
        o += 8 + n
    Path(sys.argv[2]).write_bytes(b)
    print(json.dumps({'out': sys.argv[2], 'layers': layers, 'team_textures': team, 'hidden_geosets': hidden, 'bytes': len(b)}))
