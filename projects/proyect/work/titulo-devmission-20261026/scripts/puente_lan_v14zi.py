#!/usr/bin/env python3
"""Puente de prueba LAN de v14zi (07/11/2026). NO integrar.

Cuatro jugadores (J1..J4), entrada directa, tarde 4 por defecto. Todo sale de un timer igual en todos los clientes;
A es el segundo en que empieza la primera oleada:
- A+10: J2 usa Recargar batería (orden al controlador, como la V): 100 % y 2 recargas.
- A+12: J3 con 8 s de batería (luz baja, paso 4) y J4 con 0 (sin luz).
- A+20: J4 recarga (vuelve la luz); J1 se queda sin recargas e intenta recargar: el aviso «Sin recargas» sólo en J1.
- A+24: se matan las oleadas hasta el descanso; D+4 FIN (todos a 100 %, +2 recargas).
Vida ilimitada cada 0,03 s. Registro oculto por cliente en lat\\j<jugador>-N.txt (Preload) cada 2 s y en cada paso.
Las líneas de estado (batería, recargas, paso de luz de los cuatro, ronda, el siguiente aleatorio) deben ser
iguales en todos los clientes; sólo "local" cambia.
Uso: puente_lan_v14zi.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'real Title_CX=', 'integer Lan_N= 0\ninteger Lan_T= 0\ninteger Lan_A= 0\ninteger Lan_D= 0\ngroup Lan_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Oro_Muerte takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/puente_lan_v14zi.py).
function Lan_Log takes string s returns nothing
    set Lan_N = Lan_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
endfunction

function Lan_Estado takes string q returns nothing
    local integer p = 0
    local string s = q + " t " + I2S(Lan_T) + " ronda " + I2S(Ronda_Numero) + " desc " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0))
    loop
        exitwhen p > 3
        set s = s + " J" + I2S(p + 1) + " bat " + I2S(R2I(Bat_T[p] * 10.)) + " c " + I2S(Bat_Cargas[p]) + " luz " + I2S(Luz_Nivel[p]) + " slot " + I2S(GetHandleId(GetPlayerSlotState(Player(p))))
        set p = p + 1
    endloop
    call Lan_Log(s + " azar " + I2S(GetRandomInt(0, 9999)) + " local J" + I2S(GetPlayerId(GetLocalPlayer()) + 1))
endfunction

function Lan_Vida takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 3
        if GetUnitTypeId(Game_Hero[p]) != 0 and GetWidgetLife(Game_Hero[p]) > 0.405 then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
endfunction

function Lan_Matar takes nothing returns nothing
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Lan_G, Player(o), null)
        loop
            set u = FirstOfGroup(Lan_G)
            exitwhen u == null
            call GroupRemoveUnit(Lan_G, u)
            if GetWidgetLife(u) > 0.405 then
                call KillUnit(u)
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction

function Lan_Tick takes nothing returns nothing
    set Lan_T = Lan_T + 1
    if Lan_A == 0 and Ronda_Activa and not Ronda_Descanso then
        set Lan_A = Lan_T
        call Lan_Estado("empieza oleada")
    elseif Lan_A > 0 and Lan_T == Lan_A + 10 then
        call IssueImmediateOrder(Game_Ctrl[1], "resurrection")
        call Lan_Estado("J2 recarga")
    elseif Lan_A > 0 and Lan_T == Lan_A + 12 then
        set Bat_T[2] = 8.
        set Bat_T[3] = 0.
        call Lan_Estado("J3 8 s y J4 0 s")
    elseif Lan_A > 0 and Lan_T == Lan_A + 20 then
        call IssueImmediateOrder(Game_Ctrl[3], "resurrection")
        set Bat_Cargas[0] = 0
        call IssueImmediateOrder(Game_Ctrl[0], "resurrection")
        call Lan_Estado("J4 recarga y J1 sin recargas")
    elseif Lan_A > 0 and Lan_T >= Lan_A + 24 and Lan_D == 0 then
        if Ronda_Descanso then
            set Lan_D = Lan_T
            call Lan_Estado("descanso")
        else
            call Lan_Matar()
        endif
    elseif Lan_D > 0 and Lan_T == Lan_D + 4 then
        call Lan_Estado("final")
        call Lan_Log("FIN t " + I2S(Lan_T))
    endif
    if ModuloInteger(Lan_T, 2) == 0 then
        call Lan_Estado("estado")
    endif
endfunction

function Lan_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Lan_Tick)
    call TimerStart(CreateTimer(), 0.03, true, function Lan_Vida)
endfunction

function Oro_Muerte takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Lan_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
