#!/usr/bin/env python3
"""Puente de prueba LAN de v14k (05/11/2026). NO integrar.

Dos jugadores (J1 y J2), entrada directa. Mata la primera oleada; en su descanso, con el golem abajo, lleva a los dos
héroes junto a él y abre la tienda a los dos (Shop_Abrir). Todo sale de un timer igual en los dos clientes:
- A+5: los dos con 5000 de oro; J1 compra subfusil T1 (habla el Tauren) y J2 rifle T1 con Hero_Choice[1] = 1 (habla
  Cairne), en el mismo segundo: cada cliente debe ver sólo su comprador.
- A+9: sólo J2 compra pistola T2: J1 sigue con su retrato.
- A+13: los dos sin reserva; J1 "Abastecer todo" con 100 de oro y J2 con 37.
- A+17: J1 cierra la tienda (J2 la sigue viendo); A+20 la cierra J2; A+23 FIN.
Registro oculto por cliente en lat\\j<jugador>-N.txt (Preload). Las líneas de estado (oro, reservas, tienda abierta,
estado de los dos jugadores, el siguiente aleatorio) deben ser iguales en los dos clientes; sólo "local" cambia.
Uso: puente_lan_v14k.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'real Title_CX=', 'integer Lan_N= 0\ninteger Lan_T= 0\ninteger Lan_A= 0\ngroup Lan_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Oro_Muerte takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/puente_lan_v14k.py).
function Lan_Log takes string s returns nothing
    set Lan_N = Lan_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
endfunction

function Lan_Armas takes integer p returns string
    local integer c = 0
    local integer i
    local string s = " J" + I2S(p + 1) + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + " abierta " + I2S(IntegerTertiaryOp(Shop_Open[p], 1, 0)) + " slot " + I2S(GetHandleId(GetPlayerSlotState(Player(p))))
    loop
        exitwhen c > 6
        set i = p * 7 + c
        if Arm_Tier[i] > 0 and c != 5 then
            set s = s + " c" + I2S(c) + "T" + I2S(Arm_Tier[i]) + " " + I2S(Arm_Rva[i]) + "/" + I2S(Arm_Res[c * 3 + Arm_Tier[i] - 1])
        endif
        set c = c + 1
    endloop
    return s
endfunction

function Lan_Estado takes string q returns nothing
    call Lan_Log(q + " t " + I2S(Lan_T) + Lan_Armas(0) + Lan_Armas(1) + " azar " + I2S(GetRandomInt(0, 9999)) + " local J" + I2S(GetPlayerId(GetLocalPlayer()) + 1))
endfunction

function Lan_Vaciar takes integer p returns nothing
    local integer c = 0
    loop
        exitwhen c > 6
        if Arm_Tier[p * 7 + c] > 0 and c != 5 then
            set Arm_Rva[p * 7 + c] = 0
        endif
        set c = c + 1
    endloop
endfunction

function Lan_Tick takes nothing returns nothing
    local integer o
    local unit u
    set Lan_T = Lan_T + 1
    set o = 0
    loop
        exitwhen o > 1
        if Game_Hero[o] != null then
            call SetWidgetLife(Game_Hero[o], GetUnitState(Game_Hero[o], UNIT_STATE_MAX_LIFE))
        endif
        set o = o + 1
    endloop
    if Ronda_Activa and not Ronda_Descanso then
        set o = WAVE_DEFAULT_OWNER_MIN
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
    elseif Ronda_Descanso and DevTienda_Estado == 2 and Lan_A == 0 then
        call SetUnitPosition(Game_Hero[0], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem) + 80.)
        call SetUnitPosition(Game_Hero[1], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem) - 80.)
        set Lan_A = Lan_T
        call Lan_Estado("junto al golem")
    elseif Lan_A > 0 and Lan_T == Lan_A + 2 then
        call Shop_Abrir(0)
        call Shop_Abrir(1)
        call Lan_Estado("abiertas")
    elseif Lan_A > 0 and Lan_T == Lan_A + 5 then
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 5000)
        call SetPlayerState(Player(1), PLAYER_STATE_RESOURCE_GOLD, 5000)
        set Hero_Choice[0] = 0
        set Hero_Choice[1] = 1
        set Shop_Cat[0] = 1
        set Shop_Ver[0] = 1
        call Shop_Comprar(0)
        set Shop_Cat[1] = 2
        set Shop_Ver[1] = 1
        call Shop_Comprar(1)
        call Lan_Estado("compran J1 Tauren subfusil y J2 Cairne rifle")
    elseif Lan_A > 0 and Lan_T == Lan_A + 9 then
        set Shop_Cat[1] = 0
        set Shop_Ver[1] = 2
        call Shop_Comprar(1)
        call Lan_Estado("compra J2 pistola T2")
    elseif Lan_A > 0 and Lan_T == Lan_A + 13 then
        call Lan_Vaciar(0)
        call Lan_Vaciar(1)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 100)
        call SetPlayerState(Player(1), PLAYER_STATE_RESOURCE_GOLD, 37)
        call Lan_Estado("antes todo")
        call Shop_Todo(0)
        call Shop_Todo(1)
        call Lan_Estado("despues todo")
    elseif Lan_A > 0 and Lan_T == Lan_A + 17 then
        call Shop_Cerrar(0)
        call Lan_Estado("cierra J1")
    elseif Lan_A > 0 and Lan_T == Lan_A + 20 then
        call Shop_Cerrar(1)
        call Lan_Estado("cierra J2")
    elseif Lan_A > 0 and Lan_T == Lan_A + 23 then
        call Lan_Estado("final")
        call Lan_Log("FIN t " + I2S(Lan_T))
    endif
    if Lan_A == 0 and ModuloInteger(Lan_T, 5) == 0 then
        call Lan_Estado("espera")
    endif
    set u = null
endfunction

function Lan_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Lan_Tick)
endfunction

function Oro_Muerte takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Lan_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
