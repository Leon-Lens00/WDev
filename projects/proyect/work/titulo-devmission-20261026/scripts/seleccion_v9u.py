"""Strategy board v9u (Dev Mission title, 29/10/2026). Patches v9t's war3map.j (CRLF kept).

The user's corrections after v9t:
- only the central sphere shrinks (card, effect, name, its ornaments, Pick); the old title and label stay until the
  board grows and are then hidden;
- the boss cells leave crossed and in disorder: the left block by the right edge, the right block by the left edge
  (Strat_Out: random delay up to 0.5 s, accelerating, random drift); the 8 slots beside the clock do the same (the
  4 left of it to the right, the 4 right of it to the left), and the players' cell glows follow their cells;
- the side spheres' effects use the sheared models (objetos_v9u.py 'ubt0'-'ubt7', even = left, odd = right) so
  they look head-on as at the centre instead of leaning outwards;
- the information panel is one texture (DT3I) instead of two halves with a seam.
Also: texttags drawn as if at depth 400 - Title_Eye (measured in v9t: their places were compressed by 0.77 towards
the projection centre), the text centre 0.75 font heights above the point; the portrait 1.4 x larger and centred
in its frame.

Usage: seleccion_v9u.py IN_J OUT_J
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
    s = once(s, 'real Strat_PortS= 0\n', '''real Strat_PortS= 0
real Strat_PX= 0
real Strat_PY= 0
real array Strat_BX
real array Strat_BY
''')

    # Only the sphere shrinks.
    i = s.index(L('// v9t: the sphere (card, effect, name, its ornaments, Pick) into its centre;'))
    j = s.index(L('// f = 1: as collected'), i)
    s = s[:i] + L('''// v9u: only the sphere (card, effect, name, its ornaments, Pick) into its centre; the rest stays for Strat_Fly.
function Boss_ShrinkCollect takes nothing returns nothing
    set Boss_SN = 0
    call Boss_ShrinkPic(Boss_Bg[3])
    call Boss_ShrinkPic(Boss_Bg[4])
    call Boss_ShrinkPic(Boss_Card)
    call Boss_ShrinkPic(Boss_Name)
    call Boss_ShrinkPic(Boss_PickBtn)
    if Boss_Shield != null then
        call Boss_ShrinkAdd(Boss_Shield, 5.5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5), 560)
    endif
endfunction

''') + s[j:]

    # Texttags: x, y at the depth they are drawn as; the point 0.75 font heights below the text centre.
    s = once(s, '''// A texttag centred on (px, py) for a text w pixels wide: its point is the left end, about 1.1 font heights
// above the text (Title_ClockText). Visual only.
function Strat_TextAt takes texttag t, real px, real py, real size, real w returns nothing
    call SetTextTagPos(t, Title_WX(py - 1.1 * 1080 * size, 400), Title_WY(px - w / 2, 400), Title_D() + Title_Eye - 400)
''', '''// A texttag centred on (px, py) for a text w pixels wide: its point is the left end, 0.75 font heights below
// the text's centre; texttags are drawn as if at depth 400 - Title_Eye (v9t measured). Visual only.
function Strat_TextAt takes texttag t, real px, real py, real size, real w returns nothing
    call SetTextTagPos(t, Title_WX(py + 0.75 * 1080 * size, 400 - Title_Eye), Title_WY(px - w / 2, 400 - Title_Eye), Title_D() + Title_Eye - 400)
''')

    # One panel texture.
    s = once(s, '''    set Strat_Pic[5] = Title_Pic('uidb', 831.6, 518, 409.6, 204.8, 404, 'DT3F')
    set Strat_Pic[6] = Title_Pic('uidb', 1104.4, 518, 409.6, 204.8, 404, 'DT3G')
    loop
        exitwhen i > 6
''', '''    set Strat_Pic[5] = Title_Pic('uidb', 968, 518, 545.6, 169.6, 404, 'DT3I')
    loop
        exitwhen i > 5
''')
    s = once(s, '''        if i < 7 then
            call Strat_GrowAdd(Strat_Pic[i]''', '''        if i < 6 then
            call Strat_GrowAdd(Strat_Pic[i]''')
    s = once(s, '''        if i < 7 then
            call Title_Show(Strat_Pic[i], false)''', '''        if i < 6 then
            call Title_Show(Strat_Pic[i], false)''')

    # Portrait 1.4 x, centred in the frame.
    s = once(s, '    set Strat_PortS = Hero_PortraitScale * 125 / 176\n',
             '    set Strat_PortS = 1.4 * Hero_PortraitScale * 125 / 176\n')
    s = once(s, '''    call SetUnitX(Hero_Portrait, Title_WX(310, 405))
    call SetUnitY(Hero_Portrait, Title_WY(968, 405))
endfunction''', '''    call SetUnitX(Hero_Portrait, Title_WX(330, 405))
    call SetUnitY(Hero_Portrait, Title_WY(968, 405))
endfunction''')

    # Crossed fly.
    i = s.index(L('// The boss cells out: blocks to the right off the screen'))
    j = s.index(L('function Strat_Begin takes nothing returns nothing'), i)
    s = s[:i] + L('''// v9u: a piece left of the centre leaves by the right edge, one right of it by the left edge (accelerating, its
// own delay and drift k); the place in Strat_PX/PY.
function Strat_Out takes real x0, real y0, integer k, real time returns nothing
    local real t = RMinBJ(RMaxBJ((time - Strat_Delay[k]) / 0.9, 0), 1)
    local real x1 = 2150
    if x0 > 968 then
        set x1 = -230
    endif
    set t = t * t
    set Strat_PX = x0 + (x1 - x0) * t
    set Strat_PY = y0 + Strat_DY[k] * t
endfunction

// The boss cells out crossed (bottom row into the wave row), the 8 slots by the clock the same; the players' cell
// glows follow their cells.
function Strat_Fly takes real time returns nothing
    local integer k = 0
    local integer b
    local real t
    local real x0
    loop
        exitwhen k > 39
        set b = Boss_Of[k]
        set x0 = Boss_CellX(b)
        if b < 30 then
            call Strat_Out(x0, Boss_CellY(b), k, time)
        else
            set t = RMinBJ(time / 0.6, 1)
            set t = t * t * (3 - 2 * t)
            set Strat_PX = x0 + (Strat_SqX(b - 30) - x0) * t
            set Strat_PY = Boss_CellY(b)
        endif
        set Strat_BX[b] = Strat_PX
        set Strat_BY[b] = Strat_PY
        call Hero_Put(Hero_CellQ[k], Strat_PX, Strat_PY)
        call Hero_Put(Hero_CellFrame[k], Strat_PX, Strat_PY)
        if Boss_Icon[b] != 0 then
            call Hero_Put(Boss_CellIcon[b], Strat_PX, Strat_PY)
        endif
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 7
        call Strat_Out(Hero_SlotX(k), 138.5, 40 + k, time)
        call Hero_Put(Hero_SlotQ[k], Strat_PX, Strat_PY)
        call Hero_Put(Hero_SlotFrame[k], Strat_PX, Strat_PY)
        call Hero_Put(Hero_SlotGlow[k], Strat_PX, Strat_PY)
        if Boss_SlotIcon[k] != null then
            call Hero_Put(Boss_SlotIcon[k], Strat_PX, Strat_PY)
        endif
        if Boss_Choice[k] >= 0 then
            call Hero_Put(Hero_Glow[k], Strat_BX[Boss_Choice[k]], Strat_BY[Boss_Choice[k]])
        endif
        set k = k + 1
    endloop
endfunction

''') + s[j:]
    s = once(s, '''    loop
        exitwhen k > 39
        set Strat_Delay[k] = GetRandomReal(0, 0.5)''', '''    loop
        exitwhen k > 47
        set Strat_Delay[k] = GetRandomReal(0, 0.5)''')

    # Show: the pieces that flew out and the old title and label hidden.
    s = once(s, '''    set i = 0
    loop
        exitwhen i > 1
        call Title_Skin(Strat_Card[i], Boss_Icon[Boss_Final])''', '''    set i = 0
    loop
        exitwhen i > 7
        call Title_Show(Hero_SlotQ[i], false)
        call Title_Show(Hero_SlotFrame[i], false)
        call Title_Show(Hero_SlotGlow[i], false)
        if Boss_SlotIcon[i] != null then
            call Title_Show(Boss_SlotIcon[i], false)
        endif
        call Title_Show(Hero_Glow[i], false)
        if i < 3 then
            call Title_Show(Boss_Bg[i], false)
        endif
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 1
        call Title_Skin(Strat_Card[i], Boss_Icon[Boss_Final])''')

    # Sheared effects at the side spheres.
    s = once(s, "Strat_FxAt('ubs0', Strat_SX(i), 425", "Strat_FxAt('ubt0' + i, Strat_SX(i), 425")
    s = once(s, "Strat_FxAt('ubs1', Strat_SX(s), 425", "Strat_FxAt('ubt2' + s, Strat_SX(s), 425")
    s = once(s, "Strat_FxAt('ubs2', Strat_SX(s), 425", "Strat_FxAt('ubt4' + s, Strat_SX(s), 425")
    s = once(s, "Strat_FxAt('ubs3', Strat_SX(0), 425", "Strat_FxAt('ubt6', Strat_SX(0), 425")
    s = once(s, "Strat_FxAt('ubs3', Strat_SX(1), 425", "Strat_FxAt('ubt7', Strat_SX(1), 425")

    # Reset: the slots back at their places, hidden (their owners show them again).
    s = once(s, '''        if i < 8 then
            call Strat_FxClear(i)''', '''        if i < 8 then
            call Hero_Put(Hero_SlotQ[i], Hero_SlotX(i), 138.5)
            call Hero_Put(Hero_SlotFrame[i], Hero_SlotX(i), 138.5)
            call Hero_Put(Hero_SlotGlow[i], Hero_SlotX(i), 138.5)
            call Title_Show(Hero_SlotQ[i], false)
            call Title_Show(Hero_SlotFrame[i], false)
            call Title_Show(Hero_SlotGlow[i], false)
            if Boss_SlotIcon[i] != null then
                call Hero_Put(Boss_SlotIcon[i], Hero_SlotX(i), 138.5)
                call Title_Show(Boss_SlotIcon[i], false)
            endif
            call Strat_FxClear(i)''')
    Path(sys.argv[2]).write_bytes(s.encode('utf-8'))
    print('ok', len(s))
