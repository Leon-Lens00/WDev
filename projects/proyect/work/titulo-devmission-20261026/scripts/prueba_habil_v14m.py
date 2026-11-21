#!/usr/bin/env python3
"""Sólo prueba, v14m: habilidades del Prawn sin oleadas (05/11/2026). NO integrar. Parte del j de v14m con registro.

Entrada directa; la oleada no arranca (DevWave_Arrancar no llama a Ronda_Lanzar). A los 2 s crea para el jugador 8,
alrededor del personaje del jugador 0: tres 'nlpr' (todos embisten; uno a 20 de vida para Endurecer), una élite
'ne01' y el jefe 'nj02'. Al personaje se le rellena la vida cada 0,1 s para que no muera. Cada refuerzo mide la defensa
con 10 de daño Estándar (Hab_Medir); lo evalúa leer-habil-v14m.py. A los 45 s escribe FIN.
Uso: prueba_habil_v14m.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'function Hab_Medir takes unit u returns nothing\nendfunction\n', r'''function Hab_Medir takes unit u returns nothing
    local real v = GetWidgetLife(u)
    call UnitDamageTarget(Game_Hero[0], u, 10., false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, null)
    call Hab_Log("medir " + I2S(GetUnitTypeId(u)) + " extra " + I2S(GetUnitAbilityLevel(u, 'AId3') * 3 + GetUnitAbilityLevel(u, 'AId5') * 5) + " perdida " + I2S(R2I((v - GetWidgetLife(u)) * 100. + 0.5)))
    call SetWidgetLife(u, v)
endfunction
''')
s = base.once(s, 'function DevWave_Arrancar takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_habil_v14m.py).
function Habil_Vida takes nothing returns nothing
    if Game_Hero[0] != null and UnitAlive(Game_Hero[0]) then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
endfunction

function Habil_Fin takes nothing returns nothing
    call Hab_Log("FIN")
endfunction

function Habil_Crear takes integer id, real ang, real dist returns unit
    local unit h = Game_Hero[0]
    set bj_lastCreatedUnit = CreateUnit(Player(8), id, GetUnitX(h) + dist * Cos(ang * bj_DEGTORAD), GetUnitY(h) + dist * Sin(ang * bj_DEGTORAD), ang + 180.)
    call Hab_Alta(bj_lastCreatedUnit)
    call SaveBoolean(Hab_HT, GetHandleId(bj_lastCreatedUnit), 14, true)
    call IssueTargetOrder(bj_lastCreatedUnit, "attack", h)
    call Hab_Log("crear " + I2S(id) + " x " + R2S(GetUnitX(bj_lastCreatedUnit)) + " y " + R2S(GetUnitY(bj_lastCreatedUnit)))
    set h = null
    return bj_lastCreatedUnit
endfunction

function Habil_Prueba takes nothing returns nothing
    call InitHostileNeutralAlliances()
    call Hab_Log("inicio heroe x " + R2S(GetUnitX(Game_Hero[0])) + " y " + R2S(GetUnitY(Game_Hero[0])) + " vida " + R2S(GetWidgetLife(Game_Hero[0])))
    call Habil_Crear('nlpr', 0., 700.)
    call Habil_Crear('nlpr', 120., 700.)
    call SetWidgetLife(Habil_Crear('nlpr', 240., 700.), 20.)
    call Habil_Crear('ne01', 60., 850.)
    call Habil_Crear('nj02', 180., 1000.)
    call TimerStart(CreateTimer(), 0.1, true, function Habil_Vida)
    call TimerStart(CreateTimer(), 45., false, function Habil_Fin)
endfunction

function DevWave_Arrancar takes nothing returns nothing
''')
s = base.once(s, '    call Hab_Iniciar()\n    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call Ronda_Lanzar()\n',
              '    call Hab_Iniciar()\n    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call TimerStart(CreateTimer(), 2., false, function Habil_Prueba)\n')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
