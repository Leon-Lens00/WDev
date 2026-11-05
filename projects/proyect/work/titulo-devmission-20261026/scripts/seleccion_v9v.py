"""Strategy board v9v (Dev Mission title, 29/10/2026). Patches v9u's war3map.j (CRLF kept).

The user's corrections after v9u:
- "Fase de estrategia" is one picture (DT3J) instead of two halves; the pictures are now 0 title, 1 panel,
  2 "Tiempo de estrategia", 3 "Entrando a partida con:", 4 portrait frame;
- the two spheres do not grow with the board: when it has grown (Strat_Go) they appear at once (card and shield at
  full scale) with the pick effect and its sound (Strat_Play for every registered player);
- the portrait (1.4 x in v9u, over the frame's bottom and the hero's name) is 0.97 x, centred in the frame.

Usage: seleccion_v9v.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def L(s):
    return s.replace('\n', N)


def once(s, old, new):
    old, new = L(old), L(new)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, '''    set Strat_Pic[0] = Title_Pic('uidb', 781.5, 67, 512, 128, 404, 'DT3A')
    set Strat_Pic[1] = Title_Pic('uidb', 1174, 67, 512, 128, 404, 'DT3B')
''', '''    set Strat_Pic[0] = Title_Pic('uidb', 977.5, 67, 785, 60, 404, 'DT3J')
    set Strat_Pic[1] = Title_Pic('uidb', 968, 518, 545.6, 169.6, 404, 'DT3I')
''')
    s = once(s, '''    set Strat_Pic[5] = Title_Pic('uidb', 968, 518, 545.6, 169.6, 404, 'DT3I')
    loop
        exitwhen i > 5
''', '''    loop
        exitwhen i > 4
''')
    s = once(s, '''        if i < 6 then
            call Strat_GrowAdd(Strat_Pic[i]''', '''        if i < 5 then
            call Strat_GrowAdd(Strat_Pic[i]''')
    s = once(s, '''        if i < 6 then
            call Title_Show(Strat_Pic[i], false)''', '''        if i < 5 then
            call Title_Show(Strat_Pic[i], false)''')

    # Spheres: created hidden, shown at once in Strat_Go.
    s = once(s, '''        call Title_Skin(Strat_Card[i], Boss_Icon[Boss_Final])
        call Strat_GrowAdd(Strat_Card[i], LoadReal(Title_HT, GetHandleId(Strat_Card[i]), 1))
        set Strat_Shield[i] = Strat_FxAt('ubt0' + i, Strat_SX(i), 425, 560, 0, 1)
        call Strat_GrowAdd(Strat_Shield[i], 5.5 * k)
        call SetUnitAnimation(Strat_Shield[i], "birth")
        call QueueUnitAnimation(Strat_Shield[i], "stand")
''', '''        call Title_Skin(Strat_Card[i], Boss_Icon[Boss_Final])
        set Strat_Shield[i] = Strat_FxAt('ubt0' + i, Strat_SX(i), 425, 560, 0, 1)
''')
    s = once(s, '''function Strat_Go takes nothing returns nothing
    local integer p = 0
    local integer me = GetPlayerId(GetLocalPlayer())
    if not Strat_Tracked then
        call Strat_Tracks()
    endif
''', '''function Strat_Go takes nothing returns nothing
    local integer p = 0
    local integer me = GetPlayerId(GetLocalPlayer())
    local real k = 5.5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5)
    if not Strat_Tracked then
        call Strat_Tracks()
    endif
    // v9v: the spheres at once, with the pick effect and its sound (cards by Strat_ShowView below).
    call SetUnitScale(Strat_Shield[0], k, k, k)
    call SetUnitScale(Strat_Shield[1], k, k, k)
    loop
        exitwhen p > 7
        if Title_Registered[p] then
            call Strat_Play(p)
        endif
        set p = p + 1
    endloop
    set p = 0
''')

    s = once(s, '    set Strat_PortS = 1.4 * Hero_PortraitScale * 125 / 176\n',
             '    set Strat_PortS = 0.97 * Hero_PortraitScale * 125 / 176\n')
    s = once(s, '''    call SetUnitX(Hero_Portrait, Title_WX(330, 405))
    call SetUnitY(Hero_Portrait, Title_WY(968, 405))
endfunction''', '''    call SetUnitX(Hero_Portrait, Title_WX(311, 405))
    call SetUnitY(Hero_Portrait, Title_WY(968, 405))
endfunction''')
    Path(sys.argv[2]).write_bytes(s.encode('utf-8'))
    print('ok', len(s))
