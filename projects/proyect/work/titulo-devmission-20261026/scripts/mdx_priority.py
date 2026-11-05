"""Shift every material's priority plane of an MDX by DELTA (v10o).

The user's glows (Glow_Horizontal/Vertical.mdx) came with planes -64..-59, drawn before the emblem pictures
(plane 0), so the logo stayed on top of the band. +128 keeps their relative order and puts them after it.
Usage: mdx_priority.py IN OUT DELTA
"""
import struct
import sys

src, dst, delta = sys.argv[1], sys.argv[2], int(sys.argv[3])
d = bytearray(open(src, 'rb').read())
assert d[:4] == b'MDLX'
o = 4
while o < len(d):
    tag, n = bytes(d[o:o + 4]), struct.unpack_from('<I', d, o + 4)[0]
    if tag == b'MTLS':
        p = o + 8
        while p < o + 8 + n:
            size, prio = struct.unpack_from('<Ii', d, p)
            struct.pack_into('<i', d, p + 4, prio + delta)
            print('material at', p, 'plane', prio, '->', prio + delta)
            p += size
        assert p == o + 8 + n
    o += 8 + n
assert o == len(d)
open(dst, 'wb').write(d)
