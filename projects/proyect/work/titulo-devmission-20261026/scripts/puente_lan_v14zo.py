#!/usr/bin/env python3
"""Puente de prueba LAN de v14zo (07/11/2026). NO integrar.

Dos jugadores (J1 y J2), entrada directa. Todo sale de un timer igual en los dos clientes; A es el segundo en que
empieza la primera oleada:
- A+3: J1 mata un enemigo de verdad (UnitDamageTarget desde su personaje, pasa por Oro_Muerte): First Blood de J1.
- A+5: 30 bajas de J1 (Racha_Muerte) en el mismo instante: Ultra Kill y Killing Spree; 10 de J2: Double Kill.
- A+10: 20 bajas más de J2: Triple Kill y Killing Spree (30).
- A+22: J2 pierde una vida y su racha (Racha_Romper): «perdió su racha (30)».
- A+40: FIN.
Vida ilimitada cada 0,03 s. Registro oculto por cliente en lat\\j<jugador>-N.txt (Preload) cada 2 s y en cada paso.
Las líneas de estado (bajas, racha, tiers, vidas, celdas del marcador, filas de anuncio, cola, eventos con su reloj,
el siguiente aleatorio) deben ser iguales en los dos clientes; sólo «local» y «tabla» (marcador visible) cambian.
Uso: puente_lan_v14zo.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'real Title_CX=', 'integer Lan_N= 0\ninteger Lan_T= 0\ninteger Lan_A= 0\nstring Lan_Ev= ""\ngroup Lan_G= CreateGroup()\nreal Title_CX=')
reloj = 'I2S(R2I(100. * TimerGetElapsed(s__RapidPair_clock)))'
s = base.once(s, '''        call Racha_Sonar(Racha_ColaSon[0])
''', '''        call Racha_Sonar(Racha_ColaSon[0])
        set Lan_Ev = Lan_Ev + " T" + I2S(Racha_ColaTipo[0]) + "p" + I2S(Racha_ColaPid[0]) + "@" + ''' + reloj + '''
''')
s = base.once(s, '''            call Racha_VozDe(Racha_VozPid)
''', '''            call Racha_VozDe(Racha_VozPid)
            set Lan_Ev = Lan_Ev + " V" + I2S(Racha_VozPid) + "@" + ''' + reloj + '''
''')
s = base.once(s, 'function Ronda_Hud takes', r'''// TEMPORARY test bridge (scripts/puente_lan_v14zo.py).
function Lan_Log takes string s returns nothing
    set Lan_N = Lan_N + 1
    call PreloadGenClear()
    loop
        exitwhen StringLength(s) == 0
        call Preload(SubString(s, 0, 240))
        set s = SubString(s, 240, StringLength(s))
    endloop
    call PreloadGenEnd("lat\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
endfunction

function Lan_Estado takes string q returns nothing
    local integer p = 0
    local string s = q + " t " + I2S(Lan_T) + " ronda " + I2S(Ronda_Numero) + " cola " + I2S(Racha_ColaN) + " ver " + I2S(Racha_Ver) + " filas [" + Racha_Fila[0] + "][" + Racha_Fila[1] + "][" + Racha_Fila[2] + "]"
    loop
        exitwhen p > 1
        set s = s + " J" + I2S(p + 1) + " total " + I2S(Racha_Total[p]) + " racha " + I2S(Racha_N[p]) + " tier " + I2S(Racha_Tier[p]) + " multi " + I2S(Racha_Multi[p]) + "/" + I2S(Racha_MultiTier[p]) + " vidas " + I2S(Vidas_Actual[p]) + " celdas " + Racha_Celda[p * 4 + 1] + "/" + Racha_Celda[p * 4 + 2] + "/" + Racha_Celda[p * 4 + 3] + " fila " + I2S(Racha_TablaFila[p])
        set p = p + 1
    endloop
    call Lan_Log(s + " ev" + Lan_Ev + " azar " + I2S(GetRandomInt(0, 9999)) + " local J" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + " tabla " + I2S(IntegerTertiaryOp(IsMultiboardDisplayed(Racha_Tabla), 1, 0)))
endfunction

function Lan_Vida takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 1
        if GetUnitTypeId(Game_Hero[p]) != 0 and GetWidgetLife(Game_Hero[p]) > 0.405 then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
endfunction

function Lan_Matar takes integer p returns nothing
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local unit u
    local boolean hecho = false
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX or hecho
        call GroupEnumUnitsOfPlayer(Lan_G, Player(o), null)
        loop
            set u = FirstOfGroup(Lan_G)
            exitwhen u == null
            call GroupRemoveUnit(Lan_G, u)
            if not hecho and GetWidgetLife(u) > 0.405 and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                call UnitDamageTarget(Game_Hero[p], u, 1000000., true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                set hecho = true
            endif
        endloop
        call GroupClear(Lan_G)
        set o = o + 1
    endloop
    set u = null
endfunction

function Lan_Sumar takes integer p, integer n returns nothing
    loop
        exitwhen n <= 0
        call Racha_Muerte(p)
        set n = n - 1
    endloop
endfunction

function Lan_Tick takes nothing returns nothing
    set Lan_T = Lan_T + 1
    if Lan_A == 0 and Ronda_Activa and not Ronda_Descanso then
        set Lan_A = Lan_T
        call Lan_Estado("empieza oleada")
    elseif Lan_A > 0 and Lan_T == Lan_A + 3 then
        call Lan_Matar(0)
        call Lan_Estado("J1 mata uno")
    elseif Lan_A > 0 and Lan_T == Lan_A + 5 then
        call Lan_Sumar(0, 30)
        call Lan_Sumar(1, 10)
        call Lan_Estado("J1 30 y J2 10")
    elseif Lan_A > 0 and Lan_T == Lan_A + 10 then
        call Lan_Sumar(1, 20)
        call Lan_Estado("J2 20")
    elseif Lan_A > 0 and Lan_T == Lan_A + 22 then
        set Vidas_Actual[1] = Vidas_Actual[1] - 1
        call Racha_Romper(1)
        call Lan_Estado("J2 cae")
    elseif Lan_A > 0 and Lan_T == Lan_A + 40 then
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

function Ronda_Hud takes''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Lan_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
