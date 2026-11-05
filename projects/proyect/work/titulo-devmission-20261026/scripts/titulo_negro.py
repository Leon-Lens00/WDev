"""Black screen from the first frame of the Dev Mission title (v8j, 28/10/2026). Patches the compiled war3map.j
of v8i (CRLF kept).

The user saw the terrain or the default camera point for a moment when the map loaded: main only calls
Title_Init, and the title's camera, background and pieces come 0.1 s later in Title_Begin (timer). Now main
puts a fully opaque black cinematic filter up before anything else, so the first frame is black; Title_Begin
builds the scene under it and, 0.15 s later, the filter fades from black to clear in 0.5 s and is then hidden.
The filter is the same for every player (no GetLocalPlayer), as CinematicFadeBJ does.

Usage: titulo_negro.py IN_J OUT_J
"""
from pathlib import Path
import sys

FUNCS = r'''// v8j: black from the first frame; the title fades in once it is built.
function Title_Black takes integer a0, integer a1, real dur returns nothing
    call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp")
    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    call SetCineFilterStartUV(0, 0, 1, 1)
    call SetCineFilterEndUV(0, 0, 1, 1)
    call SetCineFilterStartColor(0, 0, 0, a0)
    call SetCineFilterEndColor(0, 0, 0, a1)
    call SetCineFilterDuration(dur)
    call DisplayCineFilter(true)
endfunction

function Title_RevealEnd takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call DisplayCineFilter(false)
endfunction

function Title_Reveal takes nothing returns nothing
    local timer t = GetExpiredTimer()
    call Title_Black(255, 0, 0.5)
    call TimerStart(t, 0.55, false, function Title_RevealEnd)
    set t = null
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    j = once(j, 'function Title_Begin takes nothing returns nothing\n', FUNCS + 'function Title_Begin takes nothing returns nothing\n')
    j = once(j, '    call TimerStart(Title_Timer, 0.05, true, function Title_Tick)\n',
             '    call TimerStart(Title_Timer, 0.05, true, function Title_Tick)\n'
             '    call TimerStart(CreateTimer(), 0.15, false, function Title_Reveal)\n')
    j = once(j, 'function main takes nothing returns nothing\n',
             'function main takes nothing returns nothing\n    call Title_Black(255, 255, 0)\n')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
