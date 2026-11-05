"""Boss select v9r (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9q (CRLF kept).

The user's notes on v9q:
- the pick button's glow had an extra glow along its top: LockGlow's box includes the hero panel's frame above
  Lock in; the boss button uses BossPickGlow ('DT39', texturas_v9q.py) without it;
- during the move right the boss section seemed to move by itself: the Start background went with the camera,
  so it stood still on screen. It now follows the camera by 0.72 of the pan, so it scrolls ~190 px (parallax,
  depth ~1230) and its edge stays out of view (plane +-1095 wide, screen +-894 at that depth, 0.28 x 640 = 179).

Usage: seleccion_v9r.py IN_J OUT_J
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
    s = once(s, "set Boss_PickGlow = Title_Pic('uidg', 968, 757, 374, 114, 399, 'DT2Q')",
             "set Boss_PickGlow = Title_Pic('uidg', 968, 757, 374, 114, 399, 'DT39')")
    s = once(s, '        call SetUnitY(Title_Bg, Title_Y() + Title_PanY)\n',
             '        call SetUnitY(Title_Bg, Title_Y() + 0.72 * Title_PanY)\n')
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
