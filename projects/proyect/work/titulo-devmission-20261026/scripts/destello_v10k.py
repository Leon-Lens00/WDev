"""Presentation v10k (Dev Mission title, 29/10/2026): the flashes are the converging glows, not a white screen.

The user pointed out after v10j that the reference's flash is the glow model that contracts, not a general white
flash. Seen at 30 fps on the reference: at the stop a pale band covers the whole screen and closes from top and
bottom to a horizontal line (about 0.3 s); at the reveal the same from left and right to a vertical line. The
glows (Glow_Horizontal/Vertical, Birth: a 2480 x 1500 band contracting to a line in 0.31 s) already start on
those beats, so the White_mask cine filter (Pres_Flash) goes from the three beats, and its preload in the dark
becomes a preload of both glows: each plays its Birth under the black at Pres_Time 1.0 and is hidden again by
Pres_GlowEnd at m -0.1 (at = -0.9), so their first real use does not stall the game.

Usage: destello_v10k.py IN_J OUT_J (v10j's war3map.j or its bridge copy; CRLF kept).
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
nl = '\r\n' if '\r\n' in s else '\n'


def rep(a, b, n=1):
    global s
    a, b = a.replace('\n', nl), b.replace('\n', nl)
    assert s.count(a) == n, (s.count(a), a[:70])
    s = s.replace(a, b)


rep('''        call Pres_Flash()
''', '', 3)
rep('''        // White_mask loaded in the dark (tinted black, the same full black): its first use stalled the first flash.
        call SetCineFilterTexture("ReplaceableTextures\\\\CameraMasks\\\\White_mask.blp")
        call SetCineFilterStartColor(0, 0, 0, 255)
        call SetCineFilterEndColor(0, 0, 0, 255)
        call SetCineFilterDuration(0)
        call DisplayCineFilter(true)
''', '''        // Both glows played once under the black (a first use stalls the game), hidden again at m -0.1.
        call Pres_Pulse(Pres_GH)
        call Pres_Pulse(Pres_GV)
        set Pres_GHAt = -0.9
        set Pres_GVAt = -0.9
''')
Path(sys.argv[2]).write_bytes(s.encode('latin-1'))
print('ok', sys.argv[2])
