#!/usr/bin/env python3
"""Puente de prueba LAN de v14i (04/11/2026). NO integrar.

Dos jugadores (J1 y J2), entrada directa, rondas 2 y 3, descanso de 6 s, héroes que reciben daño pero se curan.
Registro oculto por cliente en lat\\j<jugador>-N.txt (Preload). Todo sale de timers iguales en los dos clientes.
- Al empezar cada ronda, J1 y J2 se colocan lejos uno del otro (zonas de munición 0 y 10).
- Mata cada segundo hasta 3 unidades normales, las élites a los 9 s de aparecer y al jefe a los 20 s.
- Cada élite: al aparecer, a los 5 s y a los 8 s, a qué jugador sigue y su distancia a cada héroe.
- Ronda 3: cuando una élite que sigue a J2 cumple 3 s, J2 queda fuera de la partida (Vidas_Retirar, como sin vidas):
  su élite debe pasar a J1 y los eventos siguientes traer una sola élite.
- Cada 2 s, una línea del estado sincronizado (vivas, bots, pendientes, muertes, élites y sus objetivos, héroes) que
  debe ser igual en los dos clientes.
Termina al empezar la ronda 4 con FIN.
Uso: puente_lan_v14i.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'integer Ronda_Numero = 1\n', 'integer Ronda_Numero = 2\n')
s = base.once(s, '    set Ronda_Resta = Ronda_DESCANSO\n', '    set Ronda_Resta = 6\n')
s = base.once(s, 'real Title_CX=', '''integer Lan_N= 0
integer Lan_T= 0
integer Lan_RT= 0
integer Lan_Rondas= 0
integer Lan_NE= 0
unit array Lan_E
integer array Lan_EA
boolean Lan_Retirado= false
boolean Lan_Fin= false
group Lan_G= CreateGroup()
real Title_CX=''')

s = base.once(s, '        // v14i: punto dentro del mapa jugable y caminable.\n', r'''        // TEMPORARY test bridge (scripts/puente_lan_v14i.py).
        function Lan_Log takes string s returns nothing
            set Lan_N=Lan_N + 1
            call PreloadGenClear()
            call Preload(s)
            call PreloadGenEnd("lat\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
        endfunction
        // v14i: punto dentro del mapa jugable y caminable.
''')
s = base.once(s, '''    function DevWave_Elite takes integer k returns nothing
        local integer p= 0
        local integer c= 0
''', '''    function DevWave_Elite takes integer k returns nothing
        local integer p= 0
        local integer c= 0
        call Lan_Log("evento elite k " + I2S(k) + " muertos " + I2S(DevWave_Muertos) + "/" + I2S(DevWave_Total) + " t " + I2S(Lan_T))
''')
s = base.once(s, '''    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''', '''    if id >= 'ne00' and id <= 'ne09' then
        set Lan_E[Lan_NE] = u
        set Lan_EA[Lan_NE] = 0
        set Lan_NE = Lan_NE + 1
    endif
    call Lan_Log("fuego id " + I2S(id) + " r " + I2S(Ronda_Numero) + " jug " + I2S(DevWave_Jug) + " sigue " + I2S(p) + " vida " + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE))) + " t " + I2S(Lan_T))
    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''')

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

function Lan_D takes unit a, unit b returns integer
    return R2I(SquareRoot(Pow(GetUnitX(a) - GetUnitX(b), 2) + Pow(GetUnitY(a) - GetUnitY(b), 2)))
endfunction

function Lan_Sigue takes unit u returns integer
    if HaveSavedInteger(DevWave_HT, GetHandleId(u), 1) then
        return LoadInteger(DevWave_HT, GetHandleId(u), 1)
    endif
    return - 1
endfunction

function Lan_Tick takes nothing returns nothing
    local integer o
    local integer i
    local integer n = 0
    local integer id
    local unit u
    local string q
    local integer w = Ronda_Wave
    set Lan_T = Lan_T + 1
    if Lan_Fin or w == 0 then
        return
    endif
    if Ronda_Descanso or s__Wave_isDestroyed[w] then
        set Lan_RT = 0
        return
    endif
    set Lan_RT = Lan_RT + 1
    if Lan_RT == 1 then
        set Lan_Rondas = Lan_Rondas + 1
        if Lan_Rondas >= 3 then
            set Lan_Fin = true
            call Lan_Log("FIN t " + I2S(Lan_T))
            return
        endif
        call SetUnitX(Game_Hero[0], Recarga_X[0])
        call SetUnitY(Game_Hero[0], Recarga_Y[0])
        call SetUnitX(Game_Hero[1], Recarga_X[10])
        call SetUnitY(Game_Hero[1], Recarga_Y[10])
        call Lan_Log("ronda " + I2S(Ronda_Numero) + " jug " + I2S(DevWave_Jug) + " total " + I2S(DevWave_Total) + " lim " + I2S(DevWave_Limite) + " separados " + I2S(Lan_D(Game_Hero[0], Game_Hero[1])) + " t " + I2S(Lan_T))
    endif
    // Élites: edad, seguimiento y muerte a los 9 s; en la ronda 3, J2 sale cuando una élite suya cumple 3 s.
    set i = 0
    loop
        exitwhen i >= Lan_NE
        set u = Lan_E[i]
        if u != null and GetWidgetLife(u) > 0.405 then
            set Lan_EA[i] = Lan_EA[i] + 1
            if Lan_EA[i] == 3 and Ronda_Numero == 3 and not Lan_Retirado and Lan_Sigue(u) == 1 then
                set Lan_Retirado = true
                call Vidas_Retirar(1)
                call Lan_Log("J2 retirado enPartida " + I2S(IntegerTertiaryOp(Vidas_EnPartida[1], 1, 0)) + " t " + I2S(Lan_T))
            endif
            if Lan_EA[i] == 5 or Lan_EA[i] == 8 then
                call Lan_Log("elite " + I2S(i) + " id " + I2S(GetUnitTypeId(u)) + " edad " + I2S(Lan_EA[i]) + " sigue " + I2S(Lan_Sigue(u)) + " dJ1 " + I2S(Lan_D(u, Game_Hero[0])) + " dJ2 " + I2S(Lan_D(u, Game_Hero[1])) + " t " + I2S(Lan_T))
            endif
            if Lan_EA[i] >= 9 then
                call KillUnit(u)
            endif
        endif
        set i = i + 1
    endloop
    if ModuloInteger(Lan_T, 2) == 0 then
        set q = "chequeo r " + I2S(Ronda_Numero) + " mapa " + I2S(s__Wave_activeOnMap[w]) + "/" + I2S(DevWave_Limite) + " bots"
        set o = WAVE_DEFAULT_OWNER_MIN
        loop
            exitwhen o > WAVE_DEFAULT_OWNER_MAX
            set q = q + " " + I2S(s___Wave_activeByPlayer[s__Wave_activeByPlayer[w] + o])
            set o = o + 1
        endloop
        set q = q + " pend " + I2S(s__Wave_remainingToSpawn[w]) + " muertos " + I2S(DevWave_Muertos) + " sig " + I2S(DevWave_EliteSig) + " cerca " + I2S(DevWave_Cerca) + " elites"
        set i = 0
        loop
            exitwhen i >= Lan_NE
            if Lan_E[i] != null and GetWidgetLife(Lan_E[i]) > 0.405 then
                set q = q + " " + I2S(i) + ">" + I2S(Lan_Sigue(Lan_E[i]))
            endif
            set i = i + 1
        endloop
        call Lan_Log(q + " h1 " + I2S(R2I(GetUnitX(Game_Hero[0]))) + "," + I2S(R2I(GetUnitY(Game_Hero[0]))) + " h2 " + I2S(R2I(GetUnitX(Game_Hero[1]))) + "," + I2S(R2I(GetUnitY(Game_Hero[1]))) + " t " + I2S(Lan_T))
    endif
    set o = WAVE_DEFAULT_OWNER_MIN
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Lan_G, Player(o), null)
        loop
            set u = FirstOfGroup(Lan_G)
            exitwhen u == null
            call GroupRemoveUnit(Lan_G, u)
            set id = GetUnitTypeId(u)
            if GetWidgetLife(u) > 0.405 and HaveSavedInteger(DevWave_HT, GetHandleId(u), 0) and not ( id >= 'ne00' and id <= 'ne09' ) then
                if u == DevJefe then
                    if Lan_RT >= 20 and DevJefe_Llamadas > 0 then
                        call KillUnit(u)
                    endif
                elseif n < 3 then
                    set n = n + 1
                    call KillUnit(u)
                endif
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction

function Lan_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Lan_Tick)
    call TimerStart(CreateTimer(), 0.03, true, function Lan_Curar)
endfunction

function Shop_Construir takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Lan_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
