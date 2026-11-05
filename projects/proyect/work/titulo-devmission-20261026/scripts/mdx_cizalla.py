"""Shear an effect model so that, placed off the screen centre, it looks as it does at the centre (Dev Mission
title v9u, 29/10/2026).

The title camera looks straight down with perspective. A 3D effect at a lateral offset L0 and depth d0 shows its
side: a point at height z above the unit lies nearer the eye, so it lands L0 * z / d0 further out than its base.
Shifting every point by -(L0 / d0) * z (a shear along the height) puts it back exactly: projection of
(L0 + l - L0 z / d0) / (d0 - z) = L0 / d0 + l / (d0 - z), the centred look moved to L0 / d0.

MDX nodes have no shear, but rotation x scale x rotation has (SVD: Sh = U S V^T). Three helpers are added as a
chain (ids right after the existing helpers, later nodes renumbered; A: rotation U, B: scaling S, C: rotation V^T, pivots at the origin, static keys on a new global sequence so
every sequence uses them) and every former root node becomes a child of C, so the geosets, emitters, lights and
events of the whole model are sheared. Nothing else changes (geometry, materials, textures, sequences).

The unit faces 270 (model +X = world -Y, model +Y = world +X), the title's right is world +Y and down world +X, so
for a centre at mockup pixel (px, py): model x += rY z, model y -= rX z, with rY = (px - 961) * 0.544 / 718.19
and rX = (py - 438.17) / 1.0296 * 0.302 / 387.74 (Title_WY / Title_WX per unit of depth).

Usage: mdx_cizalla.py IN_MDX OUT_MDX PX PY
"""
from pathlib import Path
import json, struct, sys
import numpy as np

NONE = 0xFFFFFFFF
NODES = (b'BONE', b'HELP', b'LITE', b'ATCH', b'PREM', b'PRE2', b'RIBB', b'EVTS', b'CLID')


def chunks(b):
    o, out = 4, []
    while o < len(b):
        t, n = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
        out.append([t, bytearray(b[o + 8:o + 8 + n])])
        o += 8 + n
    assert o == len(b)
    return out


def node_offsets(tag, d):
    """Offsets of the node headers (inclusive size, name, id, parent, flags) inside a chunk's data."""
    o, out = 0, []
    while o < len(d):
        if tag in (b'BONE', b'HELP', b'EVTS', b'CLID'):
            n = struct.unpack_from('<I', d, o)[0]
            out.append(o)
            e = o + n
            if tag == b'BONE':
                e += 8
            elif tag == b'EVTS':
                if d[e:e + 4] == b'KEVT':
                    e += 12 + 4 * struct.unpack_from('<I', d, e + 4)[0]
            elif tag == b'CLID':
                kind = struct.unpack_from('<I', d, e)[0]
                e += 4 + {0: 24, 1: 24, 2: 16, 3: 28}[kind]
            o = e
        else:
            n = struct.unpack_from('<I', d, o)[0]
            out.append(o + 4)
            o += n
    assert o == len(d), tag
    return out


def quat(m):
    w = np.sqrt(max(0.0, 1 + m[0, 0] + m[1, 1] + m[2, 2])) / 2
    x = np.sqrt(max(0.0, 1 + m[0, 0] - m[1, 1] - m[2, 2])) / 2
    y = np.sqrt(max(0.0, 1 - m[0, 0] + m[1, 1] - m[2, 2])) / 2
    z = np.sqrt(max(0.0, 1 - m[0, 0] - m[1, 1] + m[2, 2])) / 2
    x = np.copysign(x, m[2, 1] - m[1, 2])
    y = np.copysign(y, m[0, 2] - m[2, 0])
    z = np.copysign(z, m[1, 0] - m[0, 1])
    q = np.array([x, y, z, w])
    return q / np.linalg.norm(q)


def rotmat(q):
    x, y, z, w = q
    return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                     [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                     [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])


def helper(name, oid, parent, track, gs):
    tag, values = track
    body = tag + struct.pack('<III', 1, 0, gs) + struct.pack('<I', 0) + struct.pack(f'<{len(values)}f', *values)
    head = name.encode().ljust(80, b'\0') + struct.pack('<III', oid, parent, 0)
    return struct.pack('<I', 4 + len(head) + len(body)) + head + body


if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    px, py = float(sys.argv[3]), float(sys.argv[4])
    ry = (px - 961) * 0.544 / 718.18930543
    rx = (py - 438.17) / 1.0296 * 0.302 / 387.73819261
    sh = np.array([[1, 0, ry], [0, 1, -rx], [0, 0, 1.0]])
    u, s, vt = np.linalg.svd(sh)
    if np.linalg.det(u) < 0:
        u[:, 2] *= -1
        vt[2, :] *= -1
    assert np.linalg.det(u) > 0 and np.linalg.det(vt) > 0
    qa, qc = quat(u), quat(vt)
    assert np.allclose(rotmat(qa) @ np.diag(s) @ rotmat(qc), sh, atol=1e-5)

    cs = chunks(src)
    tags = [t for t, _ in cs]
    pivots = next(d for t, d in cs if t == b'PIVT')
    # The helpers take the ids right after the last helper (ids follow the chunk order); later nodes shift.
    heads = [(t, d, o) for t, d in cs if t in NODES for o in node_offsets(t, d)]
    ids = [struct.unpack_from('<I', d, o + 84)[0] for _, d, o in heads]
    assert ids == list(range(len(ids))) and len(pivots) == 12 * len(ids)
    a = max(k for k, (t, _, _) in enumerate(heads) if t == b'HELP') + 1
    b_, c = a + 1, a + 2
    shift = lambda i: i + 3 if i != NONE and i >= a else i
    roots = 0
    for t, d, o in heads:
        oid, par = struct.unpack_from('<II', d, o + 84)
        roots += par == NONE
        struct.pack_into('<II', d, o + 84, shift(oid), c if par == NONE else shift(par))
    pivots[12 * a:12 * a] = struct.pack('<9f', *([0.0] * 9))
    if b'GLBS' not in tags:
        cs.insert(tags.index(b'SEQS') + 1, [b'GLBS', bytearray()])
    glbs = next(d for t, d in cs if t == b'GLBS')
    gs = len(glbs) // 4
    glbs += struct.pack('<I', 1000)
    new = (helper('Cizalla_A', a, NONE, (b'KGRT', qa), gs) + helper('Cizalla_B', b_, a, (b'KGSC', s), gs)
           + helper('Cizalla_C', c, b_, (b'KGRT', qc), gs))
    if b'HELP' not in [t for t, _ in cs]:
        cs.insert([t for t, _ in cs].index(b'PIVT'), [b'HELP', bytearray()])
    next(d for t, d in cs if t == b'HELP').extend(new)
    out = b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in cs)
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'out': sys.argv[2], 'shear': [ry, -rx], 'roots': roots, 'helpers': [a, b_, c],
                      'global_seq': gs, 'bytes': len(out)}))
