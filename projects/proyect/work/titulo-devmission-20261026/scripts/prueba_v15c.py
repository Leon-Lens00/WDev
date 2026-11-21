#!/usr/bin/env python3
"""Sólo prueba, v15c (a partir de prueba_v15a.py). MODO intro arranca con la intro y el título; MODO directa entra directo a
la partida (Entrada_Directa): son las de Leon. MODO auto entra directo y dispara solo, para evaluar por registro la
tienda nueva (vistas, compras, precios) y las balas de los 7 tiers (no se entrega).
En intro y directa, comandos de chat: "-oro N" pone N de oro, "-sob N" pone la sobrecarga a N, "-kits N" da N kits y "-tier N"
pone el modelo N (1..7) del arma activa, para ver el color de su bala.

Registro oculto (Preload, un archivo por línea en lat\\v15c-N.txt): en intro y directa cada 2 s y hasta 900 líneas (tiempo,
tienda, ronda, descanso, oro, arma, sobrecarga, bloqueo, kits, nivel y refresco en curso); en auto cada 0,5 s y por
cada fase, con los tiros emitidos.
Uso: prueba_v15c.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa', 'auto')
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Prueba_N= 0\ninteger Prueba_T= 0\ninteger Prueba_A= 0\ninteger Prueba_E= 0\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_v15c.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v15c-" + I2S(Prueba_N) + ".txt")
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
    elseif SubString(m, 0, 6) == "-tier " then
        // Modelo N del arma activa, con sus mejoras a 0.
        set Arm_Tier[p * 7 + Arm_Cat[p]] = IMaxBJ(1, IMinBJ(7, S2I(SubString(m, 6, StringLength(m)))))
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6] = 0
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6 + 1] = 0
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6 + 2] = 0
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6 + 3] = 0
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6 + 4] = 0
        set Mej_N[(p * 4 + Arm_Cat[p]) * 6 + 5] = 0
        call Arm_Recalc(p, Arm_Cat[p])
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

// MODO auto: un paso cada 0,5 s (Prueba_A). La tienda se abre sin descanso ni golem (Prueba_Abrir) y se compra
// llamando a las funciones de los clics; las fases "captura" son para las capturas de pantalla.
function Prueba_Fuego takes nothing returns nothing
    local string antes = OrderId2String(GetUnitCurrentOrder(Game_Ctrl[0]))
    local boolean b = IssuePointOrder(Game_Ctrl[0], "carrionswarm", GetUnitX(Game_Hero[0]) + 600., GetUnitY(Game_Hero[0]))
    local unit u = Game_Ctrl[0]
    local integer r = Game_Pair[0]
    local string s = ""
    if not b then
        // Estado del controlador al rechazar la orden (informe de errores, punto 4).
        set s = " mana " + R2SW(GetUnitState(u, UNIT_STATE_MANA), 1, 1) + " vida " + R2SW(GetWidgetLife(u), 1, 1) + " pausa " + I2S(IntegerTertiaryOp(IsUnitPaused(u), 1, 0))
        set s = s + " niv " + I2S(GetUnitAbilityLevel(u, 'Arpf')) + "/" + I2S(GetUnitAbilityLevel(u, 'Arp1')) + "/" + I2S(GetUnitAbilityLevel(u, 'Arp3'))
        set s = s + " oculta " + I2S(IntegerTertiaryOp(IsUnitHidden(u), 1, 0)) + " aturd " + I2S(IntegerTertiaryOp(IsUnitType(u, UNIT_TYPE_STUNNED), 1, 0))
        if r != 0 then
            set s = s + " down " + I2S(IntegerTertiaryOp(s__RapidPair_down[r], 1, 0)) + " firing " + I2S(IntegerTertiaryOp(s__RapidPair_firing[r], 1, 0))
        endif
        set s = s + " dist " + R2SW(SquareRoot(Pow(GetUnitX(u) - GetUnitX(Game_Hero[0]), 2) + Pow(GetUnitY(u) - GetUnitY(Game_Hero[0]), 2)), 1, 1) + " t " + R2SW(TimerGetElapsed(s__RapidPair_clock), 1, 2)
    endif
    call Prueba_Log("orden fuego " + I2S(IntegerTertiaryOp(b, 1, 0)) + " antes " + antes + " despues " + OrderId2String(GetUnitCurrentOrder(Game_Ctrl[0])) + s)
    set u = null
endfunction

function Prueba_Stats takes integer c returns string
    local integer w = 100 + c
    local string s = " " + Arm_Nombre[w] + " T" + I2S(Arm_Tier[c]) + " dano " + R2SW(Arm_Dano[w], 1, 2) + " int " + R2SW(Arm_Int[w], 1, 4)
    set s = s + " vel " + R2SW(Arm_Vel[w], 1, 1) + " alc " + R2SW(Arm_Alc[w], 1, 1) + " disp " + R2SW(Arm_Disp[w], 1, 2)
    return s + " perd " + I2S(Arm_Perd[w]) + " perfora " + I2S(Arm_Perfora[w]) + " calor " + R2SW(Arm_Calor[w], 1, 3)
endfunction

// Unidades ajenas a las piezas cerca de la tienda (una figura verde aparece dentro del panel central).
function Prueba_Cerca takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local string s = "cerca"
    call GroupEnumUnitsInRange(g, GetUnitX(Menu_Ancla[1]), GetUnitY(Menu_Ancla[1]), 1500., null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if GetUnitTypeId(u) != 'uids' and GetUnitTypeId(u) != 'dumi' then
            set s = s + " " + GetUnitName(u) + "@" + I2S(R2I(GetUnitX(u) - GetUnitX(Menu_Ancla[1]))) + "," + I2S(R2I(GetUnitY(u) - GetUnitY(Menu_Ancla[1]))) + "/p" + I2S(GetPlayerId(GetOwningPlayer(u)))
        endif
    endloop
    call Prueba_Log(s)
    call DestroyGroup(g)
    set g = null
endfunction

function Prueba_Tienda takes string f returns nothing
    local integer c = Shop_Cat[0]
    call Prueba_Log("fase " + f + " abierta " + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)) + " vista " + I2S(Shop_Vista[0]) + " ver " + I2S(Shop_Ver[0]) + " sel " + I2S(Shop_Sel[0]) + " cat " + I2S(c) + " oro " + I2S(GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)) + " hechas " + I2S(Mej_Hechas(0, c, Shop_Ver[0])) + "/" + I2S(Mej_Total(Shop_Ver[0])) + " estado " + I2S(Mej_Estado(0, c, Shop_Ver[0])) + " textos " + I2S(Shop_TzN) + " piezas " + I2S(Mej_PzN) + " fijas " + I2S(Shop_PzN) + Prueba_Stats(c))
endfunction

function Prueba_Abrir takes nothing returns nothing
    local integer p = 0
    if Game_Pair[p] != 0 then
        call s__RapidPair_finish(Game_Pair[p], false)
    endif
    set Shop_Open[p] = true
    set Shop_Abiertos = Shop_Abiertos + 1
    set Shop_Cat[p] = Arm_Cat[p]
    set Shop_Ver[p] = Arm_Tier[p * 7 + Arm_Cat[p]] - 1
    set Shop_Vista[p] = 0
    set Shop_Sel[p] = - 1
    if GetLocalPlayer() == Player(p) then
        call ResetToGameCamera(0)
        call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    endif
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
    call Mej_Decir(p, Mej_Frase[Shop_Cat[p]])
endfunction

function Prueba_Cat takes integer c returns nothing
    set Shop_Cat[0] = c
    set Shop_Vista[0] = 0
    set Shop_Ver[0] = Arm_Tier[c] - 1
    set Shop_Sel[0] = - 1
    call Shop_Refrescar(0)
endfunction

// Compra todos los niveles del modelo actual (un clic de Comprar por nivel) y luego el modelo siguiente.
function Prueba_Completar takes nothing returns nothing
    local integer c = Shop_Cat[0]
    local integer m = Arm_Tier[c] - 1
    local integer j = 0
    local integer k
    local integer oro = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
    set Shop_Ver[0] = m
    set Shop_Vista[0] = 1
    loop
        exitwhen j >= Mej_Cuantas(m)
        set Shop_Sel[0] = j
        set k = 0
        loop
            exitwhen k > m
            call Mej_Comprar(0)
            set k = k + 1
        endloop
        // Un clic de más: debe rechazarse (al máximo).
        call Mej_Comprar(0)
        set j = j + 1
    endloop
    call Prueba_Log("completo c" + I2S(c) + " m" + I2S(m) + " hechas " + I2S(Mej_Hechas(0, c, m)) + "/" + I2S(Mej_Total(m)) + " gastado " + I2S(oro - GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Stats(c))
    set oro = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
    set Shop_Sel[0] = - 1
    call Mej_Comprar(0)
    call Prueba_Log("modelo c" + I2S(c) + " T" + I2S(Arm_Tier[c]) + " gastado " + I2S(oro - GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Stats(c))
endfunction

function Prueba_Nivel takes integer j, integer n returns nothing
    local integer k = 0
    set Shop_Sel[0] = j
    loop
        exitwhen k >= n
        call Mej_Comprar(0)
        set k = k + 1
    endloop
endfunction

function Prueba_Bala takes integer c, integer t returns nothing
    set Arm_Tier[c] = t
    call Arm_Recalc(0, c)
    call Arm_Elegir(0, c)
    set Sob_Valor[0] = 0.
    call Prueba_Fuego()
    call Prueba_Log("fase captura-bala-c" + I2S(c) + "-t" + I2S(t) + " velocidad " + R2SW(Arm_Velocidad, 1, 1) + Prueba_Stats(c))
endfunction

function Prueba_Auto takes nothing returns nothing
    local integer a
    local integer k
    if Game_Hero[0] == null or Game_Ctrl[0] == null then
        return
    endif
    set Prueba_A = Prueba_A + 1
    set a = Prueba_A
    if a == 1 then
        call SetUnitInvulnerable(Game_Hero[0], true)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 100000)
        call Prueba_Log("inicio" + Prueba_Stats(0) + " |" + Prueba_Stats(1) + " |" + Prueba_Stats(2) + " |" + Prueba_Stats(3))
    elseif a == 4 then
        call Prueba_Abrir()
        call Prueba_Tienda("captura-modelos-t1")
        call Prueba_Cerca()
    elseif a == 8 then
        // Segundo clic en el modelo propio: abre el árbol; un nodo elegido.
        call Mej_Ranura(0, 0)
        call Mej_Nodo(0, 1)
        call Prueba_Tienda("captura-arbol-t1")
    elseif a == 12 then
        // Cada compra refresca la tienda: un hilo nuevo por modelo para no pasar el límite de operaciones.
        call ExecuteFunc("Prueba_Completar")
        call ExecuteFunc("Prueba_Completar")
        call ExecuteFunc("Prueba_Completar")
        // Modelo 4 a medias: daño 2, sobrecarga 1, cadencia 3; elegida la cadencia.
        call Prueba_Nivel(0, 2)
        call Prueba_Nivel(1, 1)
        call Prueba_Nivel(4, 3)
        call Shop_Refrescar(0)
        call Prueba_Tienda("captura-arbol-t4")
    elseif a == 16 then
        call Prueba_Nivel(2, 4)
        call Prueba_Nivel(3, 4)
        call Prueba_Nivel(5, 4)
        call Prueba_Nivel(0, 2)
        call Prueba_Nivel(1, 3)
        call Prueba_Nivel(4, 1)
        set Shop_Vista[0] = 0
        set Shop_Sel[0] = - 1
        call Shop_Refrescar(0)
        call Prueba_Tienda("captura-modelos-t4-completo")
    elseif a == 20 then
        call Mej_Ranura(0, 6)
        call Prueba_Tienda("captura-bloqueado")
    elseif a == 24 then
        call Prueba_Cat(2)
        call ExecuteFunc("Prueba_Completar")
        call Mej_Nodo(0, 3)
        call Prueba_Tienda("captura-escopeta-t2")
    elseif a == 28 then
        call Prueba_Cat(3)
        call ExecuteFunc("Prueba_Completar")
        call ExecuteFunc("Prueba_Completar")
        call Mej_Nodo(0, 3)
        call Prueba_Tienda("captura-franco-t3")
    elseif a == 32 then
        // Precios: sobrecarga 150 y kit.
        set k = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
        call Shop_Sobrecarga(0)
        call Shop_Sobrecarga(0)
        call Prueba_Log("sobrecarga nivel " + I2S(Sob_Nivel[0]) + " gastado " + I2S(k - GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)))
        call Shop_Cerrar(0)
        call Prueba_Tienda("cerrada")
    elseif a >= 36 and a < 36 + 84 then
        if ModuloInteger(a - 36, 3) == 0 then
            set k = (a - 36) / 3
            call Prueba_Bala(k / 7, ModuloInteger(k, 7) + 1)
        endif
    elseif a == 36 + 84 then
        call Prueba_Log("velocidad final " + R2SW(Arm_Velocidad, 1, 1))
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
