#!/usr/bin/env python3
"""Sólo prueba, v14k: entrada directa; en el primer descanso abre la tienda y recorre retratos, voces y "Abastecer todo"
llamando a las funciones de la tienda desde un temporizador (código sincronizado, sin clics). NO integrar.
Cada paso deja una línea en lat\\vista-N.txt con el oro y, por categoría, nivel, reserva/máximo y lo que falta.
Uso: vista_v14k.py ENTRADA.j SALIDA.j [diag]  (diag: registra los retratos y saca el Tauren al centro a los 4 s)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
PINTADA = True
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'real Title_CX=', 'integer Vista_N= 0\ninteger Vista_T= 0\ninteger Vista_A= 0\nboolean Vista_Diag= false\ngroup Vista_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Oro_Muerte takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/vista_v14k.py).
function Vista_Log takes string s returns nothing
    set Vista_N = Vista_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\vista-" + I2S(Vista_N) + ".txt")
endfunction

function Vista_Estado takes string q returns nothing
    local integer c = 0
    local integer i
    local integer x
    local string s = q + " t " + I2S(Vista_T) + " oro " + I2S(GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)) + " todo " + I2S(Shop_TodoCosto(0))
    loop
        exitwhen c > 6
        set i = c
        if Arm_Tier[i] > 0 and c != 5 then
            set x = c * 3 + Arm_Tier[i] - 1
            set s = s + " | c" + I2S(c) + " T" + I2S(Arm_Tier[i]) + " " + I2S(Arm_Rva[i]) + "/" + I2S(Arm_Res[x]) + " u" + I2S((Arm_Precio[x] + 100) / 4)
        endif
        set c = c + 1
    endloop
    call Vista_Log(s + " habla " + I2S(Hero_Choice[0]))
endfunction

function Vista_Vaciar takes integer lleno0 returns nothing
    local integer c = 0
    loop
        exitwhen c > 6
        if Arm_Tier[c] > 0 and c != 5 then
            set Arm_Rva[c] = 0
        endif
        set c = c + 1
    endloop
    if lleno0 > 0 then
        set Arm_Rva[0] = Arm_Res[Arm_Tier[0] - 1] - lleno0
    endif
endfunction

function Vista_Tick takes nothing returns nothing
    local integer o
    local unit u
    set Vista_T = Vista_T + 1
    if Game_Hero[0] != null then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
    // Ronda: mata a los de la oleada; descanso con la tienda abajo: héroe al lado, abre (como ESC) 12 s y cierra.
    if Ronda_Activa and not Ronda_Descanso then
        set o = WAVE_DEFAULT_OWNER_MIN
        loop
            exitwhen o > WAVE_DEFAULT_OWNER_MAX
            call GroupEnumUnitsOfPlayer(Vista_G, Player(o), null)
            loop
                set u = FirstOfGroup(Vista_G)
                exitwhen u == null
                call GroupRemoveUnit(Vista_G, u)
                if GetWidgetLife(u) > 0.405 then
                    call KillUnit(u)
                endif
            endloop
            set o = o + 1
        endloop
    elseif Ronda_Descanso and DevTienda_Estado == 2 and Vista_A == 0 then
        call SetUnitPosition(Game_Hero[0], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem))
        set Vista_A = Vista_T
    elseif Vista_A > 0 and Vista_T == Vista_A + 2 then
        call Shop_Abrir(0)
        call Vista_Estado("abierta")
    elseif Vista_A > 0 and Vista_T == Vista_A + 4 and Vista_Diag then
        set o = 0
        loop
            exitwhen o > 2
            call Vista_Log("retrato " + I2S(o) + " tipo " + I2S(GetUnitTypeId(Shop_Retrato[o])) + " x " + R2S(GetUnitX(Shop_Retrato[o])) + " y " + R2S(GetUnitY(Shop_Retrato[o])) + " vuelo " + R2S(GetUnitFlyHeight(Shop_Retrato[o])) + " suelo " + R2S(UserInterface_GetTerrainZ(GetUnitX(Shop_Retrato[o]), GetUnitY(Shop_Retrato[o]))) + " oculto " + I2S(IntegerTertiaryOp(IsUnitHidden(Shop_Retrato[o]), 1, 0)) + " vida " + R2S(GetWidgetLife(Shop_Retrato[o])) + " ojo " + R2S(Shop_OJO))
            set o = o + 1
        endloop
        // El Tauren al centro de la pantalla, por delante de todos los cuadros (profundidad 300).
        call SetUnitX(Shop_Retrato[1], Title_WX(Shop_PY(442), 300))
        call SetUnitY(Shop_Retrato[1], Title_WY(960, 300))
        call SetUnitFlyHeight(Shop_Retrato[1], Shop_OJO - 300 - UserInterface_GetTerrainZ(GetUnitX(Shop_Retrato[1]), GetUnitY(Shop_Retrato[1])), 0)
        call SetUnitScale(Shop_Retrato[1], 4., 4., 4.)
        call Vista_Log("tauren al centro vuelo " + R2S(GetUnitFlyHeight(Shop_Retrato[1])))
    elseif Vista_A > 0 and Vista_T == Vista_A + 9 then
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 5000)
        set Shop_Cat[0] = 1
        set Shop_Ver[0] = 1
        call Shop_Comprar(0)
        call Vista_Estado("compra Tauren subfusil")
    elseif Vista_A > 0 and Vista_T == Vista_A + 14 then
        set Hero_Choice[0] = 1
        set Shop_Cat[0] = 2
        set Shop_Ver[0] = 1
        call Shop_Comprar(0)
        call Vista_Estado("compra Cairne rifle")
    elseif Vista_A > 0 and Vista_T == Vista_A + 19 then
        set Hero_Choice[0] = 0
        set Shop_Cat[0] = 0
        set Shop_Ver[0] = 1
        call Shop_Refrescar(0)
        call Vista_Vaciar(0)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 10)
        call Shop_Refrescar(0)
        call Vista_Estado("antes 10")
        call Shop_Todo(0)
        call Vista_Estado("despues 10")
    elseif Vista_A > 0 and Vista_T == Vista_A + 23 then
        call Vista_Vaciar(0)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 100)
        call Vista_Estado("antes 100")
        call Shop_Todo(0)
        call Vista_Estado("despues 100")
        call Vista_Vaciar(1)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 60)
        call Vista_Estado("antes 60 pistola casi llena")
        call Shop_Todo(0)
        call Vista_Estado("despues 60 pistola casi llena")
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 0)
        call Vista_Estado("antes 0")
        call Shop_Todo(0)
        call Vista_Estado("despues 0")
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 1)
        call Shop_Refrescar(0)
    elseif Vista_A > 0 and Vista_T == Vista_A + 27 then
        call Vista_Vaciar(0)
        call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 99999)
        call Vista_Estado("antes todo")
        call Shop_Todo(0)
        call Vista_Estado("despues todo")
    elseif Vista_A > 0 and Vista_T == Vista_A + 31 then
        call Shop_Cerrar(0)
        call Vista_Estado("cerrada")
    elseif Vista_A > 0 and Vista_T == Vista_A + 35 then
        call Vista_Log("FIN t " + I2S(Vista_T))
    endif
    set u = null
endfunction

function Vista_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Vista_Tick)
endfunction

function Oro_Muerte takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Vista_Iniciar")\n')
if sys.argv[3:] == ['diag']:
    s = base.once(s, 'boolean Vista_Diag= false', 'boolean Vista_Diag= true')
if PINTADA:
    # Zonas de clic pintadas: los cuadros al 60 % y sin fondo para ver debajo los modelos de los trackables, que están en el suelo.
    s = base.once(s, '    if on then\n        set a = 255\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =',
                  '    if on then\n        set a = 150\n    endif\n    if GetLocalPlayer() == Player(p) then\n        if on then\n            set path =')
    # Sin el fondo a pantalla completa (ShopPlano), que tapa el suelo donde están las zonas de clic.
    s = base.once(s, '            set path = "war3mapImported\\\\ShopPlano.mdx"\n', '            set path = ""\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
