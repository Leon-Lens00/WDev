"""Point one geoset of a model to another of its materials (Dev Mission presentation v10i, 29/10/2026).

The hydra's body (geoset 0) used material 0: the team colour (None) under the skin (Blend). On the title's
top-down camera it came out flat black with any team texture (TeamColor02 file, v10f), two-sided layers (v10h),
unfogged or unshaded layers (v10c), or GEOA changes; with material 1 (the necks': the skin alone, None,
two-sided, unshaded) it is drawn whole (v10i). Only the geoset's material id changes.

Usage: mdx_material_geoset.py IN_MDX OUT_MDX GEOSET MATERIAL
"""
import struct, sys
b = bytearray(open(sys.argv[1], 'rb').read()); G, M = int(sys.argv[3]), int(sys.argv[4]); o = 4
while o < len(b):
    t, n = b[o:o+4], struct.unpack_from('<I', b, o+4)[0]
    if t == b'GEOS':
        g = o + 8; k = 0
        while g < o + 8 + n:
            size = struct.unpack_from('<I', b, g)[0]
            if k == G:
                m = b.find(b'MATS', g, g + size); nm = struct.unpack_from('<I', b, m + 4)[0]
                struct.pack_into('<I', b, m + 8 + 4 * nm, M); print('geoset', G, '-> material', M)
            g += size; k += 1
    o += 8 + n
open(sys.argv[2], 'wb').write(b)
