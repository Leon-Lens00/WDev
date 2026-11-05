"""One clock for every screen and the wider cell grid (Dev Mission title v9h, 29/10/2026). Patches the compiled
war3map.j of v9g (CRLF kept):
- the user asked for the hero select's clock on the Start and mode screens too, replacing the old one. Both used
  the same digit textures (ModeDigit0-9); the hero one is M:SS, 50.6 x 73.6 per glyph, with the colon 'DT2N'.
  Clock_Build now makes those pieces (minutes 0-1, tens 0-5, units 0-9, colon) and Clock_Show(n, px, py) draws
  M:SS centred on (px, py): minute -41.25, colon -15.75, tens +9.25, units +41.25 (the hero layout, whose centre
  is 965.25, 130.5). The old 35.75 x 52 pieces and the hero's own clock pieces are gone;
- Hero_CellX follows texturas_heroe.py's new columns: 80 + 128 + 142 c.

Usage: reloj_mss.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def lines(s):
    return s.replace('\n', N)


def cut(s, start, end):
    i = s.index(start)
    j = s.index(end, i)
    return s[:i], s[j:]


CLOCK = lines('''// v9h: the countdown of every screen is the hero select's M:SS (scripts/reloj_mss.py): digit pictures
// (ModeDigit0-9, 'DT1D'-'DT26') and the colon ('DT2N'), 50.6 x 73.6 each, one picture per digit and place, made
// hidden on first use and moved/shown, never re-skinned (War Club did not retexture moved pieces, v8c). Not
// texttags: off the screen centre a texttag did not land at its pixel point (v8e). Shown for everybody.
function Clock_Build takes nothing returns nothing
    local integer d = 0
    set Clock_Built = true
    set Clock_Tex[0] = 'DT1D'
    set Clock_Tex[1] = 'DT1E'
    set Clock_Tex[2] = 'DT1F'
    set Clock_Tex[3] = 'DT20'
    set Clock_Tex[4] = 'DT21'
    set Clock_Tex[5] = 'DT22'
    set Clock_Tex[6] = 'DT23'
    set Clock_Tex[7] = 'DT24'
    set Clock_Tex[8] = 'DT25'
    set Clock_Tex[9] = 'DT26'
    loop
        exitwhen d > 9
        if d < 2 then
            set Clock_Min[d] = Title_Pic('uidb', 960, 112, 50.6, 73.6, 399, Clock_Tex[d])
            call Title_Show(Clock_Min[d], false)
        endif
        if d < 6 then
            set Clock_Tens[d] = Title_Pic('uidb', 960, 112, 50.6, 73.6, 399, Clock_Tex[d])
            call Title_Show(Clock_Tens[d], false)
        endif
        set Clock_Units[d] = Title_Pic('uidb', 960, 112, 50.6, 73.6, 399, Clock_Tex[d])
        call Title_Show(Clock_Units[d], false)
        set d = d + 1
    endloop
    set Clock_Colon = Title_Pic('uidb', 960, 112, 50.6, 73.6, 399, 'DT2N')
    call Title_Show(Clock_Colon, false)
endfunction

function Clock_Put takes unit u, real px, real py returns nothing
    call SetUnitX(u, Title_WX(py, 399))
    call SetUnitY(u, Title_WY(px, 399))
    call Title_Show(u, true)
endfunction

// n seconds (0-119) as M:SS centred on (px, py); n < 0 hides the clock.
function Clock_Show takes integer n, real px, real py returns nothing
    local integer d = 0
    if not Clock_Built then
        call Clock_Build()
    endif
    loop
        exitwhen d > 9
        if d < 2 then
            call Title_Show(Clock_Min[d], false)
        endif
        if d < 6 then
            call Title_Show(Clock_Tens[d], false)
        endif
        call Title_Show(Clock_Units[d], false)
        set d = d + 1
    endloop
    call Title_Show(Clock_Colon, false)
    if n < 0 then
        return
    endif
    call Clock_Put(Clock_Min[n / 60], px - 41.25, py)
    call Clock_Put(Clock_Colon, px - 15.75, py)
    set n = n - n / 60 * 60
    call Clock_Put(Clock_Tens[n / 10], px + 9.25, py)
    call Clock_Put(Clock_Units[n - n / 10 * 10], px + 41.25, py)
endfunction

''')

HERO_SHOW = lines('''// n seconds as M:SS at the mockup's timer; n < 0 hides the clock.
function Hero_ClockShow takes integer n returns nothing
    call Clock_Show(n, 965.25, 130.5)
endfunction

''')

REFRESH_OLD = lines('''    if Clock_Built then
        loop
            exitwhen i > 9
            call Title_Height(Clock_Units[i])
            set i = i + 1
        endloop
        call Title_Height(Clock_Tens[1])
        call Title_Height(Clock_Tens[2])
    endif
''')
REFRESH_NEW = lines('''    if Clock_Built then
        loop
            exitwhen i > 9
            call Title_Height(Clock_Units[i])
            if i < 6 then
                call Title_Height(Clock_Tens[i])
            endif
            if i < 2 then
                call Title_Height(Clock_Min[i])
            endif
            set i = i + 1
        endloop
        call Title_Height(Clock_Colon)
        set i = 0
    endif
''')

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    assert s.count(N) > 1000
    g = 'unit array Clock_Units' + N
    assert s.count(g) == 1
    s = s.replace(g, g + 'unit array Clock_Min' + N + 'unit Clock_Colon= null' + N)
    for old in ('unit array Hero_ClockMin', 'unit array Hero_ClockTen', 'unit array Hero_ClockUnit',
                'unit Hero_Colon= null'):
        assert s.count(old + N) == 1, old
        s = s.replace(old + N, '')

    a, b = cut(s, '// v8g: the countdown of both screens', 'function Title_ClockText takes')
    s = a + CLOCK + b

    hero_clock = lines('''    set i = 0
    loop
        exitwhen i > 9
        if i < 2 then
            set Hero_ClockMin[i]''')
    a, b = cut(s, hero_clock, 'endfunction' + N)
    s = a + b
    a, b = cut(s, '// n seconds as M:SS; n < 0 hides the clock.', '// One trackable per cell')
    s = a + HERO_SHOW + b

    assert s.count(REFRESH_OLD) == 1
    s = s.replace(REFRESH_OLD, REFRESH_NEW)
    old = '    return 297 + 113.89 * ModuloInteger(k, 8)' + N
    assert s.count(old) == 1
    s = s.replace(old, '    return 208.0 + 142.0 * ModuloInteger(k, 8)' + N)
    for name in ('Hero_ClockMin', 'Hero_ClockTen', 'Hero_ClockUnit', 'Hero_Colon'):
        assert name not in s, name
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
