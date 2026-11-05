"""v10t (29/10/2026), after the user's review of v10s:
- the boss's name in the type already used, matching the palette: the boss screen's BossName ('DT30', "Nereus"
  from the mockup's glyphs, texturas_boss.py) instead of v10s's gold PresNombre, at 1:1 (256 x 128, glyphs
  x 29-226, y 45-88: centred 2.5 px low, so the picture goes 2.5 px up);
- the triangle and the W ahead of the ring: they met it at the same level (404 / 403 / 402, and the order can turn
  as they move, pictures being sorted by their distance to the eye). Ring 404, triangle 370, W 340 (additive
  copies 0.5 ahead): at the entry's largest offset (810 px, x1.16 in distance) the W still counts as nearer than
  the ring. Sizes on screen do not change (Title_Pic scales with depth). The name goes to 320, ahead of the W.
Usage: profundidad_v10t.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()


def rep(old, new):
    global j
    old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    assert j.count(old) == 1, old
    j = j.replace(old, new)


rep('''    local real array h
    set tex[0] = 'DT3K'
''', '''    local real array h
    local real array z
    set tex[0] = 'DT3K'
''')
rep('''    set h[2] = 368.9
''', '''    set h[2] = 368.9
    // Depths: the triangle and the W well ahead of the ring (v10t).
    set z[0] = 404
    set z[1] = 370
    set z[2] = 340
''')
rep("w[i] * Pres_L(), h[i] * Pres_L(), 404 - i, tex[i])", "w[i] * Pres_L(), h[i] * Pres_L(), z[i], tex[i])")
rep("w[i] * Pres_L(), h[i] * Pres_L(), 403.5 - i, tex[i])", "w[i] * Pres_L(), h[i] * Pres_L(), z[i] - 0.5, tex[i])")
rep('''    // The boss's name under the emblem, shown at the freeze (v10s).
    set Pres_Name = Title_Pic('uidb', 961, 668, 512, 64, 360, 'DT3N')
''', '''    // The boss's name under the emblem, shown at the freeze (v10s; v10t: the boss screen's type, ahead of the W).
    set Pres_Name = Title_Pic('uidb', 961, 665.5, 256, 128, 320, 'DT30')
''')
open(dst, 'w', encoding='latin-1', newline='').write(j)
