"""v10s: the boss's name at the end of the presentation, as in the user's intro video ("BURN ROOSTER" appears under
the character as it freezes). 'DT3N' PresNombre (texturas_v10s.py, 512 x 64, capitals 40 px tall: 0.063 of the
ring's 630 px, the video's ratio) at 1:1, centred 0.78 of the ring's radius under the emblem's centre
(961, 668: 15 px above v10s's first 683, clear of the ring's band), at depth 360: pictures are sorted by their
distance to the eye, and at 399.5 that far from the centre the name counted as farther than the ring (404) and
was drawn under it. Hidden until the freeze at m 5.8.
Usage: nombre_v10s.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()


def rep(old, new):
    global j
    old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    assert j.count(old) == 1, old
    j = j.replace(old, new)


rep('''unit Pres_Hydra= null
''', '''unit Pres_Hydra= null
unit Pres_Name= null
''')
rep('''    set Pres_Bg = Strat_FxAt('ubt9', 961, 438.17, Title_D() + Title_Eye - 300, 0.65, 1)
''', '''    set Pres_Bg = Strat_FxAt('ubt9', 961, 438.17, Title_D() + Title_Eye - 300, 0.65, 1)
    // The boss's name under the emblem, shown at the freeze (v10s).
    set Pres_Name = Title_Pic('uidb', 961, 668, 512, 64, 360, 'DT3N')
    call Title_Show(Pres_Name, false)
''')
rep('''        set Pres_Step = 7
        call SetUnitTimeScale(Pres_Hydra, 0)
''', '''        set Pres_Step = 7
        call SetUnitTimeScale(Pres_Hydra, 0)
        call Title_Show(Pres_Name, true)
''')
rep('''        call RemoveUnit(Pres_Hydra)
''', '''        call RemoveUnit(Pres_Hydra)
        call RemoveUnit(Pres_Name)
''')
rep('''        set Pres_Hydra = null
''', '''        set Pres_Hydra = null
        set Pres_Name = null
''')
open(dst, 'w', encoding='latin-1', newline='').write(j)
