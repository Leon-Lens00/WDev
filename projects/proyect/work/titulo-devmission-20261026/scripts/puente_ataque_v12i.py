"""Puente de prueba de un jugador (Dev Mission v12i, 30/10/2026). NO integrar.

El personaje no debe tener ataque nativo: con un enemigo al lado no lo persigue y al recibir golpes no responde.
La rafaga, el movimiento y la animacion deben seguir funcionando.
Uso: puente_ataque_v12i.py IN_J OUT_J [CELDA]
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_ataque_v12i.py).
integer Sonda_Paso = 0
integer Sonda_N = 0
unit Sonda_Blanco = null
real Sonda_X = 0
real Sonda_Y = 0
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_ataque_v12i.py).
function Sonda_Log takes string s returns nothing
    set Sonda_N = Sonda_N + 1
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, s)
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\\\\\j1-" + I2S(Sonda_N) + ".txt")
endfunction

function Sonda_B takes boolean b returns integer
    if b then
        return 1
    endif
    return 0
endfunction

function Sonda_Estado takes string s returns nothing
    local unit h = Game_Hero[0]
    call Sonda_Log(UnitId2String(GetUnitTypeId(h)) + " " + GetUnitName(h) + " tipo " + I2S(GetUnitTypeId(h)) + " heroe " + I2S(Sonda_B(IsUnitType(h, UNIT_TYPE_HERO))) + " maxvida " + I2S(R2I(GetUnitState(h, UNIT_STATE_MAX_LIFE))) + " " + s + " paso " + I2S(Sonda_Paso) + " pos " + I2S(R2I(GetUnitX(h))) + "," + I2S(R2I(GetUnitY(h))) + " Aatk " + I2S(GetUnitAbilityLevel(h, 'Aatk')) + " orden " + I2S(GetUnitCurrentOrder(h)) + " vida " + I2S(R2I(GetWidgetLife(h))) + " blanco " + I2S(R2I(GetWidgetLife(Sonda_Blanco))) + " tiros " + I2S(s__RapidPair_emitted) + " golpes " + I2S(s__RapidBolt_hits) + " muros " + I2S(s__RapidBolt_walls))
    set h = null
endfunction

function Sonda_Timer takes nothing returns nothing
    local unit h = Game_Hero[0]
    local unit c = Game_Ctrl[0]
    if h == null then
        return
    endif
    set Sonda_Paso = Sonda_Paso + 1
    if Sonda_Paso == 1 then
        set Sonda_X = GetUnitX(h)
        set Sonda_Y = GetUnitY(h)
        set Sonda_Blanco = CreateUnit(Player(12), 'hfoo', Sonda_X - 260, Sonda_Y, 0)
        call PauseUnit(Sonda_Blanco, true)
        call Sonda_Estado("inicio")
    elseif Sonda_Paso == 5 then
        call Sonda_Estado("quieto con enemigo cerca")
    elseif Sonda_Paso == 6 then
        call IssuePointOrder(c, "channel", GetUnitX(Sonda_Blanco), GetUnitY(Sonda_Blanco))
    elseif Sonda_Paso == 8 then
        call Sonda_Estado("rafaga")
    elseif Sonda_Paso == 9 then
        call IssuePointOrder(c, "move", GetUnitX(h), GetUnitY(h) - 200)
    elseif Sonda_Paso == 12 then
        call Sonda_Estado("movido")
        set Sonda_X = GetUnitX(h)
        set Sonda_Y = GetUnitY(h)
        call PauseUnit(Sonda_Blanco, false)
        call IssueTargetOrder(Sonda_Blanco, "attack", h)
    elseif Sonda_Paso == 18 then
        call Sonda_Estado("atacado")
    elseif Sonda_Paso == 24 then
        call Sonda_Estado("final")
        call DestroyTimer(GetExpiredTimer())
    endif
    set h = null
    set c = null
endfunction

function Puente_Juego takes nothing returns nothing
    call Title_Exit()
    set Hero_Choice[0] = CELDA
    call Title_Black(255, 0, 0.2)
    call DestroyTimer(GetExpiredTimer())
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    cell = sys.argv[3] if len(sys.argv) > 3 else '0'
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', FUNCS.replace('CELDA', cell) + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n'
                  '    call TimerStart(CreateTimer(), 1., true, function Sonda_Timer)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
