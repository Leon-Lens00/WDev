#!/usr/bin/env python3
"""Sólo prueba, v14n (copia de prueba_v14l.py): para que Leon juegue él mismo. MODO intro arranca con la intro y el título; MODO directa entra
directo a la partida (Entrada_Directa); MODO tienda entra directo, mata sólo la primera oleada y en su descanso lleva al
héroe junto al golem, le da 3000 de oro y abre la tienda, para revisar zonas de clic, retratos y botones.
En los tres, comandos de chat: "-oro N" pone N de oro y "-vaciar" deja sin reserva las armas con munición.

Registro oculto (Preload, un archivo por línea en lat\\v14n-N.txt), cada 2 s y hasta 900 líneas (30 min): tiempo, tienda,
ronda, descanso, oro y por arma con munición su nivel y reserva/máximo.
Uso: prueba_v14n.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
PINTADA = False  # v14n: la tienda con su aspecto normal (las zonas pintadas siguen en v14k-tienda)
assert modo in ('intro', 'directa', 'tienda')
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Prueba_N= 0\ninteger Prueba_T= 0\ninteger Prueba_A= 0\ngroup Prueba_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_v14n.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v14n-" + I2S(Prueba_N) + ".txt")
endfunction

function Prueba_Armas takes integer p returns string
    local integer c = 0
    local integer i
    local string s = ""
    loop
        exitwhen c > 6
        set i = p * 7 + c
        if Arm_Tier[i] > 0 and c != 5 then
            set s = s + " c" + I2S(c) + " T" + I2S(Arm_Tier[i]) + " " + I2S(Arm_Rva[i]) + "/" + I2S(Arm_Res[c * 3 + Arm_Tier[i] - 1])
        endif
        set c = c + 1
    endloop
    return s
endfunction

// Lleva al héroe junto al golem en el primer descanso y abre la tienda con 3000 de oro (MODO tienda).
function Prueba_Tienda takes nothing returns nothing
    local integer o
    local unit u
    if Prueba_A < 0 or Game_Hero[0] == null then
        return
    endif
    if Ronda_Activa and not Ronda_Descanso and Ronda_Numero <= 1 then
        set o = WAVE_DEFAULT_OWNER_MIN
        loop
            exitwhen o > WAVE_DEFAULT_OWNER_MAX
            call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
            loop
                set u = FirstOfGroup(Prueba_G)
                exitwhen u == null
                call GroupRemoveUnit(Prueba_G, u)
                if GetWidgetLife(u) > 0.405 then
                    call KillUnit(u)
                endif
            endloop
            set o = o + 1
        endloop
    elseif Ronda_Descanso and DevTienda_Estado == 2 and Prueba_A == 0 then
        call SetUnitPosition(Game_Hero[0], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem))
        set Prueba_A = 1
    elseif Prueba_A > 0 then
        set Prueba_A = Prueba_A + 1
        if Prueba_A == 3 then
            call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 3000)
            call Shop_Abrir(0)
            call Prueba_Log("tienda abierta " + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)))
            set Prueba_A = -1
        endif
    endif
    set u = null
endfunction

function Prueba_Chat takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    local string m = GetEventPlayerChatString()
    local integer c = 0
    if SubString(m, 0, 5) == "-oro " then
        call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, S2I(SubString(m, 5, StringLength(m))))
    elseif m == "-vaciar" then
        loop
            exitwhen c > 6
            if Arm_Tier[p * 7 + c] > 0 and c != 5 then
                set Arm_Rva[p * 7 + c] = 0
            endif
            set c = c + 1
        endloop
    else
        return
    endif
    call Prueba_Log("chat " + m + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Armas(p))
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
    call Prueba_Log("t " + I2S(Prueba_T) + " tienda " + I2S(IntegerTertiaryOp(Shop_Open[p], 1, 0)) + " ronda " + I2S(Ronda_Numero) + " descanso " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Armas(p))
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
extra = '\n    call TimerStart(CreateTimer(), 1., true, function Prueba_Tienda)' if modo == 'tienda' else ''
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
              'call Prueba_Iniciar()' + extra + '\n    call TimerStart(CreateTimer(), 0.1, false, function ' + inicio + ')')
if PINTADA:
    # Zonas de clic pintadas: los cuadros al 60 % y sin fondo para ver debajo los modelos de los trackables, que están en el suelo.
    s = base.once(s, '    if on then\n        set a = 255\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =',
                  '    if on then\n        set a = 150\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =')
    # Sin el fondo a pantalla completa (ShopPlano), que tapa el suelo donde están las zonas de clic.
    s = base.once(s, '            set path = "war3mapImported\\\\ShopPlano.mdx"\n', '            set path = ""\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
