#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): desde cuántos tiradores y cuántos enemigos baja el juego, sobre el j de un estrés de
estres_v16t.py (8 tiradores posibles, sin tutorial, MP5 tier 6).
Leon: "el lag con los missiles, mediras con un jugador hasta con 8, para saber desde cuanto da lag, y otro tambien las
unidades maximas en el mapa".

- Ronda 9 con oleadas de 8 jugadores. El límite de vivos sube por escalones: 60, 120, 180 y 240. Los enemigos no
  mueren (invulnerables y vida llena), así que cada escalón mantiene su población.
- Por escalón: 12 s de llenado y 9 tramos de 10 s con 0, 1, 2 … 8 tiradores con MP5 tier 6 (unos 8 tiros/s cada uno).
  COMPLETE tras el último tramo de 240 (unos 410 s de ronda).
Registros lat\\\\carga-N.txt. Uso: carga_v16t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


def funcion(s, nombre, nuevo):
    i = s.index('function ' + nombre + ' takes')
    j = s.index('endfunction\r\n', i) + len('endfunction\r\n')
    return s[:i] + nuevo.replace('\n', N) + s[j:]


s = once(s, 'integer Est_Balas= 0\n', '''integer Est_Balas= 0
integer Est_Pob= 60
integer Est_Fase= 0
real Est_Fin= 12.
integer Est_Piensa0= 0
''')
s = s.replace('lat\\\\e16t-', 'lat\\\\carga-')
assert s.count('lat\\\\carga-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // carga: límite por escalones.\n        set DevWave_Limite=Est_Pob\n')

s = funcion(s, 'Est_Vida', '''function Est_Vida takes nothing returns nothing
    local integer p = 0
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local unit u
    loop
        exitwhen p > 7
        if Game_Hero[p] != null and GetWidgetLife(Game_Hero[p]) > 0.405 then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
    // Enemigos que no mueren: la población queda en el límite del escalón.
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Est_G, Player(o), null)
        loop
            set u = FirstOfGroup(Est_G)
            exitwhen u == null
            call GroupRemoveUnit(Est_G, u)
            if GetWidgetLife(u) > 0.405 then
                call SetUnitInvulnerable(u, true)
                call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction
''')

s = funcion(s, 'Est_Paso', '''function Est_Cortar takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
endfunction

function Est_Paso takes nothing returns nothing
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. then
        set DevWave_Limite = Est_Pob
        call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite))
    endif
    if Est_S < Est_Fin then
        return
    endif
    call Est_Log("seg " + I2S(Est_K) + " fase " + I2S(Est_Fase) + " pob " + I2S(Est_Pob) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " piensa " + I2S(WaveAI__ThinkCount - Est_Piensa0) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " cortes " + I2S(Est_Cortes))
    set Est_K = Est_K + 1
    set Est_Piensa0 = WaveAI__ThinkCount
    set Est_Balas = 0
    set Est_MaxVivas = 0
    set Est_Enums = 0
    set Est_Cortes = 0
    set s__RapidBolt_hits = 0
    if Est_Fase == 0 then
        set Est_Fase = 1
        set Est_Tir = 0
        set Est_Fin = Est_Fin + 10.
    elseif Est_Tir < 8 then
        set Est_Tir = Est_Tir + 1
        set Est_Fin = Est_Fin + 10.
    else
        call Est_Cortar()
        set Est_Tir = 0
        if Est_Pob >= 240 then
            set Est_Fin = 100000.
            call Est_Log("COMPLETE")
        else
            set Est_Pob = Est_Pob + 60
            set DevWave_Limite = Est_Pob
            set Est_Fase = 0
            set Est_Fin = Est_Fin + 12.
        endif
    endif
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('carga v16t: escalones 60-240, tiradores 0-8')
