"""Presentation v10j (Dev Mission title, 29/10/2026): the reference's fade and entry times back.

After v10i the user corrected their earlier request (parts moving from the song's start): in the reference the
three parts come out a little later. Measured on it (m = video - 3.4): black until m 0.25 while the theme already
sounds, the scene fades in over 0.25-0.5, the ring and the bolt enter from off the screen at about 0.7, cross the
centre near 1.0 and are almost still at the overshoot from 1.25; the return (1.45-1.85) and the flash stay.
So the theme starts on black, the fade from black is 0.25 s at m 0.25, and the entry is a cubic ease-out over
0.7-1.45 (98 % of the way by 1.25).
The first v10j test (recorded 29/10/2026) heard the theme's hits at their places (0.72, 1.44 s after its start)
but saw the fade begin at 0.1 and the flash at 1.70: the theme sounds about 0.15 s after StartSound (the mp3's
start-up and the output). With m 0.15 s after StartSound the flashes still came 0.07-0.12 s early (1.73, 5.13,
5.73 at 15 fps), and with 0.25 s 0.07-0.22 s late (2.07, 5.27, 5.87; about one frame between runs), so the scene's clock m
starts 0.2 s after StartSound (Pres_Time 3.2). Then the 2nd and 3rd flashes fell on 5.2 and 5.8 but the first\non 2.0 (its gap to the 2nd 3.2 s instead of 3.35): the first use of White_mask stalls the game, so it is\nloaded while the screen is black.

Usage: tiempos_v10j.py IN_J OUT_J (v10's war3map.j or its bridge copy; CRLF kept).
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
nl = '\r\n' if '\r\n' in s else '\n'


def rep(a, b):
    global s
    a, b = a.replace('\n', nl), b.replace('\n', nl)
    assert s.count(a) == 1, a[:70]
    s = s.replace(a, b)


rep('''// Vertical offset of part i at theme time m (v10, tracked): quartic ease-out from off the screen to the
// overshoot (0-1.45 s), quadratic ease-in back (1.45-1.85 s), dead stop.''',
    '''// Vertical offset of part i at theme time m (v10j, tracked): cubic ease-out from off the screen to the
// overshoot (0.7-1.45 s), quadratic ease-in back (1.45-1.85 s), dead stop.''')
rep('''    if m < 0 then
        return a
    elseif m < 1.45 then
        set t = 1 - m / 1.45
        return a + (p - a) * (1 - t * t * t * t)''', '''    if m < 0.7 then
        return a
    elseif m < 1.45 then
        set t = 1 - (m - 0.7) / 0.75
        return a + (p - a) * (1 - t * t * t)''')
rep('''        call StartSound(Pres_Snd)
        call Pres_Black(255, 0, 0.3)
    elseif Pres_Step == 2 and Pres_Time >= 3.35 then''', '''        call StartSound(Pres_Snd)
    elseif Pres_Step == 2 and Pres_Time >= 3.75 then''')
rep('''    if Pres_Step < 2 then
        return
    endif''', '''    if Pres_Step < 2 then
        return
    endif
    // The fade from black at m 0.25 (one tick: the window is as wide as the timer's step).
    if Pres_Step == 2 and Pres_Time >= 3.45 and Pres_Time < 3.47 then
        call Pres_Black(255, 0, 0.25)
    endif''')
rep('''    set m = Pres_Time - 3.0
''', '''    // The theme is heard about 0.2 s after StartSound (v10j measured).
    set m = Pres_Time - 3.2
''')
rep('''        call Pres_HideBoard()
        call Pres_Build()
''', '''        call Pres_HideBoard()
        call Pres_Build()
        // White_mask loaded in the dark (tinted black, the same full black): its first use stalled the first flash.
        call SetCineFilterTexture("ReplaceableTextures\\\\CameraMasks\\\\White_mask.blp")
        call SetCineFilterStartColor(0, 0, 0, 255)
        call SetCineFilterEndColor(0, 0, 0, 255)
        call SetCineFilterDuration(0)
        call DisplayCineFilter(true)
''')
Path(sys.argv[2]).write_bytes(s.encode('latin-1'))
print('ok', sys.argv[2])
