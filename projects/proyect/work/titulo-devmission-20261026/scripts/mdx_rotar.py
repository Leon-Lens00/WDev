"""Turn a unit model to face the title's top-down camera (Dev Mission presentation v9w, 29/10/2026).

The title camera looks down -Z (screen up = world -X, screen right = world +Y). A unit model stands along +Z
facing +X, so from above only its back is seen. One helper is added (ids right after the last helper, later nodes
renumbered, a static KGRT key on a new global sequence) and every former root node becomes its child, rotating
the whole model about its origin: model up (+Z) to screen up (world -X), model front (+X) towards the camera
(+Z) turned A degrees to screen right (+Y), for a 3/4 view. The unit is created facing 0 (model axes = world axes).
Geometry, materials, textures and sequences are unchanged.

Usage: mdx_rotar.py IN_MDX OUT_MDX A
"""
from pathlib import Path
import json, math, struct, sys
import numpy as np
sys.path.insert(0, str(Path(__file__).resolve().parent))
import mdx_cizalla as mc

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    a = math.radians(float(sys.argv[3]))
    r = np.array([[0, 0, -1], [math.sin(a), math.cos(a), 0], [math.cos(a), -math.sin(a), 0]])
    assert abs(np.linalg.det(r) - 1) < 1e-9
    q = mc.quat(r)
    assert np.allclose(mc.rotmat(q), r, atol=1e-6)

    cs = mc.chunks(src)
    pivots = next(d for t, d in cs if t == b'PIVT')
    heads = [(t, d, o) for t, d in cs if t in mc.NODES for o in mc.node_offsets(t, d)]
    ids = [struct.unpack_from('<I', d, o + 84)[0] for _, d, o in heads]
    assert ids == list(range(len(ids))) and len(pivots) == 12 * len(ids)
    h = max(k for k, (t, _, _) in enumerate(heads) if t == b'HELP') + 1
    shift = lambda i: i + 1 if i != mc.NONE and i >= h else i
    roots = 0
    for t, d, o in heads:
        oid, par = struct.unpack_from('<II', d, o + 84)
        roots += par == mc.NONE
        struct.pack_into('<II', d, o + 84, shift(oid), h if par == mc.NONE else shift(par))
    pivots[12 * h:12 * h] = struct.pack('<3f', 0, 0, 0)
    tags = [t for t, _ in cs]
    if b'GLBS' not in tags:
        cs.insert(tags.index(b'SEQS') + 1, [b'GLBS', bytearray()])
    glbs = next(d for t, d in cs if t == b'GLBS')
    gs = len(glbs) // 4
    glbs += struct.pack('<I', 1000)
    next(d for t, d in cs if t == b'HELP').extend(mc.helper('Rotar', h, mc.NONE, (b'KGRT', q), gs))
    out = b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in cs)
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'out': sys.argv[2], 'quat': list(q), 'roots': roots, 'helper': h, 'global_seq': gs}))
