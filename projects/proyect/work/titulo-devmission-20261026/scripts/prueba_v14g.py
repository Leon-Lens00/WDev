#!/usr/bin/env python3
"""Sólo prueba, v14g: entrada directa, héroe que recibe daño pero se cura cada 0,03 s, empieza en la ronda RONDA (7 por defecto).

Registro oculto (Preload, un archivo por línea en lat\\v14g-N.txt), sin textos en pantalla:
- al empezar la ronda, cada entrada de la oleada: tipo, dueño, tope, cantidad, jefe y espera;
- cada 2 s, vivos por tipo (normales/élites), vivos por dueño, jefe (vida, distancia, llamadas, icono), saltos,
  acelerones, carreras y entradas;
- aparición del jefe y cada llamada de refuerzos.
Hasta que sale el jefe, a partir de 14 s mata a todos los de la oleada cada 2 s, para no esperar. A los 90 s del jefe
lleva al héroe a 1500 de él, para ver el icono en el borde. Termina a los 150 s del jefe con FIN.

Uso: prueba_v14g.py ENTRADA.j SALIDA.j [RONDA]
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ronda = sys.argv[3] if len(sys.argv) > 3 else '7'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'integer Ronda_Numero = 1\n', f'integer Ronda_Numero = {ronda}\n')
s = base.once(s, 'real Title_CX=', '''integer Prueba_N= 0
real Prueba_T= 0.
real Prueba_JefeT= - 1.
boolean Prueba_Fin= false
group Prueba_G= CreateGroup()
real Title_CX=''')

s = base.once(s, '\nfunction DevJefe_Limpiar takes nothing returns nothing\n', r'''
// TEMPORARY test bridge (scripts/prueba_v14g.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v14g-" + I2S(Prueba_N) + ".txt")
endfunction

function Prueba_Jefe takes nothing returns nothing
    set Prueba_JefeT = Prueba_T
    call Prueba_Log("jefe t=" + R2S(Prueba_T) + " id=" + I2S(GetUnitTypeId(DevJefe)) + " vida=" + I2S(R2I(GetWidgetLife(DevJefe))) + "/" + I2S(R2I(GetUnitState(DevJefe, UNIT_STATE_MAX_LIFE))))
endfunction

function DevJefe_Limpiar takes nothing returns nothing
''')
s = base.once(s, '    set DevJefe_Llamadas=0\n', '    set DevJefe_Llamadas=0\n    call Prueba_Jefe()\n')
s = base.once(s, '    set o=IMinBJ(DevJefe_Llamadas, 6)\n', '''    set o=IMinBJ(DevJefe_Llamadas, 6)
    call Prueba_Log("llamada " + I2S(DevJefe_Llamadas) + " duenos=" + I2S(o) + " c/u=" + I2S(WaveComputeScaledAmount(2 , DevWave_Jug , 50.)) + " t=" + R2S(Prueba_T))
''')

s = base.once(s, 'function DevWave_Arrancar takes nothing returns nothing\n', r'''function Prueba_Entradas takes nothing returns nothing
    local integer i = 0
    local integer e
    local integer w = Ronda_Wave
    call Prueba_Log("ronda " + I2S(Ronda_Numero) + " jug=" + I2S(DevWave_Jug) + " tipos=" + I2S(DevWave_NTipos) + " entradas=" + I2S(s__Wave_slotCount[w]) + " porMatar=" + I2S(s__Wave_toKillRemaining[w]) + " topeDueno=" + I2S(s__Wave_perPlayerLimit[w]))
    loop
        exitwhen i >= s__Wave_slotCount[w]
        set e = s___Wave_slots[s__Wave_slots[w] + i]
        call Prueba_Log("entrada id=" + I2S(s__WaveSlot_unitId[e]) + " o=" + I2S(GetPlayerId(s__WaveSlot_owner[e])) + " lim=" + I2S(s__WaveSlot_limit[e]) + " n=" + I2S(s__WaveSlot_total[e]) + " g=" + I2S(s__WaveSlot_slotGroupId[e]) + " jefe=" + I2S(IntegerTertiaryOp(s__WaveSlot_isBoss[e], 1, 0)) + " espera=" + I2S(s__WaveSlot_killGate[e]))
        set i = i + 1
    endloop
endfunction

// El héroe recibe daño (con uno invulnerable la IA sólo espera y no salta), pero no muere.
function Prueba_Curar takes nothing returns nothing
    if Game_Hero[0] != null and GetWidgetLife(Game_Hero[0]) > 0.405 then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
endfunction

function Prueba_Tick takes nothing returns nothing
    local integer k = 0
    local integer o
    local integer a
    local integer e
    local integer id
    local unit u
    local string s
    local string d = ""
    local boolean matar
    set Prueba_T = Prueba_T + 2.
    if Prueba_Fin or Ronda_Wave == 0 then
        return
    endif
    if Prueba_T == 4. then
        call Prueba_Entradas()
    endif
    set matar = DevJefe == null and Prueba_JefeT < 0. and Prueba_T >= 14.
    set s = "t=" + R2S(Prueba_T) + " r=" + I2S(Ronda_Numero)
    set o = WAVE_DEFAULT_OWNER_MIN
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        set a = 0
        call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
        loop
            set u = FirstOfGroup(Prueba_G)
            exitwhen u == null
            call GroupRemoveUnit(Prueba_G, u)
            if GetWidgetLife(u) > 0.405 then
                set a = a + 1
                set id = GetUnitTypeId(u)
                set k = 0
                loop
                    exitwhen k >= DevWave_NTipos
                    if id == DevWave_Tipo[k] then
                        call SaveInteger(Barras_HT, 2, k, LoadInteger(Barras_HT, 2, k) + 1)
                    elseif id == 'ne00' + k then
                        call SaveInteger(Barras_HT, 3, k, LoadInteger(Barras_HT, 3, k) + 1)
                    endif
                    set k = k + 1
                endloop
                if matar and u != DevJefe then
                    call KillUnit(u)
                endif
            endif
        endloop
        set d = d + " " + I2S(a)
        set o = o + 1
    endloop
    set k = 0
    set s = s + " tipos"
    loop
        exitwhen k >= DevWave_NTipos
        set s = s + " " + I2S(LoadInteger(Barras_HT, 2, k)) + "/" + I2S(LoadInteger(Barras_HT, 3, k))
        call SaveInteger(Barras_HT, 2, k, 0)
        call SaveInteger(Barras_HT, 3, k, 0)
        set k = k + 1
    endloop
    set s = s + " duenos" + d
    if DevJefe != null then
        set s = s + " jefe=" + I2S(R2I(GetWidgetLife(DevJefe))) + "/" + I2S(R2I(GetUnitState(DevJefe, UNIT_STATE_MAX_LIFE))) + " dist=" + I2S(R2I(SquareRoot(Pow(GetUnitX(DevJefe) - GetUnitX(Game_Hero[0]), 2) + Pow(GetUnitY(DevJefe) - GetUnitY(Game_Hero[0]), 2)))) + " ll=" + I2S(DevJefe_Llamadas)
        if DevJefe_Icono[0] != null then
            set s = s + " ico=" + I2S(IntegerTertiaryOp(IsUnitHidden(DevJefe_Icono[0]), 0, 1)) + " icoXY=" + I2S(R2I(GetUnitX(DevJefe_Icono[0]))) + "," + I2S(R2I(GetUnitY(DevJefe_Icono[0])))
        endif
    endif
    set s = s + " salto=" + I2S(WaveAI__TeleportCount) + " acel=" + I2S(WaveAI__SprintCount) + " carrera=" + I2S(WaveAI__HasteCount) + " entradas=" + I2S(s__Wave_slotCount[Ronda_Wave]) + " porMatar=" + I2S(s__Wave_toKillRemaining[Ronda_Wave])
    call Prueba_Log(s)
    if Prueba_JefeT >= 0. and Prueba_T - Prueba_JefeT == 90. and DevJefe != null then
        call SetUnitPosition(Game_Hero[0], GetUnitX(DevJefe) + 1500., GetUnitY(DevJefe))
        call Prueba_Log("heroe lejos t=" + R2S(Prueba_T))
    endif
    if Prueba_JefeT >= 0. and Prueba_T - Prueba_JefeT >= 150. then
        set Prueba_Fin = true
        call Prueba_Log("FIN t=" + R2S(Prueba_T))
    endif
    set u = null
endfunction

function DevWave_Arrancar takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n    call TimerStart(CreateTimer(), 0.03, true, function Prueba_Curar)\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
