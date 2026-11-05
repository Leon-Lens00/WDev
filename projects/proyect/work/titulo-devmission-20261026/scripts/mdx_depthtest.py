"""Let the title background model be depth tested (Dev Mission title v6c, 27/10/2026).

Every layer of the nebula storm (ModelEditor tormenta-nebula-v8, Nebula_PlusZ.mdx) has NoDepthTest (0x40) and
NoDepthSet (0x80), so where it lands in the draw order decides whether it covers the title pictures (v6b: they
were darkened at height 300, right at 1000). This clears only NoDepthTest on every layer. NoDepthSet stays, so the
nebula still writes no depth and its own layers blend over each other exactly as before; what changes is that
anything already in the depth buffer and nearer the camera (the pictures, the terrain) is no longer drawn over.
Geometry, bounds, textures, filter modes and animation are untouched; the user's model is not modified.

MDX 800 layout walked here: chunk MTLS = materials (u32 inclusive size, u32 priority plane, u32 flags, 'LAYS',
u32 count, layers); layer = u32 inclusive size, u32 filter mode, u32 shading flags, ...

Usage: mdx_depthtest.py IN_MDX OUT_MDX
"""
from pathlib import Path
import json, struct, sys

NO_DEPTH_TEST, NO_DEPTH_SET = 0x40, 0x80

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    assert src[:4] == b'MDLX'
    out = bytearray(src)
    o, mtls = 4, None
    while o < len(src):
        tag, size = src[o:o + 4], struct.unpack_from('<I', src, o + 4)[0]
        if tag == b'MTLS':
            mtls = (o + 8, o + 8 + size)
        o += 8 + size
    assert o == len(src) and mtls, 'chunk walk'
    o, end = mtls
    materials = layers = cleared = 0
    while o < end:
        msize = struct.unpack_from('<I', src, o)[0]
        assert src[o + 12:o + 16] == b'LAYS'
        n = struct.unpack_from('<I', src, o + 16)[0]
        lo = o + 20
        for _ in range(n):
            lsize, _filter, flags = struct.unpack_from('<III', src, lo)
            assert flags & NO_DEPTH_SET, ('layer without NoDepthSet', lo)
            if flags & NO_DEPTH_TEST:
                struct.pack_into('<I', out, lo + 8, flags & ~NO_DEPTH_TEST)
                cleared += 1
            layers += 1
            lo += lsize
        assert lo == o + msize, 'layer walk'
        materials += 1
        o += msize
    assert o == end
    Path(sys.argv[2]).write_bytes(bytes(out))
    print(json.dumps({'materials': materials, 'layers': layers, 'cleared': cleared, 'bytes': len(out)}))
