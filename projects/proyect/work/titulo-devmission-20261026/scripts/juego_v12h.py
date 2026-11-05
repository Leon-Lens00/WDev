"""Dev Mission title v12h (30/10/2026): what a player does is seen and heard by that player only.

Applied on the v12g script. The audit found hover, click, error, voices and portraits already local. Two things were not:
- Hero_Glow, the band of the chosen hero or boss, was shown to everyone.
- The boss pick sound of Boss_Pick. Boss_Display keeps playing it for everyone at the final boss (p = -1).

Usage: juego_v12h.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOW = '''// v12h: p's band at (px, py), on p's screen only.
function Hero_ShowGlow takes integer p, real px, real py returns nothing
    call Hero_Put(Hero_Glow[p], px, py)
    call Title_Show(Hero_Glow[p], true)
    if GetLocalPlayer() != Player(p) then
        call SetUnitScale(Hero_Glow[p], 0, 0, 0)
    endif
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

    s = base.once(s, "// A cell: p's candidate (p's glow on it); the pick button confirms it.\n",
                  GLOW + "// A cell: p's candidate (p's glow on it); the pick button confirms it.\n")
    s = base.once(s, '''    call Hero_Put(Hero_Glow[p], Boss_CellX(b), Boss_CellY(b))
    call Title_Show(Hero_Glow[p], true)
''', '''    call Hero_ShowGlow(p, Boss_CellX(b), Boss_CellY(b))
''')
    s = base.once(s, '''    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
''', '''    call Hero_ShowGlow(p, Hero_CellX(k), Hero_CellY(k))
''')

    s = base.once(s, '''function Boss_Display takes integer b returns nothing
    local real k = 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    call StopSound(Boss_PickSnd, false, false)
    call StartSound(Boss_PickSnd)
''', '''function Boss_Display takes integer b, integer p returns nothing
    local real k = 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    // v12h: p < 0 is for everyone; otherwise only the player who picked hears it.
    if p < 0 or GetLocalPlayer() == Player(p) then
        call StopSound(Boss_PickSnd, false, false)
        call StartSound(Boss_PickSnd)
    endif
''')
    s = base.once(s, '    call Boss_Display(Boss_Final)\n', '    call Boss_Display(Boss_Final, -1)\n')
    s = base.once(s, '    call Boss_Display(0)\n', '    call Boss_Display(0, -1)\n')
    s = base.once(s, '    call Boss_Display(b)\n', '    call Boss_Display(b, p)\n')

    assert s.count('call Title_Show(Hero_Glow[p], true)') == 1
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
