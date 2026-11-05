"""Sondas temporales de prueba (Dev Mission v12f, 30/10/2026). NO integrar.

Se aplica sobre un mapa con puente directo. Pulsa un "?" de boss, cuenta lo que queda de la entrada, mete un segundo
jugador falso junto al primero para ver que su barra no se ve, mueve al heroe y cambia su vida, y abre y cierra la
barra enemiga con un objetivo de prueba.
Uso: sonda_v12f.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''integer Sonda_Paso = 0
integer Sonda_Antes = 0
integer Sonda_Salir = 0
integer Sonda_Barrido = 0
unit Sonda_Jefe = null
'''
FUNCS = '''// TEMPORARY test probes (scripts/sonda_v12f.py).
function Sonda_Cuenta takes string s returns nothing
    local group g = CreateGroup()
    local integer n = 0
    local integer t = 0
    local integer i = 0
    call GroupEnumUnitsOfPlayer(g, CAMERA_DUMMY_PLAYER, null)
    set n = CountUnitsInGroup(g)
    loop
        exitwhen i > 15
        call GroupClear(g)
        call GroupEnumUnitsOfPlayer(g, Player(i), null)
        set t = t + CountUnitsInGroup(g)
        set i = i + 1
    endloop
    call DestroyGroup(g)
    set g = null
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12, s + ": dummies " + I2S(n) + ", unidades " + I2S(t))
endfunction

function Sonda_Paso1 takes nothing returns nothing
    local unit h = Game_Hero[Game_First]
    local real m = GetUnitState(h, UNIT_STATE_MAX_LIFE)
    set Sonda_Paso = Sonda_Paso + 1
    if Sonda_Paso > 1 then
        // J2 stays down and right of J1, so that its bar would fall inside J1's screen.
        call SetUnitX(Game_Hero[1], GetUnitX(h) + 520)
        call SetUnitY(Game_Hero[1], GetUnitY(h) - 280)
    endif
    if Sonda_Paso == 1 then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12, "Antes del titulo " + I2S(Sonda_Antes) + ", al salir antes " + I2S(Sonda_Salir) + " tras barrer " + I2S(Sonda_Barrido))
        call Sonda_Cuenta("Tras limpiar")
        set Hero_Choice[1] = 1
        call Game_Enter(1)
        call PauseUnit(Game_Hero[1], true)
        call Sonda_Cuenta("Con J2 falso")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12, "Heroe " + UnitId2String(GetUnitTypeId(h)) + " en " + I2S(R2I(GetUnitX(h))) + ", " + I2S(R2I(GetUnitY(h))))
    elseif Sonda_Paso == 2 then
        call IssuePointOrder(h, "move", GetUnitX(h) + 200, GetUnitY(h))
    elseif Sonda_Paso == 3 then
        call SetWidgetLife(h, m * 0.6)
    elseif Sonda_Paso == 4 then
        call SetWidgetLife(h, m * 0.2)
    elseif Sonda_Paso == 5 then
        set Sonda_Jefe = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'otau', GetUnitX(h) + 300, GetUnitY(h), 180)
        call PauseUnit(Sonda_Jefe, true)
        call HealthBarsTarget(Sonda_Jefe)
    elseif Sonda_Paso == 6 then
        call SetWidgetLife(Sonda_Jefe, GetUnitState(Sonda_Jefe, UNIT_STATE_MAX_LIFE) * 0.5)
    elseif Sonda_Paso == 7 then
        call HealthBarsTarget(null)
        call RemoveUnit(Sonda_Jefe)
        call SetUnitVertexColor(HealthBars__HeroBars[1], 255, 255, 255, 255)
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12, "Control: barra de J2 visible a la fuerza. Dueno heroe " + I2S(GetPlayerId(GetOwningPlayer(h))))
    else
        call Sonda_Cuenta("Fin")
        call DestroyTimer(GetExpiredTimer())
    endif
    set h = null
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function ConversationUI___Start takes nothing returns nothing\n',
                  FUNCS + 'function ConversationUI___Start takes nothing returns nothing\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n',
                  '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n'
                  '    call TimerStart(CreateTimer(), 2.5, true, function Sonda_Paso1)\n')
    s = base.once(s, '    elseif Puente_Paso == 1 and Hero_Ready and Hero_Left <= 10 then\n',
                  '    elseif Puente_Paso == 2 and Boss_Ready then\n'
                  '        set Puente_Paso = 3\n'
                  '        call Boss_OnHit(0, 205)\n'
                  '    elseif Puente_Paso == 1 and Hero_Ready and Hero_Left <= 10 then\n')
    s = base.once(s, '    call GroupEnumUnitsOfPlayer(Title_Keep, CAMERA_DUMMY_PLAYER, null)\n',
                  '    call GroupEnumUnitsOfPlayer(Title_Keep, CAMERA_DUMMY_PLAYER, null)\n'
                  '    set Sonda_Antes = CountUnitsInGroup(Title_Keep)\n')
    s = base.once(s, '    call GroupEnumUnitsOfPlayer(g, CAMERA_DUMMY_PLAYER, null)\n    loop\n        set u = FirstOfGroup(g)\n',
                  '    call GroupEnumUnitsOfPlayer(g, CAMERA_DUMMY_PLAYER, null)\n    set Sonda_Salir = CountUnitsInGroup(g)\n'
                  '    loop\n        set u = FirstOfGroup(g)\n')
    s = base.once(s, '    call DestroyGroup(g)\n    call DestroyGroup(Title_Keep)\n',
                  '    call GroupEnumUnitsOfPlayer(g, CAMERA_DUMMY_PLAYER, null)\n    set Sonda_Barrido = CountUnitsInGroup(g)\n'
                  '    call DestroyGroup(g)\n    call DestroyGroup(Title_Keep)\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
