"""Temporary test bridge to the boss select (Dev Mission title v10u, 30/10/2026). NOT for integration.

The user asked to start straight at the boss select, to reach the side spheres of the strategy phase quickly.
Patches a normal build's war3map.j (CRLF kept): instead of the intro, what Title_Begin and Hero_Show leave ready
for Boss_Start (background, trackables, the clock's timer, the hero grid), then Boss_Start. No hero is chosen.

Usage: puente_boss.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


BRIDGE = '''// TEMPORARY test bridge (scripts/puente_boss.py): straight to the boss select, no intro, title or hero select.
function Boss_Bridge takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + 1, Title_X() + 1, Title_Y() + 1, Title_X() + 1, Title_Y() - 1)
    call Title_Camera()
    call Title_Background()
    call Title_Tracks()
    set Title_Clock = CreateTextTag()
    call SetTextTagPermanent(Title_Clock, true)
    call SetTextTagVisibility(Title_Clock, true)
    set Title_Active = false
    call TimerStart(Title_Timer, 0.05, true, function Title_Tick)
    set Hero_Active = true
    set Hero_Ready = false
    call Hero_Build()
    call Hero_Pieces(true)
    if not Hero_Tracked then
        call Hero_Tracks()
    endif
    call TimerStart(CreateTimer(), 0.05, false, function Boss_Start)
    call TimerStart(CreateTimer(), 0.15, false, function Title_Reveal)
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, '// v9c: the missile diagnostic multiboard', BRIDGE + '// v9c: the missile diagnostic multiboard')
    s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Boss_Bridge)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
