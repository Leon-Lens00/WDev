#!/usr/bin/env python3
"""Puente de prueba LAN de v14h (04/11/2026). NO integrar.

Dos jugadores (J1 y J2), entrada directa, rondas 2 a 4, héroes que reciben daño pero se curan. Registro oculto por
cliente en lat\\j<jugador>-N.txt (Preload). Todo lo que hace la prueba sale de timers iguales en ambos clientes.
- Ronda, 3 s: cada héroe junto a una zona activa distinta, con las armas vacías. 4 s: los dos toman munición (como ESC).
  5 s: J2 va a la zona que usó J1 (para él sigue verde). 6 s: J2 la toma. Desde 8 s mata cada 2 s a los de la oleada.
- Descanso, 3 s: J1 junto a la tienda; 4 s la abre. 6 s: J2 junto a la tienda y la abre. 8 s: J1 la cierra con la de
  J2 abierta. 40 s: J1 la abre otra vez; al empezar la oleada deben estar las dos cerradas.
- Cada 2 s, chequeo: una suma del estado sincronizado (héroes, oro, tienda, zonas, armas) que debe coincidir en los dos
  clientes, y lo local de quien escribe (aviso, localizador, reloj de la tienda, modelo de su zona).
Termina a los 6 s de la ronda 5 con FIN.
Uso: puente_lan_v14h.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'integer Ronda_Numero = 1\n', 'integer Ronda_Numero = 2\n')
s = base.once(s, 'real Title_CX=', '''integer Lan_N= 0
integer Lan_T= 0
integer Lan_RT= 0
integer Lan_DT= 0
integer Lan_Est= - 1
integer Lan_Rondas= 0
integer array Lan_Z
boolean Lan_Fin= false
group Lan_G= CreateGroup()
real Title_CX=''')

s = base.once(s, '''    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''', '''    call Lan_Log("fuego id " + I2S(id) + " k " + I2S(k) + " r " + I2S(Ronda_Numero) + " jug " + I2S(DevWave_Jug) + " vida " + I2S(R2I(GetWidgetLife(u))) + "/" + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE))) + " t " + I2S(Lan_T))
    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''')
s = base.once(s, '\nfunction DevJefe_Limpiar takes nothing returns nothing\n', r'''
// TEMPORARY test bridge (scripts/puente_lan_v14h.py).
function Lan_Log takes string s returns nothing
    set Lan_N = Lan_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
endfunction

function Lan_B takes boolean b returns integer
    if b then
        return 1
    endif
    return 0
endfunction

function DevJefe_Limpiar takes nothing returns nothing
''')

s = base.once(s, 'function Shop_Construir takes nothing returns nothing\n', r'''function Lan_Curar takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 1
        if Game_Hero[p] != null and UnitAlive(Game_Hero[p]) then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
endfunction

function Lan_Poner takes integer p, real x, real y returns nothing
    call SetUnitX(Game_Hero[p], x)
    call SetUnitY(Game_Hero[p], y)
endfunction

function Lan_Vaciar takes integer p returns nothing
    local integer c = 0
    loop
        exitwhen c > 6
        if Arm_Tier[p * 7 + c] > 0 and c != 5 then
            set Arm_Clip[p * 7 + c] = 0
            set Arm_Rva[p * 7 + c] = 0
        endif
        set c = c + 1
    endloop
endfunction

function Lan_Armas takes integer p returns string
    local integer c = 0
    local string s = " J" + I2S(p + 1)
    loop
        exitwhen c > 6
        if Arm_Tier[p * 7 + c] > 0 and c != 5 then
            set s = s + " c" + I2S(c) + " " + I2S(Arm_Clip[p * 7 + c]) + "/" + I2S(Arm_Rva[p * 7 + c])
        endif
        set c = c + 1
    endloop
    return s
endfunction

function Lan_Tomar takes integer p returns nothing
    local integer z = Recarga_Cerca(p)
    if z >= 0 then
        call Recarga_Tomar(p, z)
    endif
    call Lan_Log("toma J" + I2S(p + 1) + " zona " + I2S(z) + Lan_Armas(p) + " t " + I2S(Lan_T))
endfunction

function Lan_Chequeo takes nothing returns nothing
    local integer p = 0
    local integer z = 0
    local integer t = DevTienda_Estado * 7 + DevTienda_Punto * 11 + R2I(GetUnitX(Shop_Golem) + GetUnitY(Shop_Golem) * 3) + Ronda_Resta * 13 + s__Wave_toKillRemaining[Ronda_Wave] * 17
    local integer zonas = 0
    local integer yo = GetPlayerId(GetLocalPlayer())
    local string m
    loop
        exitwhen p > 1
        set t = t + R2I(GetUnitX(Game_Hero[p]) * 5 + GetUnitY(Game_Hero[p]) * 7 + GetWidgetLife(Game_Hero[p])) + GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) * 19 + Lan_B(Shop_Open[p]) * 23 + Arm_Clip[p * 7] * 29 + Arm_Rva[p * 7] * 31
        set p = p + 1
    endloop
    loop
        exitwhen z > 19
        set zonas = zonas + Lan_B(Recarga_On[z]) * 37 * (z + 1) + Lan_B(Recarga_Usada[z]) * 41 * (z + 1) + Lan_B(Recarga_Usada[20 + z]) * 43 * (z + 1) + Lan_B(Recarga_Fx[z] != null) + Lan_B(Recarga_Fx[20 + z] != null)
        set z = z + 1
    endloop
    set m = "ninguna"
    if Lan_Z[yo] >= 0 and Recarga_On[Lan_Z[yo]] then
        if Recarga_Usada[yo * 20 + Lan_Z[yo]] then
            set m = "roja"
        else
            set m = "verde"
        endif
    endif
    call Lan_Log("chequeo " + I2S(Lan_T) + " suma " + I2S(t) + " zonas " + I2S(zonas) + " r " + I2S(Ronda_Numero) + " descanso " + I2S(Lan_B(Ronda_Descanso)) + " resta " + I2S(Ronda_Resta) + " tienda " + I2S(DevTienda_Estado) + " abiertas " + I2S(Lan_B(Shop_Open[0])) + "/" + I2S(Lan_B(Shop_Open[1])) + " | yo J" + I2S(yo + 1) + " aviso " + I2S(DevTienda_AvisoK[yo]) + " loc " + I2S(Lan_B(not IsUnitHidden(DevTienda_Icono[yo]))) + " reloj " + Shop_RelojVisto + " miZona " + m + " cifra " + Ronda_CifraVista[yo])
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
endfunction

function Lan_Tick takes nothing returns nothing
    local integer z
    local integer n
    if Lan_Fin or Ronda_Wave == 0 or Game_Hero[1] == null then
        return
    endif
    set Lan_T = Lan_T + 1
    if ModuloInteger(Lan_T, 2) == 0 then
        call Lan_Chequeo()
    endif
    if DevTienda_Estado != Lan_Est then
        set Lan_Est = DevTienda_Estado
        call Lan_Log("tienda est " + I2S(DevTienda_Estado) + " punto " + I2S(DevTienda_Punto) + " h " + I2S(R2I(GetUnitFlyHeight(Shop_Golem))) + " oculta " + I2S(Lan_B(IsUnitHidden(Shop_Golem))) + " t " + I2S(Lan_T))
    endif
    if not Ronda_Descanso then
        set Lan_DT = 0
        set Lan_RT = Lan_RT + 1
        if Lan_RT == 1 then
            set Lan_Rondas = Lan_Rondas + 1
            call Lan_Log("ronda " + I2S(Ronda_Numero) + " abiertas " + I2S(Lan_B(Shop_Open[0])) + "/" + I2S(Lan_B(Shop_Open[1])) + " t " + I2S(Lan_T))
        elseif Lan_RT == 3 then
            set n = 0
            set z = 0
            set Lan_Z[0] = - 1
            set Lan_Z[1] = - 1
            loop
                exitwhen z > 19
                if Recarga_On[z] then
                    if Lan_Z[0] < 0 then
                        set Lan_Z[0] = z
                    elseif Lan_Z[1] < 0 then
                        set Lan_Z[1] = z
                    endif
                    set n = n + 1
                endif
                set z = z + 1
            endloop
            call Lan_Log("zonas n " + I2S(n) + " J1 " + I2S(Lan_Z[0]) + " J2 " + I2S(Lan_Z[1]) + " t " + I2S(Lan_T))
            call Lan_Vaciar(0)
            call Lan_Vaciar(1)
            call Lan_Poner(0, Recarga_X[Lan_Z[0]] + 100., Recarga_Y[Lan_Z[0]])
            call Lan_Poner(1, Recarga_X[Lan_Z[1]] + 100., Recarga_Y[Lan_Z[1]])
        elseif Lan_RT == 4 then
            call Lan_Tomar(0)
            call Lan_Tomar(1)
        elseif Lan_RT == 5 then
            call Lan_Vaciar(1)
            set Lan_Z[1] = Lan_Z[0]
            call Lan_Poner(1, Recarga_X[Lan_Z[0]] - 100., Recarga_Y[Lan_Z[0]])
            call Lan_Log("J2 a la zona de J1 " + I2S(Lan_Z[0]) + " cercaJ1 " + I2S(Recarga_Cerca(0)) + " t " + I2S(Lan_T))
        elseif Lan_RT == 6 and Lan_Rondas >= 4 then
            set Lan_Fin = true
            call Lan_Chequeo()
            call Lan_Log("FIN t " + I2S(Lan_T))
        elseif Lan_RT == 6 then
            call Lan_Tomar(1)
        elseif Lan_RT >= 8 and ModuloInteger(Lan_RT, 2) == 0 then
            call Lan_Matar()
        endif
    else
        set Lan_RT = 0
        set Lan_DT = Lan_DT + 1
        if Lan_DT == 3 then
            call Lan_Poner(0, GetUnitX(Shop_Golem) + 180., GetUnitY(Shop_Golem))
        elseif Lan_DT == 4 then
            call Shop_Abrir(0)
            call Lan_Log("abre J1 " + I2S(Lan_B(Shop_Open[0])) + " t " + I2S(Lan_T))
        elseif Lan_DT == 6 then
            call Lan_Poner(1, GetUnitX(Shop_Golem) - 180., GetUnitY(Shop_Golem))
            call Shop_Abrir(1)
            call Lan_Log("abre J2 " + I2S(Lan_B(Shop_Open[1])) + " t " + I2S(Lan_T))
        elseif Lan_DT == 8 then
            call Shop_Cerrar(0)
            call Lan_Log("cierra J1 abiertas " + I2S(Lan_B(Shop_Open[0])) + "/" + I2S(Lan_B(Shop_Open[1])) + " t " + I2S(Lan_T))
        elseif Lan_DT == 39 then
            call Lan_Poner(0, GetUnitX(Shop_Golem) + 180., GetUnitY(Shop_Golem))
        elseif Lan_DT == 40 then
            call Shop_Abrir(0)
            call Lan_Log("abre J1 otra vez " + I2S(Lan_B(Shop_Open[0])) + " resta " + I2S(Ronda_Resta) + " t " + I2S(Lan_T))
        endif
    endif
endfunction

function Lan_Iniciar takes nothing returns nothing
    set Lan_Z[0] = - 1
    set Lan_Z[1] = - 1
    call TimerStart(CreateTimer(), 1., true, function Lan_Tick)
    call TimerStart(CreateTimer(), 0.03, true, function Lan_Curar)
endfunction

function Shop_Construir takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Lan_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
