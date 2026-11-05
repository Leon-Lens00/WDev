"""Shrink the bounds of the title background model (Dev Mission title v6b, 27/10/2026).

In v6 the nebula storm (ModelEditor tormenta-nebula-v8, Nebula_PlusZ.mdx) darkened the blended title pictures
at scale 1 but not at scale 0.5. Its every extent has BoundsRadius 1400, more than its distance to the camera
(~1230), so the translucent sort seems to treat it as nearer than the pictures (depth 400) and draws it last.
This writes a copy whose extents (model, Stand sequence, each geoset and its per-sequence extent: 254 in V8,
each an MDX extent = radius, minimum xyz, maximum xyz) are replaced by a small box around the origin, so the
model should sort behind the pictures. Geometry, materials and animation are untouched. The user's model is
not modified.

Usage: mdx_bounds.py IN_MDX OUT_MDX [RADIUS]
"""
from pathlib import Path
import json, struct, sys

OLD_RADIUS = 1400.0

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    radius = float(sys.argv[3]) if len(sys.argv) > 3 else 200.0
    h = radius / 2
    new = struct.pack('<7f', radius, -h, -h, -h / 2, h, h, h / 4)
    assert src[:4] == b'MDLX'
    key = struct.pack('<f', OLD_RADIUS)
    out = bytearray(src)
    count, i = 0, src.find(key)
    while i >= 0:
        r, *ext = struct.unpack_from('<7f', src, i)
        assert all(ext[k] <= ext[k + 3] for k in range(3)), (i, ext)
        out[i:i + 28] = new
        count += 1
        i = src.find(key, i + 28)
    assert count == 254, count
    Path(sys.argv[2]).write_bytes(bytes(out))
    print(json.dumps({'extents': count, 'radius': radius, 'bytes': len(out)}))
