"""Silence a model's sound events (Dev Mission title v9k, 29/10/2026).

Dev Us's boss effects carry SND event objects that the game plays as 3D sounds at the effect; on the zenith
title camera the effects sit a few hundred units under the eye, so they play at full volume over the pick's
mp3. Every SND object (a node and its KEVT track, no size of its own) keeps both (so object ids and pivots stay as they are); only its
key times move past every sequence (0x7FFFFFFF), so the event never fires. Splat/ubersplat events stay.

Usage: mdx_silenciar.py IN_MDX OUT_MDX
"""
from pathlib import Path
import json, struct, sys

b = bytearray(Path(sys.argv[1]).read_bytes())
assert b[:4] == b'MDLX'
i, done = 4, []
while i < len(b):
    tag, n = bytes(b[i:i + 4]), struct.unpack_from('<I', b, i + 4)[0]
    if tag == b'EVTS':
        j, end = i + 8, i + 8 + n
        while j < end:
            node = struct.unpack_from('<I', b, j)[0]
            name = bytes(b[j + 4:j + 84]).split(b'\0')[0].decode('latin-1')
            k = j + node
            count = 0
            if b[k:k + 4] == b'KEVT':
                count = struct.unpack_from('<I', b, k + 4)[0]
                if name.startswith('SND'):
                    for t in range(count):
                        struct.pack_into('<I', b, k + 12 + 4 * t, 0x7FFFFFFF)
                    done.append([name, count])
                k += 12 + 4 * count
            j = k
        assert j == end
    i += 8 + n
Path(sys.argv[2]).write_bytes(b)
print(json.dumps(done))
