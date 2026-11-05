#!/usr/bin/env python3
"""v13j: v13h con el dash a 100 pasos por segundo en lugar de 32.

El dash movía al personaje 28 unidades de golpe 32 veces por segundo y la cámara lo sigue
sin suavizado, así que la pantalla entera saltaba a 32 pasos durante medio segundo.
Misma distancia y duración: 9 unidades cada 0,01 s, en un temporizador solo para dashes.

Uso: v13j.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

TIMER_DASH = '''    function s__RapidPair_tickDash takes nothing returns nothing
        local integer this= s__RapidPair_first
        local integer following
        loop
            exitwhen this == 0
            set following=s__RapidPair_next[this]
            if s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                call s__RapidPair_stepDash(this)
            endif
            set this=following
        endloop
    endfunction
'''


def aplicar(j_in, j_out):
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, '''        call s__GroundMotion_step(s__RapidPair_motion[this],1. / 32.)
        if s__RapidPair_firing[this] then
            call s__RapidPair_aimAt(this,s__RapidPair_pickX[this] , s__RapidPair_pickY[this])
        endif
        call SetUnitX(s__RapidPair_dashCarrier[this]''', '''        call s__GroundMotion_step(s__RapidPair_motion[this],0.01)
        if s__RapidPair_firing[this] then
            call s__RapidPair_aimAt(this,s__RapidPair_pickX[this] , s__RapidPair_pickY[this])
        endif
        call SetUnitX(s__RapidPair_dashCarrier[this]''')
    s = base.once(s, '''            if s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                call s__RapidPair_stepDash(this)
            endif
            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or''', '''            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or''')
    s = base.once(s, '    function s__RapidPair_tick takes nothing returns nothing\n',
                  TIMER_DASH + '    function s__RapidPair_tick takes nothing returns nothing\n')
    s = base.once(s, '        call TimerStart(s__RapidPair_ticker, 1. / 32., true, function s__RapidPair_tick)\n',
                  '        call TimerStart(s__RapidPair_ticker, 1. / 32., true, function s__RapidPair_tick)\n'
                  '        call TimerStart(CreateTimer(), 0.01, true, function s__RapidPair_tickDash)\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')


if __name__ == '__main__':
    aplicar(sys.argv[1], sys.argv[2])
