#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): qué parte del lanzamiento de cada disparo cuesta, sobre el j de un estrés de estres_v16t.py
(v16t-relojes, MP5 tier 6). Leon: "Medir el disparo" (las pruebas anteriores mostraron que el coste es por disparo,
no por vuelo).

- Ronda 9, 240 enemigos que no mueren (invulnerables y vida llena); 12 s de llenado y 3 vueltas de 7 modos de 10 s.
  COMPLETE tras la última (unos 222 s de ronda).
  0 nadie dispara
  1 8 tiradores, normal
  2 sin boca: no se comprueba la boca del arma (Bala_Boca, 2 Bala_Libre); la bala sale a 24 del tirador
  3 sin modelo: la bala no lleva efecto adjunto (Missile.model=)
  4 sin animación: el tirador no gira ni pone "attack" en cada disparo
  5 sin bala: Arm_Tiro sale al empezar (orden, ritmo, animación y munición sí; ningún Missile)
  6 sin modelo ni colisión: la bala vuela sin efecto y sin búsqueda de unidades/paredes
Registros lat\\\\disp-N.txt. Uso: disparo_v16t.py ENTRADA.j SALIDA.j
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
integer Est_Pob= 240
integer Est_Fase= 0
integer Est_Modo= 0
integer Est_Vuelta= 0
real Est_Fin= 12.
boolean Est_SinColision= false
boolean Est_SinModelo= false
boolean Est_SinBoca= false
boolean Est_SinAnim= false
boolean Est_SinBala= false
''')
s = once(s, '''        local unit caster= s__RapidBolt_source[m]
        if Bala_Area[m] > 0. then
''', '''        local unit caster= s__RapidBolt_source[m]
        if Est_SinColision then
            set caster=null
            return false
        endif
        if Bala_Area[m] > 0. then
''')
s = once(s, '''        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''', '''        if Est_SinModelo then
        elseif Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''')
s = once(s, '''        call Bala_Boca(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r)
''', '''        if Est_SinBoca then
            set s__GroundCollision_x=x + dx * 24. / distance
            set s__GroundCollision_y=y + dy * 24. / distance
            set s__GroundCollision_reason=0
        else
            call Bala_Boca(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r)
        endif
''')
s = once(s, '''        call s__RapidPair_face(this)
        call SetUnitAnimation(s__RapidPair_actor[this], "attack")
''', '''        if not Est_SinAnim then
            call s__RapidPair_face(this)
            call SetUnitAnimation(s__RapidPair_actor[this], "attack")
        endif
''')
s = once(s, '''        set Est_Balas=Est_Balas + 1
        set Arm_Alcance=range
''', '''        set Est_Balas=Est_Balas + 1
        if Est_SinBala then
            set a=null
            return
        endif
        set Arm_Alcance=range
''')
s = s.replace('lat\\\\e16t-', 'lat\\\\disp-')
assert s.count('lat\\\\disp-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // disparo: límite por escalones.\n        set DevWave_Limite=Est_Pob\n')

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
    set Est_SinBoca = m == 2
    set Est_SinModelo = m == 3 or m == 6
    set Est_SinAnim = m == 4
    set Est_SinBala = m == 5
    set Est_SinColision = m == 6
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
    call Est_Log("seg " + I2S(Est_K) + " fase " + I2S(Est_Fase) + " pob " + I2S(Est_Pob) + " modo " + I2S(Est_Modo) + " vuelta " + I2S(Est_Vuelta) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " cortes " + I2S(Est_Cortes))
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
    elseif Est_Modo < 6 then
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
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('disparo v16t: 240 enemigos, 7 modos x 3 vueltas')
