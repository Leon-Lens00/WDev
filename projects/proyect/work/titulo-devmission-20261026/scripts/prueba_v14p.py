#!/usr/bin/env python3
"""Sólo prueba, v14p (a partir de prueba_v14o.py). MODO intro arranca con la intro y el título; MODO directa entra directo a
la partida (Entrada_Directa): son las de Leon. MODO auto entra directo y dispara solo cada arma en sus 6 tiers (no se entrega).
En intro y directa, comandos de chat: "-oro N" pone N de oro, "-vaciar" deja sin reserva las armas con munición y
"-tier N" pone el tier N (1..6) del arma activa con el cargador lleno, para ver el color de su bala.

Registro oculto (Preload, un archivo por línea en lat\\v14p-N.txt): en intro y directa cada 2 s y hasta 900 líneas (tiempo,
tienda, ronda, descanso, oro y por arma con munición su nivel y reserva/máximo). En auto cada 0,5 s: tiros por ráfaga,
modelo de la última bala, dispersión acumulada del rifle y caída/daño de las granadas.
Uso: prueba_v14p.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
PINTADA = False  # v14p: la tienda con su aspecto normal (las zonas pintadas siguen en v14k-tienda)
assert modo in ('intro', 'directa', 'tienda', 'auto')
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Prueba_N= 0\ninteger Prueba_T= 0\ninteger Prueba_A= 0\ngroup Prueba_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_v14p.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v14p-" + I2S(Prueba_N) + ".txt")
endfunction

function Prueba_Armas takes integer p returns string
    local integer c = 0
    local integer i
    local string s = ""
    loop
        exitwhen c > 6
        set i = p * 7 + c
        if Arm_Tier[i] > 0 and c != 5 then
            set s = s + " c" + I2S(c) + " T" + I2S(Arm_Tier[i]) + " " + I2S(Arm_Rva[i]) + "/" + I2S(Arm_Res[c * 6 + Arm_Tier[i] - 1])
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
    elseif SubString(m, 0, 6) == "-tier " then
        set c = IMinBJ(6, IMaxBJ(1, S2I(SubString(m, 6, StringLength(m)))))
        if Arm_Tier[p * 7 + Arm_Cat[p]] == 0 then
            call UnitAddAbility(Game_Ctrl[p], 'Aw00' + Arm_Cat[p])
        endif
        set Arm_Tier[p * 7 + Arm_Cat[p]] = c
        call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00' + Arm_Cat[p], c)
        set Arm_Clip[p * 7 + Arm_Cat[p]] = Arm_Mag[Arm_W(p)]
        set Arm_Rva[p * 7 + Arm_Cat[p]] = Arm_Res[Arm_W(p)]
        call Arm_Pareja(p)
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

if modo == 'auto':
    # Contadores en las funciones del arma (globales: esas funciones van antes que el puente).
    s = base.once(s, 'real Title_CX=', 'integer Prueba_Tiros= 0\ninteger Prueba_EN= 0\nreal Prueba_EX= 0.\nreal Prueba_EY= 0.\nreal Prueba_PX= 0.\nreal Prueba_PY= 0.\ninteger Prueba_B= 0\ninteger Prueba_B0= 0\ninteger Prueba_E0= 0\nreal array Prueba_V\nunit array Prueba_U\nreal Title_CX=')
    s = base.once(s, '        set s__RapidPair_lastMissile[this]=m\n', '        set s__RapidPair_lastMissile[this]=m\n        set Prueba_Tiros=Prueba_Tiros + 1\n')
    s = base.once(s, 'Death de la granada.\n', 'Death de la granada.\n        set Prueba_EN=Prueba_EN + 1\n        set Prueba_EX=x\n        set Prueba_EY=y\n')
    s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// MODO auto: un paso cada 0,5 s. Cada arma y tier: 5 pasos (dispara, espera la ráfaga de 1,5 s y anota).
// Blancos: 3 soldados en línea a 200..340 delante del héroe y uno a 800, donde cae la granada.
function Prueba_Blancos takes nothing returns nothing
    local real x = GetUnitX(Game_Hero[0])
    local real y = GetUnitY(Game_Hero[0])
    local integer i = 0
    loop
        exitwhen i > 3
        if Prueba_U[i] != null then
            call RemoveUnit(Prueba_U[i])
        endif
        set Prueba_U[i] = CreateUnit(Player(WAVE_DEFAULT_OWNER_MIN), 'hfoo', x + 200. + 70. * i, y, 180.)
        if i == 3 then
            call SetUnitX(Prueba_U[i], x + 800.)
        endif
        call PauseUnit(Prueba_U[i], true)
        set Prueba_V[i] = GetWidgetLife(Prueba_U[i])
        set i = i + 1
    endloop
endfunction

function Prueba_Danos takes nothing returns string
    local integer i = 0
    local string s = " dano"
    loop
        exitwhen i > 3
        set s = s + " " + I2S(R2I(Prueba_V[i] - GetWidgetLife(Prueba_U[i])))
        set i = i + 1
    endloop
    return s
endfunction

function Prueba_Fuego takes real d returns nothing
    set Prueba_PX = GetUnitX(Game_Hero[0]) + d
    set Prueba_PY = GetUnitY(Game_Hero[0])
    call Prueba_Log("orden fuego " + I2S(IntegerTertiaryOp(IssuePointOrder(Game_Ctrl[0], "carrionswarm", Prueba_PX, Prueba_PY), 1, 0)))
endfunction

function Prueba_Poner takes integer c, integer t returns nothing
    set Arm_Tier[c] = t
    set Arm_Clip[c] = 200
    set Arm_Rva[c] = 9999
    set Arm_Cat[0] = c
    call Arm_Pareja(0)
    call SetUnitInvulnerable(s__RapidPair_actor[Game_Pair[0]], true)
endfunction

// Texttags libres: se crean hasta que el motor devuelve el id 0 ya usado (lleno) o hasta 100; luego se borran.
function Prueba_Libres takes nothing returns integer
    local texttag array t
    local integer n = 0
    local integer i = 0
    loop
        exitwhen n >= 100
        set t[n] = CreateTextTag()
        exitwhen n > 0 and GetHandleId(t[n]) == 0
        set n = n + 1
    endloop
    loop
        exitwhen i >= n
        call DestroyTextTag(t[i])
        set t[i] = null
        set i = i + 1
    endloop
    return n
endfunction

// Como Shop_Abrir sin pedir descanso ni golem cerca (sólo prueba).
function Prueba_AbrirTienda takes integer c, integer ver returns nothing
    set Shop_Open[0] = true
    set Shop_Abiertos = Shop_Abiertos + 1
    set Shop_Cat[0] = c
    set Shop_Ver[0] = ver
    if GetLocalPlayer() == Player(0) then
        call ResetToGameCamera(0)
        call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    endif
    call Shop_Camara(0)
    if GetLocalPlayer() == Player(0) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(0, true)
    call Shop_Refrescar(0)
endfunction

function Prueba_Modelo takes nothing returns string
    if Game_Pair[0] == 0 or s__RapidPair_lastMissile[Game_Pair[0]] == 0 then
        return " modelo -"
    endif
    return " modelo " + s__Missile_path[s__RapidPair_lastMissile[Game_Pair[0]]]
endfunction

function Prueba_Auto takes nothing returns nothing
    local integer a
    local integer k
    local integer c
    local integer t
    local integer f
    if Game_Hero[0] == null or Game_Ctrl[0] == null or Game_Pair[0] == 0 then
        return
    endif
    set Prueba_A = Prueba_A + 1
    set a = Prueba_A
    if a == 1 then
        call SetUnitInvulnerable(Game_Hero[0], true)
        call Prueba_Log("inicio rafagas p " + I2S(Arm_Rafaga(0)) + "/" + I2S(Arm_Rafaga(1)) + "/" + I2S(Arm_Rafaga(2)) + " s " + I2S(Arm_Rafaga(6)) + "/" + I2S(Arm_Rafaga(11)) + " r " + I2S(Arm_Rafaga(12)) + "/" + I2S(Arm_Rafaga(17)) + " f " + I2S(Arm_Rafaga(18)) + "/" + I2S(Arm_Rafaga(23)) + " e " + I2S(Arm_Rafaga(24)) + "/" + I2S(Arm_Rafaga(29)) + " x " + I2S(Arm_Rafaga(36)) + "/" + I2S(Arm_Rafaga(41)) + " escala s " + R2SW(Arm_Escala(6), 1, 2) + "/" + R2SW(Arm_Escala(11), 1, 2) + " r " + R2SW(Arm_Escala(12), 1, 2) + " p " + R2SW(Arm_Escala(0), 1, 2))
    elseif a >= 4 and a < 4 + 180 then
        set k = (a - 4) / 5
        set f = ModuloInteger(a - 4, 5)
        set c = k / 6
        if c == 5 then
            set c = 6
        endif
        set t = ModuloInteger(k, 6) + 1
        if f == 0 then
            call Prueba_Blancos()
            call Prueba_Poner(c, t)
            set Prueba_B0 = Prueba_Tiros
            set Prueba_E0 = Prueba_EN
            set Prueba_B = s__RapidBolt_hits
            if c == 6 then
                call Prueba_Fuego(800.)
            else
                call Prueba_Fuego(600.)
            endif
            call Prueba_Log("fase captura-bala-c" + I2S(c) + "-t" + I2S(t) + Prueba_Modelo())
        elseif f == 1 and c == 6 then
            call Prueba_Log("fase captura-explosion-c6-t" + I2S(t))
        elseif f == 4 then
            set f = Arm_Cat[0] * 6 + Arm_Tier[Arm_Cat[0]] - 1
            call Prueba_Log("rafaga c" + I2S(c) + " t" + I2S(t) + " tiros " + I2S(Prueba_Tiros - Prueba_B0) + " esperado " + I2S(Arm_Rafaga(f)) + " int " + R2SW(Arm_Int[f], 1, 4) + " disp " + R2SW(Arm_Disp[f], 1, 1) + " vel " + R2SW(s__Missile_speed[s__RapidPair_lastMissile[Game_Pair[0]]] / Missile_TIMER_TIMEOUT, 1, 0) + " dano " + R2SW(Arm_Dano[f], 1, 0) + " perd " + I2S(Arm_Perd[f]) + " perfora " + I2S(Arm_Perfora[f]) + " impactos " + I2S(s__RapidBolt_hits - Prueba_B) + " vivos " + I2S(s__RapidBolt_live) + Prueba_Modelo() + Prueba_Danos())
            if c == 6 then
                call Prueba_Log("granada c6 t" + I2S(t) + " explosiones " + I2S(Prueba_EN - Prueba_E0) + " ultima " + R2SW(Prueba_EX - Prueba_PX, 1, 1) + " " + R2SW(Prueba_EY - Prueba_PY, 1, 1) + " del punto")
            endif
        endif
    elseif a == 186 then
        // Rifle: ráfaga sostenida relanzando cada 0,5 s; luego parar, y luego el dash.
        call Prueba_Blancos()
        call Prueba_Poner(2, 1)
        call Prueba_Fuego(600.)
    elseif a > 186 and a <= 192 then
        call Prueba_Fuego(600.)
        call Prueba_Log("rifle sostenido " + R2SW(Arm_Desvio[0], 1, 2))
    elseif a == 197 then
        call Prueba_Log("rifle parado " + R2SW(Arm_Desvio[0], 1, 2) + " disparando " + I2S(IntegerTertiaryOp(s__RapidPair_firing[Game_Pair[0]], 1, 0)))
        call Prueba_Fuego(600.)
    elseif a == 199 then
        call Prueba_Log("rifle antes del dash " + R2SW(Arm_Desvio[0], 1, 2))
        call s__RapidPair_dash(Game_Pair[0], GetUnitX(Game_Hero[0]), GetUnitY(Game_Hero[0]) + 300.)
        call Prueba_Log("rifle tras el dash " + R2SW(Arm_Desvio[0], 1, 2) + " disparando " + I2S(IntegerTertiaryOp(s__RapidPair_firing[Game_Pair[0]], 1, 0)))
    elseif a == 202 then
        call Prueba_Log("vivos rapidbolt " + I2S(s__RapidBolt_live) + " texttags libres sin tienda " + I2S(Prueba_Libres()))
        set Arm_Tier[0] = 4
        set Arm_Tier[4] = 6
        call Prueba_AbrirTienda(0, 5)
    elseif a == 204 then
        call Prueba_Log("fase captura-tienda-pistolas texttags libres " + I2S(Prueba_Libres()))
    elseif a == 207 then
        set Shop_Cat[0] = 4
        set Shop_Ver[0] = 6
        call Shop_Refrescar(0)
        call Prueba_Log("fase captura-tienda-escopetas")
    elseif a == 210 then
        set Shop_Cat[0] = 6
        set Shop_Ver[0] = 1
        call Shop_Refrescar(0)
        call Prueba_Log("fase captura-tienda-explosivos")
    elseif a == 213 then
        call Shop_Cerrar(0)
        call Prueba_Log("tienda cerrada texttags libres " + I2S(Prueba_Libres()))
        call Prueba_Log("COMPLETE")
        call PauseTimer(GetExpiredTimer())
        return
    endif
endfunction

function Intro_Begin takes nothing returns nothing
'''.replace('\n', '\n'))
inicio = 'Intro_Begin' if modo == 'intro' else 'Entrada_Directa'
extra = '\n    call TimerStart(CreateTimer(), 1., true, function Prueba_Tienda)' if modo == 'tienda' else ''
if modo == 'auto':
    extra = '\n    call TimerStart(CreateTimer(), 0.5, true, function Prueba_Auto)'
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
              'call Prueba_Iniciar()' + extra + '\n    call TimerStart(CreateTimer(), 0.1, false, function ' + inicio + ')')
if PINTADA:
    # Zonas de clic pintadas: los cuadros al 60 % y sin fondo para ver debajo los modelos de los trackables, que están en el suelo.
    s = base.once(s, '    if on then\n        set a = 255\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =',
                  '    if on then\n        set a = 150\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =')
    # Sin el fondo a pantalla completa (ShopPlano), que tapa el suelo donde están las zonas de clic.
    s = base.once(s, '            set path = "war3mapImported\\\\ShopPlano.mdx"\n', '            set path = ""\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
