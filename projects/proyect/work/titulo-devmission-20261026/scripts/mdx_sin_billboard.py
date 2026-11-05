"""Take the billboard off the Ubershield Azure sphere (Dev Mission title v10u, 30/10/2026).

'Pods', 'Blau' and 'Rim' are billboarded bones (flag 0x8), so the engine replaces their rotation each frame:
mdx_cizalla.py's shear never reaches the hexagon sphere, and off the centre it projects as a perspective oval
(sec of the angle from the axis) while the flat rim stays round. The title camera never turns, so the billboard
can be baked: the vertices and normals of those bones' geosets get the rotation it gave them, and the flag goes.

Billboard: bone +X to the camera, +Z to the screen's top, +Y to its right. Title camera (rotation 180): right +Y,
up -X. Unit facing 270: model +X = world -Y, model +Y = world +X. So (x, y, z) -> (-y, -z, x). Pivots at the origin.
Run this first, then mdx_cizalla.py.

Usage: mdx_sin_billboard.py IN_MDX OUT_MDX
"""
from pathlib import Path
import json, struct, sys

BILLBOARD = 0x8


def chunks(b):
    o, out = 4, []
    while o < len(b):
        t, n = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
        out.append([t, bytearray(b[o + 8:o + 8 + n])])
        o += 8 + n
    assert o == len(b)
    return out


def turn(d, o, n):
    for i in range(n):
        x, y, z = struct.unpack_from('<3f', d, o + 12 * i)
        struct.pack_into('<3f', d, o + 12 * i, -y, -z, x)


def turn_box(d, o):
    """An extent: radius, min xyz, max xyz."""
    lo, hi = struct.unpack_from('<3f', d, o + 4), struct.unpack_from('<3f', d, o + 16)
    struct.pack_into('<6f', d, o + 4, -hi[1], -hi[2], lo[0], -lo[1], -lo[2], hi[0])


def geoset(d, o, billboard):
    """Turn the geoset at o (its inclusive size first) if its bones are billboarded; returns the next offset."""
    size = struct.unpack_from('<I', d, o)[0]
    p, found, parts = o + 4, {}, []
    while True:
        t, n = bytes(d[p:p + 4]), struct.unpack_from('<I', d, p + 4)[0]
        found[t] = p
        step = {b'VRTX': 12, b'NRMS': 12, b'PTYP': 4, b'PCNT': 4, b'PVTX': 2, b'GNDX': 1, b'MTGC': 4, b'MATS': 4}[t]
        p += 8 + n * step
        if t == b'MATS':
            break
    m = found[b'MATS']
    nodes = set(struct.unpack_from(f'<{struct.unpack_from("<I", d, m + 4)[0]}I', d, m + 8))
    if not nodes & billboard:
        return o + size, False
    assert nodes <= billboard, nodes
    for t in (b'VRTX', b'NRMS'):
        turn(d, found[t] + 8, struct.unpack_from('<I', d, found[t] + 4)[0])
    # Material id, selection group, selection flags, then the extents.
    p += 12
    turn_box(d, p)
    count = struct.unpack_from('<I', d, p + 28)[0]
    for i in range(count):
        turn_box(d, p + 32 + 28 * i)
    return o + size, True


if __name__ == '__main__':
    cs = chunks(Path(sys.argv[1]).read_bytes())
    get = lambda tag: next(d for t, d in cs if t == tag)
    bones, geos, pivots = get(b'BONE'), get(b'GEOS'), get(b'PIVT')
    o, billboard, names = 0, set(), []
    while o < len(bones):
        n = struct.unpack_from('<I', bones, o)[0]
        oid, _, flags = struct.unpack_from('<III', bones, o + 84)
        if flags & BILLBOARD:
            assert struct.unpack_from('<3f', pivots, 12 * oid) == (0.0, 0.0, 0.0), oid
            struct.pack_into('<I', bones, o + 92, flags & ~BILLBOARD)
            billboard.add(oid)
            names.append(bytes(bones[o + 4:o + 84]).split(b'\0')[0].decode())
        o += n + 8
    o, k, turned = 0, 0, []
    while o < len(geos):
        o, done = geoset(geos, o, billboard)
        if done:
            turned.append(k)
        k += 1
    out = b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in cs)
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'out': sys.argv[2], 'bones': names, 'geosets': turned, 'bytes': len(out)}))
