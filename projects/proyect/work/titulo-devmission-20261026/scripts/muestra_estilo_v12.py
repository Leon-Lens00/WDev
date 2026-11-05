"""Sample of texttag styling without a font change (Dev Mission title, 30/10/2026). NOT for integration.

Patches the frame bridge's war3map.j: on the strategy board, two titles built only with texttags, left a plain tag
beside right a styled one (per-letter gradient colours over a dark shadow and a blue glow, each one more tag).

Usage: muestra_estilo_v12.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


def grad(text, a, b):
    """text with each letter's colour between a and b, centre lighter, as the mockup's lettering."""
    out = ''
    n = max(len(text) - 1, 1)
    for i, c in enumerate(text):
        t = abs(2 * i / n - 1)
        col = [round(a[k] + (b[k] - a[k]) * t) for k in range(3)]
        out += '|cff%02x%02x%02x%s|r' % (*col, c) if c != ' ' else ' '
    return out


FUNCS = '''function Muestra_Tag takes string txt, real x, real y, real size, real wid, integer r, integer g, integer b returns nothing
    local texttag t = CreateTextTag()
    call SetTextTagPermanent(t, true)
    call SetTextTagColor(t, r, g, b, 255)
    call SetTextTagText(t, txt, size)
    call Strat_TextAt(t, x, y, size, wid)
    call SetTextTagVisibility(t, true)
    set t = null
endfunction

function Muestra_Estilo takes string plain, string colored, real x, real y, real size, real wid returns nothing
    local real d = 2
    call Muestra_Tag(plain, x - d, y, size, wid, 40, 110, 255)
    call Muestra_Tag(plain, x + d, y, size, wid, 40, 110, 255)
    call Muestra_Tag(plain, x, y - d, size, wid, 40, 110, 255)
    call Muestra_Tag(plain, x, y + d, size, wid, 40, 110, 255)
    call Muestra_Tag(plain, x + 3, y + 3, size, wid, 0, 4, 20)
    call Muestra_Tag(colored, x, y, size, wid, 255, 255, 255)
endfunction

function Muestra_Show takes nothing returns nothing
    call Muestra_Tag("Fase de estrategia", 330, 300, 0.044, 420, 200, 228, 255)
    call Muestra_Estilo("Fase de estrategia", "%s", 1600, 300, 0.044, 420)
    call Muestra_Tag("Entrando a partida con:", 330, 420, 0.03, 330, 200, 228, 255)
    call Muestra_Estilo("Entrando a partida con:", "%s", 1600, 420, 0.03, 330)
endfunction

''' % (grad('Fase de estrategia', (150, 205, 255), (250, 253, 255)),
       grad('Entrando a partida con:', (150, 205, 255), (250, 253, 255)))

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, 'function Marco_Full takes nothing returns nothing\n', FUNCS + 'function Marco_Full takes nothing returns nothing\n')
    s = once(s, '    call SetTextTagVisibility(Strat_Tag[2], true)\nendfunction\n',
             '    call SetTextTagVisibility(Strat_Tag[2], true)\n    call Muestra_Show()\nendfunction\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
