"""Hero/boss select v9m (Dev Mission title, 29/10/2026): hit zones at the cells' own depth, shown for debugging.

The user reported in v9l that the cells still light before the mouse reaches them. The hit quads sat 26/40 above
the ground, about 1500 under the eye, while the pictures are 402 under it; Title_WX/WY place both with the
picture calibration (Title_Eye, 1.0296), so any error in that calibration moves the deep quads outward from the
centre in proportion to depth. Now every hero/boss hit quad is at z = Title_D + Title_Eye - 402 = 1128.35 (the
cells' depth) and the scripts place them with depth 402, so quad and picture share one projection.

For the user's check ("oculta el fondo de momento"): the Start background (Title_Bg) is hidden when the hero
select appears, and the hit quads use TrackDebug.blp (translucent red, blend) instead of the invisible TitleHit.

Usage: zonas_v9m.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, '''    local integer k
    local real depth = Title_D() + Title_Eye - 26
    set Hero_Tracked = true
''', '''    local integer k
    local real depth = 402
    set Hero_Tracked = true
''')
    s = once(s, '''    local real depth = Title_D() + Title_Eye - 40
''', '''    local real depth = 402
''')
    s = once(s, '''    if not Hero_Built then
        call Hero_Build()
    endif
    loop
        exitwhen i >= Mode_N
''', '''    if not Hero_Built then
        call Hero_Build()
    endif
    // v9m, for the user's check of the hit zones: no Start background behind the hero and boss select.
    call SetUnitScale(Title_Bg, 0, 0, 0)
    loop
        exitwhen i >= Mode_N
''')
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
