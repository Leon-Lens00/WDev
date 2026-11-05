"""Presentation v10m (Dev Mission title, 29/10/2026): smaller emblem and hydra, the hydra centred, double glows.

The user asked after v10l: the walking hydra goes out of the emblem and is much larger than the reference's
character, the emblem a little smaller too, and a second set of converging glows at the same time to shine more.
- Reference (intro with audio, character frozen): ring about 600 px in a 742 px tall player (0.81), the character
  about 0.6 of the ring wide and 0.35 tall, centred on it. v10l (diff of the black walking silhouette against the
  emblem alone, 15 frames): about 650 x 450 px against a 700 px ring, centred at (1163, 466) px while the emblem's
  centre is (961, 438): too large and walking on the right half.
- Emblem x0.9 about its centre (sizes, places and the tracked offsets of Pres_Off).
- Hydra x0.6 of v10l relative to the ring (scale 0.408 x 0.6 x 0.9 = 0.220), its origin (the feet) moved so the
  walking body centres on the emblem: v10l's body centre was origin + (77, -174) px, so origin = centre -
  (77, -174) x 0.54 = (919.4, 532.1).
- Glows: Pres_GH2 / Pres_GV2, second units of the same glows, pulsed, ended and removed with the first ones.

Usage: escena_v10m.py IN_J OUT_J (v10l's war3map.j or its bridge copy; CRLF kept).
"""
from pathlib import Path
import re, sys

s = Path(sys.argv[1]).read_bytes().decode('latin-1')
nl = '\r\n' if '\r\n' in s else '\n'


def rep(a, b, n=1):
    global s
    a, b = a.replace('\n', nl), b.replace('\n', nl)
    assert s.count(a) == n, (s.count(a), a[:70])
    s = s.replace(a, b)


rep('''unit Pres_GV= null
''', '''unit Pres_GV= null
unit Pres_GH2= null
unit Pres_GV2= null
''')
# Emblem x0.9 about (961, 438.17).
rep('''function Pres_PX takes integer i returns real
    if i == 2 then
        return 953.1
    endif
    return 954.7
endfunction

function Pres_PY takes integer i returns real
    if i == 0 then
        return 414.2
    elseif i == 1 then
        return 471.0
    endif
    return 415.8
endfunction
''', '''// The emblem's scale about its centre (961, 438.17) (v10m: 0.9).
constant function Pres_L takes nothing returns real
    return 0.9
endfunction

function Pres_PX takes integer i returns real
    if i == 2 then
        return 961 + (953.1 - 961) * Pres_L()
    endif
    return 961 + (954.7 - 961) * Pres_L()
endfunction

function Pres_PY takes integer i returns real
    if i == 0 then
        return 438.17 + (414.2 - 438.17) * Pres_L()
    elseif i == 1 then
        return 438.17 + (471.0 - 438.17) * Pres_L()
    endif
    return 438.17 + (415.8 - 438.17) * Pres_L()
endfunction
''')
rep('''        set a = 900
        set p = -169
    endif
    if m < 0.7 then''', '''        set a = 900
        set p = -169
    endif
    set a = a * Pres_L()
    set p = p * Pres_L()
    if m < 0.7 then''')
rep('''        set Pres_Pic[i] = Title_Pic('uidb', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i], h[i], 404 - i, tex[i])
        set Pres_Hi[i] = Title_Pic('uidg', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i], h[i], 403.5 - i, tex[i])''',
    '''        set Pres_Pic[i] = Title_Pic('uidb', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i] * Pres_L(), h[i] * Pres_L(), 404 - i, tex[i])
        set Pres_Hi[i] = Title_Pic('uidg', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i] * Pres_L(), h[i] * Pres_L(), 403.5 - i, tex[i])''')
# Hydra.
rep('''    set Pres_Hydra = CreateUnit(CAMERA_DUMMY_PLAYER, 'ubt8', Title_WX(640, 220), Title_WY(1086, 220), 0)''',
    '''    // v10m: 0.54 of v10l's size, the walking body centred on the emblem.
    set Pres_Hydra = CreateUnit(CAMERA_DUMMY_PLAYER, 'ubt8', Title_WX(532.1, 220), Title_WY(919.4, 220), 0)''')
rep('''    call SetUnitScale(Pres_Hydra, 0.408, 0.408, 0.408)''', '''    call SetUnitScale(Pres_Hydra, 0.220, 0.220, 0.220)''')
# Second glows.
rep('''    set Pres_GV = Strat_FxAt('ubtb', 961, 430, 150, 0, 1)
''', '''    set Pres_GV = Strat_FxAt('ubtb', 961, 430, 150, 0, 1)
    // A second set at the same place, pulsed together with the first: twice as bright (v10m).
    set Pres_GH2 = Strat_FxAt('ubta', 961, 430, 150, 0, 1)
    set Pres_GV2 = Strat_FxAt('ubtb', 961, 430, 150, 0, 1)
''')
rep('''    if u == Pres_GV then''', '''    if u == Pres_GV or u == Pres_GV2 then''')
for g in ('GH', 'GV'):
    k = s.count(f'call Pres_Pulse(Pres_{g}){nl}')
    s = re.sub(rf'( *)call Pres_Pulse\(Pres_{g}\)\r?\n', lambda m: f'{m.group(0)}{m.group(1)}call Pres_Pulse(Pres_{g}2){nl}', s)
    assert s.count(f'call Pres_Pulse(Pres_{g}2)') == k
    rep(f'''    call Pres_GlowEnd(Pres_{g}, Pres_{g}At, m)
''', f'''    call Pres_GlowEnd(Pres_{g}, Pres_{g}At, m)
    call Pres_GlowEnd(Pres_{g}2, Pres_{g}At, m)
''')
    rep(f'''        call RemoveUnit(Pres_{g})
''', f'''        call RemoveUnit(Pres_{g})
        call RemoveUnit(Pres_{g}2)
''')
    rep(f'''        set Pres_{g} = null
''', f'''        set Pres_{g} = null
        set Pres_{g}2 = null
''')
Path(sys.argv[2]).write_bytes(s.encode('latin-1'))
print('ok', sys.argv[2])
