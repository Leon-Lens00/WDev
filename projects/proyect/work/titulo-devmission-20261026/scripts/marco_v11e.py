"""Portrait frame v11e (Dev Mission title, 30/10/2026): patches war3map.j (CRLF kept).

The frame (DT3E, new StratFrame.blp, texturas_v11e.py) goes in FRONT of the portrait (403 against 405) in the hero
select (Hero_Bg[5]) and the strategy board (Strat_Pic[5]), centred on it; the dark that was inside the old frame is now
Strat_Pic[4] ('DT3P') behind the portrait. A world square shows wider than tall by the pixel ratio below, so the frame's
width in px is its height * R. The board's portrait grows to fill the slot of the old frame.

Usage: marco_v11e.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'
R = (0.302 / 387.73819261) / (0.544 / 718.18930543)
# The frame's height: the wall (21.4 units, 320 texels of the 512) at each screen's portrait height.
HERO_H = 176 * 512 / 320
STRAT_K = 0.78
STRAT_H = STRAT_K * HERO_H


def once(s, old, new, n=1):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == n, (s.count(old), old[:80])
    return s.replace(old, new)


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, "    set Hero_Bg[4] = Title_Pic('uidb', 1487, 670.5, 370, 305, 690, 'DT37')\n",
             "    set Hero_Bg[4] = Title_Pic('uidb', 1487, 670.5, 370, 305, 690, 'DT37')\n"
             "    // v11e: the portrait's frame, in front of it (405), centred on it: its band hides the wall's edges.\n"
             f"    set Hero_Bg[5] = Title_Pic('uidb', 1487, 394, {HERO_H * R:.2f}, {HERO_H:.2f}, 403, 'DT3E')\n")
    s = once(s, "        if i < 5 then\n            call Title_Show(Hero_Bg[i], false)\n",
             "        if i < 6 then\n            call Title_Show(Hero_Bg[i], false)\n")
    s = once(s, "        if i < 5 then\n            call Title_Show(Hero_Bg[i], true)\n",
             "        if i < 6 then\n            call Title_Show(Hero_Bg[i], true)\n")
    s = once(s, "    // The frame behind the portrait (405): its inside is dark at 0.85.\n"
             "    set Strat_Pic[4] = Title_Pic('uidb', 968, 310, 435.2, 217.6, 407, 'DT3E')\n    loop\n        exitwhen i > 4\n",
             "    // v11e: the dark at 0.85 behind the portrait (405), the frame in front of it, centred on it.\n"
             f"    set Strat_Pic[4] = Title_Pic('uidb', 968, 311, {STRAT_H * 410 / 512 * R:.2f}, {STRAT_H * 326 / 512:.2f}, 407, 'DT3P')\n"
             f"    set Strat_Pic[5] = Title_Pic('uidb', 968, 311, {STRAT_H * R:.2f}, {STRAT_H:.2f}, 403, 'DT3E')\n"
             "    loop\n        exitwhen i > 5\n")
    s = once(s, "        if i < 5 then\n            call Strat_GrowAdd(Strat_Pic[i]",
             "        if i < 6 then\n            call Strat_GrowAdd(Strat_Pic[i]")
    s = once(s, "        if i < 5 then\n            call Title_Show(Strat_Pic[i], false)\n",
             "        if i < 6 then\n            call Title_Show(Strat_Pic[i], false)\n", 2)
    s = once(s, "    // The hero select's portrait was 176 px tall at 405; the frame's inside is 133 px here.\n"
             "    set Strat_PortS = 0.97 * Hero_PortraitScale * 125 / 176\n",
             "    // v11e: the same frame as the hero select's, at this share of its size.\n"
             f"    set Strat_PortS = {STRAT_K} * Hero_PortraitScale\n")
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
