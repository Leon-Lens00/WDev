#!/usr/bin/env python3
"""Sólo prueba, v15a (a partir de prueba_v14n.py). MODO intro arranca con la intro y el título; MODO directa entra directo a
la partida (Entrada_Directa): son las de Leon. MODO auto entra directo y dispara solo, para evaluar por registro la
sobrecarga, el bloqueo, el refresco y la ráfaga (no se entrega).
En intro y directa, comandos de chat: "-oro N" pone N de oro, "-sob N" pone la sobrecarga a N y "-kits N" da N kits.

Registro oculto (Preload, un archivo por línea en lat\\v15a-N.txt): en intro y directa cada 2 s y hasta 900 líneas (tiempo,
tienda, ronda, descanso, oro, arma, sobrecarga, bloqueo, kits, nivel y refresco en curso); en auto cada 0,5 s y por
cada fase, con los tiros emitidos.
Uso: prueba_v15a.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa', 'auto')
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Prueba_N= 0\ninteger Prueba_T= 0\ninteger Prueba_A= 0\ninteger Prueba_E= 0\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_v15a.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v15a-" + I2S(Prueba_N) + ".txt")
endfunction

function Prueba_Estado takes integer p returns string
    local string s = " arma c" + I2S(Arm_Cat[p]) + " T" + I2S(Arm_Tier[p * 7 + Arm_Cat[p]])
    set s = s + " sob " + R2SW(Sob_Valor[p], 1, 1) + " bloq " + I2S(IntegerTertiaryOp(Sob_Bloq[p], 1, 0))
    set s = s + " kits " + I2S(Sob_Kits[p]) + " nivel " + I2S(Sob_Nivel[p]) + " refresco " + I2S(IntegerTertiaryOp(Arm_Fin[p] > 0., 1, 0))
    return s + " tiros " + I2S(s__RapidPair_emitted)
endfunction

function Prueba_Chat takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    local string m = GetEventPlayerChatString()
    if SubString(m, 0, 5) == "-oro " then
        call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, S2I(SubString(m, 5, StringLength(m))))
    elseif SubString(m, 0, 5) == "-sob " then
        set Sob_Valor[p] = RMinBJ(100., S2R(SubString(m, 5, StringLength(m))))
    elseif SubString(m, 0, 6) == "-kits " then
        set Sob_Kits[p] = S2I(SubString(m, 6, StringLength(m)))
    else
        return
    endif
    call Prueba_Log("chat " + m + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Estado(p))
    if Shop_Open[p] then
        call Shop_Refrescar(p)
    endif
endfunction

function Prueba_Tick takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    set Prueba_T = Prueba_T + 2
    if Prueba_N >= 900 then
        call PauseTimer(GetExpiredTimer())
        return
    endif
    call Prueba_Log("t " + I2S(Prueba_T) + " tienda " + I2S(IntegerTertiaryOp(Shop_Open[p], 1, 0)) + " ronda " + I2S(Ronda_Numero) + " descanso " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Estado(p))
endfunction

// MODO auto: un paso cada 0,5 s (Prueba_A). Dispara hacia +X con la orden de Disparo (Arp1, carrionswarm) del
// controlador, como un clic del jugador; F es la orden stomp de Aw08.
function Prueba_Fuego takes nothing returns nothing
    call IssuePointOrder(Game_Ctrl[0], "carrionswarm", GetUnitX(Game_Hero[0]) + 600., GetUnitY(Game_Hero[0]))
endfunction

function Prueba_Unidad takes unit u returns string
    return " oculto " + I2S(IntegerTertiaryOp(IsUnitHidden(u), 1, 0)) + " x " + R2SW(GetUnitX(u), 1, 1) + " y " + R2SW(GetUnitY(u), 1, 1) + " alto " + R2SW(GetUnitFlyHeight(u), 1, 1)
endfunction

function Prueba_Fase takes string f returns nothing
    call Prueba_Log("fase " + f + " a " + I2S(Prueba_A) + Prueba_Estado(0))
    call Prueba_Log("barra" + Prueba_Unidad(Sob_Barra[0]) + " marco" + Prueba_Unidad(Arm_Blindaje[0]))
endfunction

// Refrescar (orden stomp de Aw08): registra si la orden se aceptó y la orden que tenía el controlador.
function Prueba_Refrescar takes nothing returns nothing
    local string antes = OrderId2String(GetUnitCurrentOrder(Game_Ctrl[0]))
    local boolean ok = IssueImmediateOrder(Game_Ctrl[0], "stomp")
    call Prueba_Log("orden stomp " + I2S(IntegerTertiaryOp(ok, 1, 0)) + " antes " + antes + " ahora " + OrderId2String(GetUnitCurrentOrder(Game_Ctrl[0])) + " refresco " + I2S(IntegerTertiaryOp(Arm_Fin[0] > 0., 1, 0)))
endfunction

function Prueba_Auto takes nothing returns nothing
    local integer a
    if Game_Hero[0] == null or Game_Ctrl[0] == null then
        return
    endif
    set Prueba_A = Prueba_A + 1
    set a = Prueba_A
    if a == 1 then
        call SetUnitInvulnerable(Game_Hero[0], true)
        call Prueba_Fase("inicio")
    elseif a == 6 then
        // Pistola T1 sin parar 9 s: debe mantenerse (calor 8/s, refresco 8/s).
        call Arm_Elegir(0, 0)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
        call Prueba_Fase("pistola")
    elseif a > 6 and a <= 24 then
        if ModuloInteger(a - 6, 3) == 0 then
            call Prueba_Fuego()
        endif
    elseif a == 25 then
        call Prueba_Log("pistola tiros " + I2S(s__RapidPair_emitted - Prueba_E))
        set Sob_Valor[0] = 0.
        // Francotirador sin parar hasta bloquearse (máx. 20 s) y 3 s más intentando.
        call Arm_Elegir(0, 3)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
        call Prueba_Fase("franco")
    elseif a > 25 and a <= 65 and Prueba_E >= 0 then
        if Sob_Bloq[0] then
            call Prueba_Log("bloqueo tiros " + I2S(s__RapidPair_emitted - Prueba_E))
            call Prueba_Fase("bloqueo")
            set Prueba_E = - 1
            set Prueba_A = 70
        elseif ModuloInteger(a - 25, 3) == 0 then
            call Prueba_Fuego()
        endif
    elseif a > 70 and a <= 76 then
        // Bloqueada: los intentos no deben emitir.
        if a == 71 then
            set Prueba_E = s__RapidPair_emitted
        endif
        call Prueba_Fuego()
        if a == 76 then
            call Prueba_Log("bloqueada intentos tiros " + I2S(s__RapidPair_emitted - Prueba_E))
        endif
    elseif a > 76 and a <= 140 and Prueba_E >= 0 then
        if not Sob_Bloq[0] then
            call Prueba_Fase("desbloqueo")
            set Prueba_E = - 1
            set Prueba_A = 140
        endif
    elseif a == 141 then
        // Refrescar y disparar a los 0,5 s: se cancela y el kit se conserva.
        set Sob_Valor[0] = 50.
        call Prueba_Refrescar()
    elseif a == 142 then
        call Prueba_Fase("refrescando")
        call Prueba_Fuego()
    elseif a == 143 then
        call Prueba_Fase("cancelado")
    elseif a == 150 then
        // Refrescar entero: sobrecarga 0 y un kit menos.
        set Sob_Valor[0] = 80.
        call Prueba_Refrescar()
        call Prueba_Fase("refresco2")
    elseif a == 156 then
        call Prueba_Fase("refrescado")
        set Sob_Valor[0] = 40.
        call Prueba_Refrescar()
    elseif a == 157 then
        call Prueba_Fase("sinkits")
        // Una ráfaga de cada arma: 3 tiros escopeta, 12 subfusil, 6 pistola, 3 francotirador.
        set Sob_Valor[0] = 0.
        call Arm_Elegir(0, 2)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
    elseif a == 162 then
        call Prueba_Log("rafaga escopeta tiros " + I2S(s__RapidPair_emitted - Prueba_E) + Prueba_Estado(0))
        set Sob_Valor[0] = 0.
        call Arm_Elegir(0, 1)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
    elseif a == 167 then
        call Prueba_Log("rafaga subfusil tiros " + I2S(s__RapidPair_emitted - Prueba_E) + Prueba_Estado(0))
        set Sob_Valor[0] = 0.
        call Arm_Elegir(0, 0)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
    elseif a == 172 then
        call Prueba_Log("rafaga pistola tiros " + I2S(s__RapidPair_emitted - Prueba_E) + Prueba_Estado(0))
        set Sob_Valor[0] = 0.
        call Arm_Elegir(0, 3)
        set Prueba_E = s__RapidPair_emitted
        call Prueba_Fuego()
    elseif a == 177 then
        call Prueba_Log("rafaga franco tiros " + I2S(s__RapidPair_emitted - Prueba_E) + Prueba_Estado(0))
        call Prueba_Log("COMPLETE")
        call PauseTimer(GetExpiredTimer())
        return
    endif
    call Prueba_Log("auto " + I2S(a) + Prueba_Estado(0))
endfunction

function Prueba_Iniciar takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function Prueba_Chat)
    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)
    set t = null
endfunction

function Intro_Begin takes nothing returns nothing
''')
inicio = 'Intro_Begin' if modo == 'intro' else 'Entrada_Directa'
arranque = 'call TimerStart(CreateTimer(), 0.5, true, function Prueba_Auto)' if modo == 'auto' else 'call Prueba_Iniciar()'
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
              arranque + '\n    call TimerStart(CreateTimer(), 0.1, false, function ' + inicio + ')')
Path(sal).write_text(s, encoding='latin-1', newline='')
