"""Medicion de latencia de trackables (Dev Mission v12h, 30/10/2026). NO integrar.

Entra directo a la seleccion de heroe con dos jugadores y 300 s. Cada evento de trackable se escribe en pantalla de TODOS los
clientes: si B ve el hover de A, el evento viaja por la red aunque su efecto sea local.
Uso: puente_latencia_v12h.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_latencia_v12h.py).
integer Puente_Paso = 0
boolean Puente_Listo = false
integer Puente_Eventos = 0
'''
ECO = '''// TEMPORARY test bridge (scripts/puente_latencia_v12h.py).
function Puente_Eco takes string s, integer p, integer k returns nothing
    set Puente_Eventos = Puente_Eventos + 1
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12, I2S(Puente_Eventos) + " " + s + " de J" + I2S(p + 1) + " k" + I2S(k) + " visto en J" + I2S(GetPlayerId(GetLocalPlayer()) + 1))
    // Archivo por evento y cliente: su fecha de modificacion da la hora real de llegada. Solo escribe a disco.
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("x")
    call PreloadGenEnd("lat\\\\v" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Puente_Eventos) + "-" + s + "-J" + I2S(p + 1) + "-k" + I2S(k) + ".txt")
endfunction

'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_latencia_v12h.py).
function Puente_Sim takes nothing returns nothing
    if Puente_Paso == 0 and Puente_Listo then
        set Puente_Paso = 1
        call Mode_Start()
        call Hero_Begin()
    endif
endfunction

function Puente_Directo takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Registered[1] = true
    set Title_Count = 2
    set Title_Left = 999
    call Title_Begin()
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Title_OnTrack takes nothing returns nothing\n', ECO + 'function Title_OnTrack takes nothing returns nothing\n')
    for name, tag in [('Title_OnTrack', 'track'), ('Title_OnHit', 'HIT')]:
        i = s.index('function ' + name + ' takes nothing returns nothing' + base.N)
        j = s.index('    if Boss_Active then' + base.N, i)
        s = s[:j] + '    call Puente_Eco("' + tag + '", p, LoadInteger(Title_HT, id, 1))' + base.N + s[j:]
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', FUNCS + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.25, true, function Puente_Sim)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Directo)\n')
    s = base.once(s, '    set Title_Active = true\n',
                  '    set Title_Active = true\n    set Title_Registered[0] = true\n    set Title_Registered[1] = true\n'
                  '    set Title_Count = 2\n    set Title_Left = 999\n    set Puente_Listo = true\n')
    for old, new in [('call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)', 'call TimerStart(CreateTimer(), 0.3, false, function Hero_Show)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)', 'call TimerStart(GetExpiredTimer(), 0.3, false, function Hero_Go)'),
                     ('call TimerStart(CreateTimer(), 5.6, false, function Panel_Logo)', 'call TimerStart(CreateTimer(), 0.2, false, function Panel_Logo)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Panel_Entry)', 'call TimerStart(GetExpiredTimer(), 0.2, false, function Panel_Entry)'),
                     ('    set Hero_Left = 60\n', '    set Hero_Left = 300\n')]:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
