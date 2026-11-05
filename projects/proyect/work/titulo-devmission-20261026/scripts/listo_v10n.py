"""Presentation v10n (Dev Mission title, 29/10/2026): the hydra's ready pose centred on the emblem.

The user, after v10m: the walk's place is right, the ready moment (Spell, frozen) needs its own. Measured on
v10m's frozen frame: the ring's centre at (957, 416) px, the hydra's body and heads 656-1061 x 283-533, centre
(859, 408): 98 px left and 8 px up. At the reveal (m 5.2, under the glows) its origin moves from (919.4, 532.1)
to (1017.4, 540.1).

Usage: listo_v10n.py IN_J OUT_J (v10m's war3map.j or its bridge copy; CRLF kept).
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
nl = '\r\n' if '\r\n' in s else '\n'
a = '''        call SetUnitVertexColor(Pres_Hydra, 255, 255, 255, 255)
'''.replace('\n', nl)
b = '''        call SetUnitVertexColor(Pres_Hydra, 255, 255, 255, 255)
        // The ready pose centred (v10n): its place differs from the walk's.
        call SetUnitX(Pres_Hydra, Title_WX(540.1, 220))
        call SetUnitY(Pres_Hydra, Title_WY(1017.4, 220))
'''.replace('\n', nl)
assert s.count(a) == 1
s = s.replace(a, b)
Path(sys.argv[2]).write_bytes(s.encode('latin-1'))
print('ok', sys.argv[2])
