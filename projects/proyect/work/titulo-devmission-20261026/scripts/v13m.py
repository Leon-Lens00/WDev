#!/usr/bin/env python3
"""v13m: v13l con el dash nuevo y la altura de los misiles como parámetro.

Dash: cancela el disparo rápido y su movimiento artificial, siempre gira al punto de cast,
llega en 0,375 s (0,5 - 25 %, 1200 u/s) y el efecto va en el pecho de la misma unidad, sin dummy.
La animación sube en proporción para seguir cabiendo en el trayecto.
Misiles: vuelven a la altura fija de 70 en una sola constante. El impacto es plano y no cambia.

Uso: v13m.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base


def aplicar(j_in, j_out):
    s = Path(j_in).read_text(encoding='latin-1', newline='')

    s = base.once(s, 'constant real s__RapidPair_DASH_TIME= 0.5\n', 'constant real s__RapidPair_DASH_TIME= 0.375\n')
    s = base.once(s, 'constant real s__RapidPair_DASH_ANIMATION_SCALE= 2.5\n', 'constant real s__RapidPair_DASH_ANIMATION_SCALE= 3.33\n')
    s = base.once(s, 'constant real s__RapidPair_DASH_VISUAL_SCALE= 1.\n', '')
    s = base.once(s, 'unit array s__RapidPair_dashCarrier\n', '')

    s = base.once(s, '''    // The death flash stays where the dash ended; the recycler keeps the carrier
    // long enough for it to play.
    function s__RapidPair_hideDash takes integer this returns nothing
        if s__RapidPair_dashEffect[this] != null then
            call DestroyEffect(s__RapidPair_dashEffect[this])
            call RecycleMissile(s__RapidPair_dashCarrier[this])
            set s__RapidPair_dashEffect[this]=null
            set s__RapidPair_dashCarrier[this]=null
        endif
''', '''    function s__RapidPair_hideDash takes integer this returns nothing
        if s__RapidPair_dashEffect[this] != null then
            call DestroyEffect(s__RapidPair_dashEffect[this])
            set s__RapidPair_dashEffect[this]=null
        endif
''')

    s = base.once(s, '''        call s__RapidPair_hideDash(this)
        set s__RapidPair_dashes=s__RapidPair_dashes + 1
''', '''        call s__RapidPair_hideDash(this)
        // The dash replaces the burst and its artificial walk.
        call s__RapidPair_finish(this,false)
        set s__RapidPair_dashes=s__RapidPair_dashes + 1
''')

    s = base.once(s, '''        if not s__RapidPair_firing[this] then
            call SetUnitFacing(s__RapidPair_actor[this], angle * bj_RADTODEG)
            call SetUnitTimeScale(s__RapidPair_actor[this], s__RapidPair_DASH_ANIMATION_SCALE)
        endif
''', '''        call SetUnitFacing(s__RapidPair_actor[this], angle * bj_RADTODEG)
        call SetUnitTimeScale(s__RapidPair_actor[this], s__RapidPair_DASH_ANIMATION_SCALE)
''')

    inicio = s.index('        set s__RapidPair_dashCarrier[this]=GetRecycledMissile(')
    fin = s.index('\r\n', s.index('set s__RapidPair_dashEffect[this]=AddSpecialEffectTarget(', inicio)) + 2
    s = s[:inicio] + (
        '        set s__RapidPair_dashEffect[this]=AddSpecialEffectTarget('
        's__RapidBolt_dashModelOf(s__RapidPair_color(this) , s__RapidPair_family[this]), '
        's__RapidPair_actor[this], "chest")\r\n') + s[fin:]

    s = base.once(s, '''        call SetUnitX(s__RapidPair_dashCarrier[this], GetUnitX(s__RapidPair_actor[this]))
        call SetUnitY(s__RapidPair_dashCarrier[this], GetUnitY(s__RapidPair_actor[this]))
''', '')

    s = base.once(s, 'constant real s__RapidBolt_RANGE= 1350.\n',
                  'constant real s__RapidBolt_RANGE= 1350.\nconstant real s__RapidBolt_HEIGHT= 70.\n')
    s = base.once(s, '''        // Fly just above the ground (Z = body radius, relative to terrain): at 70
        // the bolts looked like they passed over units the planar circle hits.
        set m=s__Missile_createXYZ(s__GroundCollision_x , s__GroundCollision_y , s__RapidBolt_radiusFor(color , f) , px , py , s__RapidBolt_radiusFor(color , f))
''', '''        // Flight height over the terrain, the look only: impact is a planar circle.
        set m=s__Missile_createXYZ(s__GroundCollision_x , s__GroundCollision_y , s__RapidBolt_HEIGHT , px , py , s__RapidBolt_HEIGHT)
''')

    assert 'dashCarrier' not in s and 'DASH_VISUAL_SCALE' not in s
    Path(j_out).write_text(s, encoding='latin-1', newline='')


if __name__ == '__main__':
    aplicar(sys.argv[1], sys.argv[2])
