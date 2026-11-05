"""Temporary test bridge for the presentation (Dev Mission title, 29/10/2026). NOT for integration.

The user asked for a temporary bridge so that starting the map goes straight to the presentation, to test it
faster. Patches a presentation build's war3map.j (CRLF kept): instead of the intro, the title camera is set and
Pres_Begin runs (1 s to black, 2 s, then the scene with the theme). The board is never built, so its hiding
touches null units, which the natives ignore. -titulo after the scene is not supported in this build.

Usage: puente_v10.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


BRIDGE = '''// TEMPORARY test bridge (scripts/puente_v10.py): straight to the presentation, no intro, title or board.
function Pres_Bridge takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + 1, Title_X() + 1, Title_Y() + 1, Title_X() + 1, Title_Y() - 1)
    call Title_Camera()
    call Pres_Begin()
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, '// v9c: the missile diagnostic multiboard', BRIDGE + '// v9c: the missile diagnostic multiboard')
    s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Pres_Bridge)\n')
    Path(sys.argv[2]).write_bytes(s.encode('utf-8'))
    print('ok', len(s))
