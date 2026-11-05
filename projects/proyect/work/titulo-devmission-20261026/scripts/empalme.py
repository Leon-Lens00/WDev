"""Splice the title screen into a copy of the trackables v4 script (Dev Mission title, 26/10/2026).

Inserts the globals after the first "globals", defers the dialogue demo's start timer (Title_Exit starts it),
replaces HudMask_Init in main by Title_Init (the mask is applied on leaving) and puts the title functions
before main. Keeps the base's CRLF line ends. Each replaced line must appear exactly once.

Usage: empalme.py BASE_J GLOBALS_J TITLE_J OUT_J
"""
from pathlib import Path
import sys

base, glob, title, out = (Path(a) for a in sys.argv[1:5])
text = base.read_bytes().decode('utf-8')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
pairs = [('    call TimerStart(CreateTimer(), 0.2, false, function ConversationUI___Start)\r\n',
          '    // Dev Mission title: ConversationUI___Start runs from Title_Exit.\r\n'),
         ('    call HudMask_Init()\r\n', '    // Dev Mission title: HudMask_Apply runs from Title_Exit.\r\n    call Title_Init()\r\n'),
         ('\r\nfunction main takes nothing returns nothing\r\n',
          '\r\n' + crlf(title.read_text()) + '\r\nfunction main takes nothing returns nothing\r\n')]
assert text.startswith('globals\r\n')
text = 'globals\r\n' + crlf(glob.read_text()) + text[len('globals\r\n'):]
for old, new in pairs:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
out.write_bytes(text.encode('utf-8'))
print(len(text.splitlines()), 'lines')
