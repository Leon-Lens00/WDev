"""Dev Mission v12w (31/10/2026): dash lanzado a un punto y 3 rondas.

El punto solo da la dirección: la distancia sigue siendo DASH_DISTANCE. Una sola habilidad, 'Ard1', en D.
Uso: dash_v12w.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

CAMBIOS = (
    ('constant integer Ronda_TOTAL = 10\n', 'constant integer Ronda_TOTAL = 3\n'),
    ('    function s__RapidPair_dash takes integer this,boolean backward returns nothing\n',
     '    function s__RapidPair_dash takes integer this,real tx,real ty returns nothing\n'),
    ('''        if s__RapidPair_firing[this] then
            set angle=Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        endif
        if backward then
            set angle=angle + bj_PI
        endif
        call s__RapidPair_hideDash(this)
''', '''        // The point only gives the direction: every dash covers DASH_DISTANCE.
        if tx != x or ty != y then
            set angle=Atan2(ty - y, tx - x)
        endif
        call s__RapidPair_hideDash(this)
'''),
    ('''        if not s__RapidPair_firing[this] then
            call SetUnitTimeScale(s__RapidPair_actor[this], s__RapidPair_DASH_ANIMATION_SCALE)
''', '''        if not s__RapidPair_firing[this] then
            call SetUnitFacing(s__RapidPair_actor[this], angle * bj_RADTODEG)
            call SetUnitTimeScale(s__RapidPair_actor[this], s__RapidPair_DASH_ANIMATION_SCALE)
'''),
    # The burst keeps looking at the clicked point while the dash carries the actor sideways.
    ('real array s__RapidPair_aimX\n', 'real array s__RapidPair_aimX\nreal array s__RapidPair_pickX\nreal array s__RapidPair_pickY\n'),
    ('        call s__RapidPair_aimAt(this,px , py)\n', '        set s__RapidPair_pickX[this]=px\n        set s__RapidPair_pickY[this]=py\n        call s__RapidPair_aimAt(this,px , py)\n'),
    ('''        // The aim travels with the actor: facing and burst direction stay the same.
        set s__RapidPair_aimX[this]=s__RapidPair_aimX[this] + GetUnitX(s__RapidPair_actor[this]) - x
        set s__RapidPair_aimY[this]=s__RapidPair_aimY[this] + GetUnitY(s__RapidPair_actor[this]) - y
''', '''        if s__RapidPair_firing[this] then
            call s__RapidPair_aimAt(this,s__RapidPair_pickX[this] , s__RapidPair_pickY[this])
        endif
'''),
    ("            call s__RapidPair_dash(this,GetSpellAbilityId() == 'Ard2')\n", '            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())\n'),
    ("        call RegisterSpellEffectEvent('Ard2' , function s__RapidPair_dashSpell)\n", ''),
    ("    call UnitAddAbility(Game_Ctrl[p], 'Ard2')\n", ''),
)

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    for old, new in CAMBIOS:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok')
