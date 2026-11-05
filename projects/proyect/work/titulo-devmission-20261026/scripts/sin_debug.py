"""Dev Mission title without on-screen debug text (v9c, 28/10/2026). Patches the compiled war3map.j of v9b
(CRLF kept).

The user asked for the version without debug comments. Removed: the eight messages the title and the mode screen
print by themselves (title help, registered player, time out, registration closed, mode chosen, mode locked, not
registered, mode time out). The diagnostic chat commands (-ajuste, -rot, -fondo, -camara, -modos, -titulo...) keep
their answers, since they only show when typed. The missile diagnostic multiboard (MissileStats, "Misiles: OK")
is hidden as soon as it exists (Title_HideBoard, 0.02 s timer from Title_Init); -misiles still toggles it, and the
HUD hides it again after the title as before. MultiboardDisplay for everybody, visual only.

Usage: sin_debug.py IN_J OUT_J
"""
from pathlib import Path
import sys

MESSAGES = [
    '"Registro cerrado: "', '"Modo bloqueado por ahora."', '"No te registraste con Start."', '" eligio Modo supervivencia."',
    '" eligieron Modo supervivencia."', '" registrados (" + names', '" registrado (jugador "', '"Pantalla de titulo: pulsa Start',
]

HIDE = '''// v9c: the missile diagnostic multiboard stays hidden during the title; -misiles still toggles it.
function Title_HideBoard takes nothing returns nothing
    if s__MissileStats_board != null then
        call MultiboardDisplay(s__MissileStats_board, false)
        call DestroyTimer(GetExpiredTimer())
    endif
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    lines = j.split('\n')
    for m in MESSAGES:
        hits = [i for i, l in enumerate(lines) if 'DisplayTimedTextToPlayer' in l and m in l]
        assert len(hits) == 1, (m, hits)
        del lines[hits[0]]
    j = '\n'.join(lines)
    j = once(j, 'function Title_Init takes nothing returns nothing\n', HIDE + 'function Title_Init takes nothing returns nothing\n')
    j = once(j, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n'
             '    call TimerStart(CreateTimer(), 0.02, true, function Title_HideBoard)\n')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
