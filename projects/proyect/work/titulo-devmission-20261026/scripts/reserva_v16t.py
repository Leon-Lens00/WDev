#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): reserva del reciclador de balas, sobre el j de un estrés de estres_v16t.py (v16t-relojes,
MP5 tier 6). Leon: "nos hace falta configurar bien las reservas entonces" (la prueba del disparo mostró que cada bala
crea y mata una unidad porque desde v13g el reciclador no tiene reserva).

- CUPO 0: como ahora (sin reserva). CUPO N: se recupera la precarga original de MissileRecycler (la de v13e, quitada en
  v13g) con 8 sectores × N unidades; el resto del reciclador no cambia (DEATH_TIME sigue en 0,3).
- Ronda 9, 240 enemigos que no mueren; 12 s de llenado y 3 vueltas de 4 modos de 10 s. COMPLETE tras la última.
  0 nadie dispara
  1 8 tiradores, apuntado normal (enemigo más cercano)
  2 8 tiradores, cada uno en su dirección (p × 45°): un sector del reciclador por tirador
  3 8 tiradores, todos hacia la misma dirección (0°): todas las balas piden el mismo sector
- El registro añade las unidades de bala nuevas y reutilizadas (MissileStats, acumuladas).
Registros lat\\\\resN-K.txt. Uso: reserva_v16t.py ENTRADA.j V13E.j SALIDA.j CUPO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
v13e = Path(sys.argv[2]).read_text(encoding='latin-1', newline='')
cupo = int(sys.argv[4])


def funcion(s, nombre, nuevo):
    i = s.index('function ' + nombre + ' takes')
    j = s.index('endfunction\r\n', i) + len('endfunction\r\n')
    return s[:i] + nuevo.replace('\n', N) + s[j:]


# --- reserva ---
if cupo > 0:
    ini = v13e.index('function MissileRecycler___Init takes nothing returns nothing')
    a = v13e.index('            call s__MissileStats_configure(', ini)
    b = v13e.index('        call TimerStart(MissileRecycler___gameTime', a)
    bloque = v13e[a:b]
    assert bloque.count('CreateUnit(') == 1 and 'exitwhen n == end' in bloque
    ini = s.index('function MissileRecycler___Init takes nothing returns nothing')
    a = s.index('            call s__MissileStats_configure(0)\r\n', ini)
    b = s.index('        call TimerStart(MissileRecycler___gameTime', a)
    assert b - a < 80, s[a:b]
    s = s[:a] + bloque + s[b:]
    s = once(s, 'constant integer MissileRecycler___ANG_STORAGE_MAX= 12\n',
             f'constant integer MissileRecycler___ANG_STORAGE_MAX= {cupo}\n')

s = once(s, 'integer Est_Balas= 0\n', '''integer Est_Balas= 0
integer Est_Pob= 240
integer Est_Fase= 0
integer Est_Modo= 0
integer Est_Vuelta= 0
real Est_Fin= 12.
boolean Est_Fijo= false
boolean Est_Mismo= false
''')
s = once(s, '                call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n',
         '                if not Est_Fijo then\n                    call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n                endif\n')
s = once(s, '                    set a = I2R(p) * bj_PI / 4.\n',
         '                    set a = I2R(p) * bj_PI / 4.\n                    if Est_Mismo then\n                        set a = 0.\n                    endif\n')
s = s.replace('lat\\\\e16t-', f'lat\\\\res{cupo}-')
assert s.count(f'lat\\\\res{cupo}-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // reserva: límite fijo.\n        set DevWave_Limite=Est_Pob\n')

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
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction
''')

s = funcion(s, 'Est_Paso', '''function Est_Modo_Poner takes integer m returns nothing
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
    if m == 0 then
        set Est_Tir = 0
    endif
    set Est_Fijo = m >= 2
    set Est_Mismo = m == 3
endfunction

function Est_Paso takes nothing returns nothing
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. then
        set DevWave_Limite = Est_Pob
        call Est_Modo_Poner(0)
        call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite) + " cupo ''' + str(cupo) + '''")
    endif
    if Est_S < Est_Fin then
        return
    endif
    call Est_Log("seg " + I2S(Est_K) + " fase " + I2S(Est_Fase) + " pob " + I2S(Est_Pob) + " modo " + I2S(Est_Modo) + " vuelta " + I2S(Est_Vuelta) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " nuevas " + I2S(s__MissileStats_newTotal) + " reusadas " + I2S(s__MissileStats_reusedTotal) + " precarga " + I2S(s__MissileStats_preloadTotal))
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
    elseif Est_Modo < 3 then
        call Est_Modo_Poner(Est_Modo + 1)
    elseif Est_Vuelta < 2 then
        set Est_Vuelta = Est_Vuelta + 1
        call Est_Modo_Poner(0)
    else
        call Est_Modo_Poner(0)
        set Est_Fin = 100000.
        call Est_Log("COMPLETE")
    endif
endfunction
''')
Path(sys.argv[3]).write_text(s, encoding='latin-1', newline='')
print(f'reserva v16t: cupo {cupo} por sector ({8 * cupo} unidades), 240 enemigos, 4 modos x 3 vueltas')
