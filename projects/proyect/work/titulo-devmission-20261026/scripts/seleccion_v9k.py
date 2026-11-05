"""Hero and boss select v9k (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9j (CRLF kept).

The user's requests after v9j:
- the boss cells higher, the bottom row was cut by the HUD (top at y ~828): side rows from 232 (pitch 105 kept,
  last row 652, bottom edge 702), bottom row at 757 (edges 707-807); the centre 15 px up with them (sphere, card
  and effects 402, name 663, its ornaments 670);
- a cell under the mouse lights up like a mode box (Mode_BoxHi): a bright copy of the frame (CellHi, 'DT33',
  texturas_v9k.py) per player at depth 400.5 (between the chosen-cell glow, 399, and the frame, 401), moved to
  the cell and shown only on that player's screen (scale in GetLocalPlayer: visual); for the boss cells it
  replaces the neon sprite ('ubs4'), 100 px like the landed cells;
- no cursor sound on the boss cells; the pick's mp3 at 70 instead of 95 (the effects' own model sounds are
  silenced in their MDX, mdx_silenciar.py);
- the hero select on the Start screen's animated background, as the boss select: Hero_Bg is now the title
  (HeroTitleL/R 'DT34'/'DT35'), "Tiempo de seleccion" (BossLabel 'DT2U') and the portrait panel with Lock in
  (HeroPanelT/B 'DT36'/'DT37', 370 x 305 each, depth 690, behind the portrait at 405); Hero_Bg[5-7] stay null.

Usage: seleccion_v9k.py IN_J OUT_J
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
    s = once(s, 'unit array Hero_CellQ\n', 'unit array Hero_CellQ\nunit array Hero_Hi\ninteger array Hero_HiCell\n')

    # Boss layout higher.
    s = once(s, '        return 278.0 + 105.0 * (ModuloInteger(b, 15) / 3)\n    endif\n    return 810.0\n',
             '        return 232.0 + 105.0 * (ModuloInteger(b, 15) / 3)\n    endif\n    return 757.0\n')
    s = once(s, 'id, Title_WX(417, depth), Title_WY(968, depth), 270)', 'id, Title_WX(402, depth), Title_WY(968, depth), 270)')
    s = once(s, "Title_Pic('uidb', 662, 685, 256, 64, 404, 'DT2V')", "Title_Pic('uidb', 662, 670, 256, 64, 404, 'DT2V')")
    s = once(s, "Title_Pic('uidb', 1278, 685, 256, 64, 404, 'DT2W')", "Title_Pic('uidb', 1278, 670, 256, 64, 404, 'DT2W')")
    s = once(s, "Title_Pic('uidb', 968, 417, 356, 356, 561, 'DT31')", "Title_Pic('uidb', 968, 402, 356, 356, 561, 'DT31')")
    s = once(s, "Title_Pic('uidb', 970, 678, 256, 128, 403, 'DT30')", "Title_Pic('uidb', 970, 663, 256, 128, 403, 'DT30')")

    # Boss hover: the bright frame instead of the neon sprite; no cursor sound; quieter pick.
    i = s.index(L('        // neon_sprite100 is 141 wide'))
    j = s.index(L('        set i = i + 1\n'), i)
    s = s[:i] + L('''        // The bright cell frame (CellHi) under the mouse, 100 px as the landed cells.
        set Boss_Neon[i] = Title_Pic('uidb', 968, 402, 100, 100, 400.5, 'DT33')
        call Title_Show(Boss_Neon[i], false)
''') + s[j:]
    s = once(s, '    call SetSoundVolume(Boss_PickSnd, 95)\n', '    call SetSoundVolume(Boss_PickSnd, 70)\n')
    s = once(s, '''    set Boss_CursorSnd = CreateSound("war3mapImported\\\\XC_LU_CURSOR_MOVES.mp3", false, false, false, 10, 10, "")
    call SetSoundDuration(Boss_CursorSnd, 408)
    call SetSoundChannel(Boss_CursorSnd, 0)
    call SetSoundVolume(Boss_CursorSnd, 127)
''', '')
    s = once(s, '''        call SetUnitScale(Boss_Neon[p], s, s, s)
        if b >= 0 then
            call StopSound(Boss_CursorSnd, false, false)
            call StartSound(Boss_CursorSnd)
        endif
''', '''        call SetUnitScale(Boss_Neon[p], s, s, s)
''')

    # Hero screen: pieces on the animated background instead of the static Hero_Bg, and the hover frame.
    s = once(s, '''        set Hero_Bg[i] = Title_Pic('uidb', 256 + 512 * ModuloInteger(i, 4), 256 + 512 * (i / 4), 514, 514, 700, bg[i])
        call Title_Show(Hero_Bg[i], false)
''', '')
    s = once(s, '''        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 39
        set Hero_Icon[i] = 0
''', '''        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    // v9k: the Start screen's animated background stays under the hero select (the user's choice); the mockup's
    // title, "Tiempo de seleccion" and the portrait panel are pictures (texturas_v9k.py, mockup + 80, 15).
    set Hero_Bg[0] = Title_Pic('uidb', 781.5, 62, 512, 128, 404, 'DT34')
    set Hero_Bg[1] = Title_Pic('uidb', 1174, 62, 512, 128, 404, 'DT35')
    set Hero_Bg[2] = Title_Pic('uidb', 967, 176, 256, 32, 404, 'DT2U')
    set Hero_Bg[3] = Title_Pic('uidb', 1487, 365.5, 370, 305, 690, 'DT36')
    set Hero_Bg[4] = Title_Pic('uidb', 1487, 670.5, 370, 305, 690, 'DT37')
    set i = 0
    loop
        exitwhen i > 11
        if i < 5 then
            call Title_Show(Hero_Bg[i], false)
        endif
        set Hero_HiCell[i] = -1
        set Hero_Hi[i] = Title_Pic('uidb', Hero_CellX(0), Hero_CellY(0), 96, 96, 400.5, 'DT33')
        call Title_Show(Hero_Hi[i], false)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 39
        set Hero_Icon[i] = 0
''')
    s = once(s, '''function Hero_OnTrack takes integer p, integer kind returns nothing
    local boolean on = kind == 140 and Hero_Ready
''', '''// The bright frame on the cell under p's mouse, only on p's screen; k < 0: none.
function Hero_ShowHi takes integer p, integer k returns nothing
    local real s = 0
    set Hero_HiCell[p] = k
    if k >= 0 then
        call Hero_Put(Hero_Hi[p], Hero_CellX(k), Hero_CellY(k))
        set s = LoadReal(Title_HT, GetHandleId(Hero_Hi[p]), 1)
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Hero_Hi[p], s, s, s)
    endif
endfunction

function Hero_OnTrack takes integer p, integer kind returns nothing
    local boolean on = kind == 140 and Hero_Ready
    local integer k = kind - 100
    if not Hero_Ready or k < 0 or k > 39 then
        set k = -1
    endif
    if k != Hero_HiCell[p] then
        call Hero_ShowHi(p, k)
    endif
''')
    # Hidden with the other pieces, at the boss select and on a new hero select.
    s = once(s, '''    call Title_Show(Hero_LockGlow, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
endfunction
''', '''    call Title_Show(Hero_LockGlow, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
    set i = 0
    loop
        exitwhen i > 11
        set Hero_HiCell[i] = -1
        call SetUnitScale(Hero_Hi[i], 0, 0, 0)
        set i = i + 1
    endloop
endfunction
''')
    s = once(s, '''        if i < 12 then
            set Boss_Choice[i] = -1
            set Boss_Hover[i] = -1
            set Hero_LockHover[i] = false
''', '''        if i < 12 then
            set Boss_Choice[i] = -1
            set Boss_Hover[i] = -1
            set Hero_LockHover[i] = false
            set Hero_HiCell[i] = -1
            call SetUnitScale(Hero_Hi[i], 0, 0, 0)
''')
    s = once(s, '''        set Hero_Choice[i] = -1
        set Hero_Locked[i] = false
        set Hero_LockHover[i] = false
        if i < 8 then
            call Title_Show(Hero_Bg[i], true)
''', '''        set Hero_Choice[i] = -1
        set Hero_Locked[i] = false
        set Hero_LockHover[i] = false
        if i < 5 then
            call Title_Show(Hero_Bg[i], true)
        endif
        if i < 8 then
''')
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
