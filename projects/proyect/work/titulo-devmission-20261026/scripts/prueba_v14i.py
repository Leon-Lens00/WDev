#!/usr/bin/env python3
"""Sólo prueba, v14i: entrada directa, héroe que se cura cada 0,03 s, empieza en la ronda RONDA (5 por defecto) con
los jugadores reales y desde la ronda RJ (6) cuenta como 8 jugadores para llegar al límite de 240 y 40 por bot.
Descanso de 6 s. Termina al empezar la tercera ronda con FIN.

Mata cada segundo hasta 3 unidades normales (con 8 jugadores ninguna los primeros 30 s y luego 30), las élites cada 3 s y al jefe 25 s después de
aparecer, para ver sus refuerzos.

Registro oculto (Preload, un archivo por línea en lat\\v14i-N.txt):
- cada segundo: vivas en el mapa y límite, vivas por bot 8..13, pendientes, por matar, muertes normales / total,
  siguiente evento de élite y apariciones cercanas;
- cada evento de élites, cada élite y jefe al aparecer (jugador fijo, vida y la esperada), cada refuerzo;
- cada aparición cercana con su distancia al héroe;
- al terminar la ronda: duración, máximos de vivas por bot y en el mapa, y el reparto de efectos de aparición.

Uso: prueba_v14i.py ENTRADA.j SALIDA.j [RONDA] [RJ]
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ronda = sys.argv[3] if len(sys.argv) > 3 else '5'
rj = sys.argv[4] if len(sys.argv) > 4 else '6'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'integer Ronda_Numero = 1\n', f'integer Ronda_Numero = {ronda}\n')
s = base.once(s, '    set Ronda_Resta = Ronda_DESCANSO\n', '    set Ronda_Resta = 6\n')
s = base.once(s, '        set DevWave_Jug=IMaxBJ(1, WaveCountPlayingUsers())\n', f'''        set DevWave_Jug=IMaxBJ(1, WaveCountPlayingUsers())
        if Ronda_Numero >= {rj} then
            set DevWave_Jug=8
        endif
''')
s = base.once(s, 'real Title_CX=', '''integer Prueba_N= 0
real Prueba_T= 0.
integer Prueba_RT= 0
integer Prueba_Rondas= 0
integer Prueba_JefeT= 0
integer Prueba_MaxBot= 0
integer Prueba_MaxMapa= 0
real Prueba_Ini= 0.
integer array Prueba_Fx
boolean Prueba_Fin= false
group Prueba_G= CreateGroup()
real Title_CX=''')

s = base.once(s, '        // v14i: punto dentro del mapa jugable y caminable.\n', r'''        // TEMPORARY test bridge (scripts/prueba_v14i.py).
        function Prueba_Log takes string s returns nothing
            set Prueba_N=Prueba_N + 1
            call PreloadGenClear()
            call Preload(s)
            call PreloadGenEnd("lat\\v14i-" + I2S(Prueba_N) + ".txt")
        endfunction
        // v14i: punto dentro del mapa jugable y caminable.
''')
s = base.once(s, '                        set DevWave_Cerca=DevWave_Cerca + 1\n', '''                        set DevWave_Cerca=DevWave_Cerca + 1
                        call Prueba_Log("cerca d=" + I2S(R2I(dist)) + " xy=" + I2S(R2I(x)) + "," + I2S(R2I(y)) + " t=" + R2S(Prueba_T))
''')
s = base.once(s, '            set DevWave_PsFx[DevWave_UltPs]=fx\n', '            set DevWave_PsFx[DevWave_UltPs]=fx\n            set Prueba_Fx[fx]=Prueba_Fx[fx] + 1\n')
s = base.once(s, '''    function DevWave_Elite takes integer k returns nothing
        local integer p= 0
        local integer c= 0
''', '''    function DevWave_Elite takes integer k returns nothing
        local integer p= 0
        local integer c= 0
        call Prueba_Log("evento elite k=" + I2S(k) + " muertos=" + I2S(DevWave_Muertos) + "/" + I2S(DevWave_Total) + " E=" + I2S(DevWave_EliteE) + " t=" + R2S(Prueba_T))
''')
s = base.once(s, '        call WaveUpsertSlotExByPlayer(Ronda_Wave , 800 + k , DevWave_Tipo[k] , e , false , 9999 , 1 , 1 , - 1 , false , d , DevWave_Perfil[k] , 0 , 0 , 1.)\n', '''        call WaveUpsertSlotExByPlayer(Ronda_Wave , 800 + k , DevWave_Tipo[k] , e , false , 9999 , 1 , 1 , - 1 , false , d , DevWave_Perfil[k] , 0 , 0 , 1.)
        call Prueba_Log("refuerzo llamada=" + I2S(DevJefe_Llamadas) + " k=" + I2S(k) + " id=" + I2S(DevWave_Tipo[k]) + " cantidad=" + I2S(e) + " refuerzo=" + I2S(DevWave_Refuerzo) + " t=" + R2S(Prueba_T))
''')
s = base.once(s, '''    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''', '''    call Prueba_Log("fuego id=" + I2S(id) + " k=" + I2S(k) + " r=" + I2S(Ronda_Numero) + " jug=" + I2S(DevWave_Jug) + " sigue=" + I2S(IntegerTertiaryOp(HaveSavedInteger(DevWave_HT, GetHandleId(u), 1), LoadInteger(DevWave_HT, GetHandleId(u), 1), - 1)) + " dueno=" + I2S(GetPlayerId(GetOwningPlayer(u))) + " vida=" + I2S(R2I(GetWidgetLife(u))) + "/" + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE))) + " esperadaElite=" + I2S(R2I(0.70 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) + 0.5)) + " t=" + R2S(Prueba_T))
    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''')
s = base.once(s, 'function Ronda_AlTerminar takes nothing returns nothing\n    local integer p = 0\n', '''function Prueba_FinRonda takes nothing returns nothing
    local integer f = 1
    local string q = "fx"
    loop
        exitwhen f > 19
        set q = q + " " + I2S(f) + ":" + I2S(Prueba_Fx[f])
        set Prueba_Fx[f] = 0
        set f = f + 1
    endloop
    call Prueba_Log("fin ronda=" + I2S(Ronda_Numero) + " dur=" + R2S(Prueba_T - Prueba_Ini) + " muertos=" + I2S(DevWave_Muertos) + "/" + I2S(DevWave_Total) + " elites=" + I2S(DevWave_EliteSig - 1) + "/" + I2S(DevWave_EliteE) + " cerca=" + I2S(DevWave_Cerca) + " maxBot=" + I2S(Prueba_MaxBot) + " maxMapa=" + I2S(Prueba_MaxMapa) + " lim=" + I2S(DevWave_Limite) + " " + q)
endfunction

function Ronda_AlTerminar takes nothing returns nothing
    local integer p = 0
    call Prueba_FinRonda()
''')

s = base.once(s, 'function Shop_Construir takes nothing returns nothing\n', r'''function Prueba_Curar takes nothing returns nothing
    if Game_Hero[0] != null and GetWidgetLife(Game_Hero[0]) > 0.405 then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
endfunction

function Prueba_Tick takes nothing returns nothing
    local integer o
    local integer a
    local integer n = 0
    local integer lim
    local integer id
    local unit u
    local string q
    local integer w = Ronda_Wave
    set Prueba_T = Prueba_T + 1.
    if Prueba_Fin or w == 0 then
        return
    endif
    if Ronda_Descanso or s__Wave_isDestroyed[w] then
        set Prueba_RT = 0
        return
    endif
    set Prueba_RT = Prueba_RT + 1
    if Prueba_RT == 1 then
        set Prueba_Rondas = Prueba_Rondas + 1
        set Prueba_Ini = Prueba_T
        set Prueba_MaxBot = 0
        set Prueba_MaxMapa = 0
        set Prueba_JefeT = 0
        if Prueba_Rondas >= 3 then
            set Prueba_Fin = true
            call Prueba_Log("FIN t=" + R2S(Prueba_T))
            return
        endif
        call Prueba_Log("ronda " + I2S(Ronda_Numero) + " jug=" + I2S(DevWave_Jug) + " total=" + I2S(DevWave_Total) + " lim=" + I2S(DevWave_Limite) + " refuerzo=" + I2S(DevWave_Refuerzo) + " porMatar=" + I2S(s__Wave_toKillRemaining[w]) + " pct=" + I2S(DevWave_PCT_BASE) + " t=" + R2S(Prueba_T))
    endif
    set q = "seg r=" + I2S(Ronda_Numero) + " mapa=" + I2S(s__Wave_activeOnMap[w]) + "/" + I2S(DevWave_Limite) + " bots"
    set o = WAVE_DEFAULT_OWNER_MIN
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        set a = s___Wave_activeByPlayer[s__Wave_activeByPlayer[w] + o]
        set q = q + " " + I2S(a)
        if a > Prueba_MaxBot then
            set Prueba_MaxBot = a
        endif
        set o = o + 1
    endloop
    if s__Wave_activeOnMap[w] > Prueba_MaxMapa then
        set Prueba_MaxMapa = s__Wave_activeOnMap[w]
    endif
    call Prueba_Log(q + " pend=" + I2S(s__Wave_remainingToSpawn[w]) + " porMatar=" + I2S(s__Wave_toKillRemaining[w]) + " muertos=" + I2S(DevWave_Muertos) + "/" + I2S(DevWave_Total) + " sig=" + I2S(DevWave_EliteSig) + " cerca=" + I2S(DevWave_Cerca) + " t=" + R2S(Prueba_T))
    if DevJefe != null and GetWidgetLife(DevJefe) > 0.405 then
        set Prueba_JefeT = Prueba_JefeT + 1
    endif
    set lim = 3
    if DevWave_Jug > 1 then
        // Con 8 jugadores se deja llenar el mapa 30 s para ver los topes de 240 y 40 por bot.
        set lim = 30
        if Prueba_RT <= 30 then
            set lim = 0
        endif
    endif
    set o = WAVE_DEFAULT_OWNER_MIN
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
        loop
            set u = FirstOfGroup(Prueba_G)
            exitwhen u == null
            call GroupRemoveUnit(Prueba_G, u)
            set id = GetUnitTypeId(u)
            if GetWidgetLife(u) > 0.405 and HaveSavedInteger(DevWave_HT, GetHandleId(u), 0) then
                if id >= 'ne00' and id <= 'ne09' then
                    if ModuloInteger(Prueba_RT, 3) == 0 then
                        call KillUnit(u)
                    endif
                elseif u == DevJefe then
                    if Prueba_JefeT >= 25 then
                        call KillUnit(u)
                    endif
                elseif n < lim then
                    set n = n + 1
                    call KillUnit(u)
                endif
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction

function Prueba_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Prueba_Tick)
    call TimerStart(CreateTimer(), 0.03, true, function Prueba_Curar)
endfunction

function Shop_Construir takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Prueba_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
