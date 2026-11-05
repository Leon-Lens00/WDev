"""Presentation v10l (Dev Mission title, 29/10/2026): theme synchronised with the intro's own audio, glows in
front and larger.

The user sent the intro recorded with its audio (fuentes/presentacion/referencia-audio.mp4). Its sound matches
the theme (onset-envelope correlation 0.78) from video 1.85 s; from that start its flashes fall at 1.465, 4.784
and 5.399 s of the theme, while the scene's clock m (tracked on the silent reference) has them at 1.85, 5.2 and
5.8: the pictures are 0.4 s late against the music. The visual timeline stays; the theme starts 0.4 s later
(StartSound at Pres_Time 3.4, heard about 0.2 s after it, v10j measured), so its hits fall at m - 0.4.

The glows go in front of everything (depth 330 -> 150, the hydra is at 220, the emblem at 401-404) and 1.45 times
larger: Glow_Vertical's band is 1500 units wide at the start, which at the former scale (2400 units = 1920 px)
left the sides of the screen uncovered. Tested: at 1.45 the horizontal glow covers the screen, the vertical
only about 63 % of its width, so the vertical one is 1.6 times larger again.

Usage: escena_v10l.py IN_J OUT_J (v10k's war3map.j or its bridge copy; CRLF kept).
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
nl = '\r\n' if '\r\n' in s else '\n'


def rep(a, b):
    global s
    a, b = a.replace('\n', nl), b.replace('\n', nl)
    assert s.count(a) == 1, (s.count(a), a[:70])
    s = s.replace(a, b)


rep('''    set Pres_GH = Strat_FxAt('ubta', 961, 430, 330, 0, 1)
    set Pres_GV = Strat_FxAt('ubtb', 961, 430, 330, 0, 1)''', '''    set Pres_GH = Strat_FxAt('ubta', 961, 430, 150, 0, 1)
    set Pres_GV = Strat_FxAt('ubtb', 961, 430, 150, 0, 1)''')
rep('''    local real s = 1920 * (0.544 / 718.18930543) * 330 / 2400''',
    '''    local real s = 1.45 * 1920 * (0.544 / 718.18930543) * 150 / 2400
    if u == Pres_GV then
        set s = s * 1.6
    endif''')
rep('''        set Pres_Step = 2
        call StartSound(Pres_Snd)
''', '''        set Pres_Step = 2
''')
rep('''    // The fade from black at m 0.25 (one tick: the window is as wide as the timer's step).
''', '''    // The theme 0.4 s after the scene's clock (the intro's own audio, v10l; one tick as below).
    if Pres_Step == 2 and Pres_Time >= 3.40 and Pres_Time < 3.42 then
        call StartSound(Pres_Snd)
    endif
    // The fade from black at m 0.25 (one tick: the window is as wide as the timer's step).
''')
Path(sys.argv[2]).write_bytes(s.encode('latin-1'))
print('ok', sys.argv[2])
