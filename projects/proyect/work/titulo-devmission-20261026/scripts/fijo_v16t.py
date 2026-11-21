#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): ¿el lag medido es de las balas, del apuntado del bot de prueba o del movimiento de los
enemigos? Sobre el j de un estrés de estres_v16t.py (v16t-relojes, MP5 tier 6). Leon: "Sí, prepararla".

- Ronda 9, límite por escalones 120 y 240; enemigos que no mueren (invulnerables y vida llena).
- Por escalón: 12 s de llenado y 2 vueltas de 6 modos de 10 s. COMPLETE tras la última (unos 264 s de ronda).
  0 nadie dispara
  1 8 tiradores, apuntado normal (Est_Disparar busca el enemigo más cercano en 1100 cada 0,25 s)
  2 8 tiradores, apuntado fijo: cada uno dispara en su dirección (p × 45°) sin buscar enemigos
  3 enemigos en pausa (PauseUnit) y 8 tiradores con apuntado normal
  4 enemigos en pausa y 8 tiradores con apuntado fijo
  5 enemigos en pausa, nadie dispara
Registros lat\\\\fijo-N.txt. Uso: fijo_v16t.py ENTRADA.j SALIDA.j
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
integer Est_Pob= 120
integer Est_Fase= 0
integer Est_Modo= 0
integer Est_Vuelta= 0
real Est_Fin= 12.
boolean Est_Fijo= false
boolean Est_Pausados= false
''')
s = once(s, '                call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n',
         '                if not Est_Fijo then\n                    call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n                endif\n')
s = s.replace('lat\\\\e16t-', 'lat\\\\fijo-')
assert s.count('lat\\\\fijo-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // fijo: límite por escalones.\n        set DevWave_Limite=Est_Pob\n')

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
                if Est_Pausados and not IsUnitPaused(u) then
                    call PauseUnit(u, true)
                endif
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction
''')

s = funcion(s, 'Est_Paso', '''function Est_Pausar takes boolean b returns nothing
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local unit u
    set Est_Pausados = b
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Est_G, Player(o), null)
        loop
            set u = FirstOfGroup(Est_G)
            exitwhen u == null
            call GroupRemoveUnit(Est_G, u)
            call PauseUnit(u, b)
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction

function Est_Modo_Poner takes integer m returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
    set Est_Modo = m
    set Est_Tir = 8
    if m == 0 or m == 5 then
        set Est_Tir = 0
    endif
    set Est_Fijo = m == 2 or m == 4
    if (m >= 3) != Est_Pausados then
        call Est_Pausar(m >= 3)
    endif
endfunction

function Est_Paso takes nothing returns nothing
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. then
        set DevWave_Limite = Est_Pob
        call Est_Modo_Poner(0)
        call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite))
    endif
    if Est_S < Est_Fin then
        return
    endif
    call Est_Log("seg " + I2S(Est_K) + " fase " + I2S(Est_Fase) + " pob " + I2S(Est_Pob) + " modo " + I2S(Est_Modo) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " cortes " + I2S(Est_Cortes))
    set Est_K = Est_K + 1
    set Est_Balas = 0
    set Est_MaxVivas = 0
    set Est_Enums = 0
    set Est_Cortes = 0
    set s__RapidBolt_hits = 0
    set Est_Fin = Est_Fin + 10.
    if Est_Fase == 0 then
        set Est_Fase = 1
        set Est_Vuelta = 0
        call Est_Modo_Poner(0)
    elseif Est_Modo < 5 then
        call Est_Modo_Poner(Est_Modo + 1)
    elseif Est_Vuelta == 0 then
        set Est_Vuelta = 1
        call Est_Modo_Poner(0)
    else
        call Est_Modo_Poner(0)
        if Est_Pob >= 240 then
            set Est_Fin = 100000.
            call Est_Log("COMPLETE")
        else
            set Est_Pob = 240
            set DevWave_Limite = Est_Pob
            set Est_Fase = 0
            set Est_Fin = Est_Fin + 2.
        endif
    endif
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('fijo v16t: 120 y 240 enemigos, 6 modos x 2 vueltas')
