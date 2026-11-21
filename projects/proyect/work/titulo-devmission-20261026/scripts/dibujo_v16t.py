#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): qué parte de la bala cuesta dibujar. Sobre el j de camara_v16t.py (v16t-reserva, armas de
antes, reserva 512), cámara siempre en el héroe, 120 enemigos que no mueren, 8 tiradores MP5 de antes.
Leon: "date ese test haber como va" (medir qué parte de la unidad bala cuesta).

Modos de 10 s, 2 vueltas tras 12 s de llenado:
  0 nadie dispara; 1 normal; 2 bala sin inclinarse (SetUnitAnimationByIndex del dummy);
  3 sin inclinarse ni girar (tampoco SetUnitFacing); 4 sin barras de vida al golpear (Barras_Golpe);
  5 bala sin modelo (sin set_model); 6 todo lo anterior quitado.
El mismo j va en dos mapas: dummy normal y dummy plano (dummy_plano.py, sin animación de hueso).
Uso: dibujo_v16t.py ENTRADA.j SALIDA.j PREFIJO   (registros lat\\PREFIJO-N.txt)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
pre = sys.argv[3]


def funcion(s, nombre, nuevo):
    i = s.index('function ' + nombre + ' takes')
    j = s.index('endfunction\r\n', i) + len('endfunction\r\n')
    return s[:i] + nuevo.replace('\n', N) + s[j:]


s = s.replace('lat\\\\cam-', 'lat\\\\' + pre + '-')
assert s.count('lat\\\\' + pre + '-') == 1
s = once(s, 'integer Est_Balas= 0\n', '''integer Est_Balas= 0
boolean Est_SinInclina= false
boolean Est_SinGiro= false
boolean Est_SinBarras= false
boolean Est_SinModelo= false
''')
s = once(s, '''                if GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID then
                    call SetUnitAnimationByIndex(u, R2I(pitch + 90.5))
''', '''                if GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID and not Est_SinInclina then
                    call SetUnitAnimationByIndex(u, R2I(pitch + 90.5))
''')
s = once(s, '''                call SetUnitFlyHeight(u, s__Missile_z[this], 0.)
                call SetUnitFacing(u, a * bj_RADTODEG)
''', '''                call SetUnitFlyHeight(u, s__Missile_z[this], 0.)
                if not Est_SinGiro then
                    call SetUnitFacing(u, a * bj_RADTODEG)
                endif
''')
s = once(s, '''    local integer k
    if fuente == null or GetUnitTypeId(u) == 0 or GetWidgetLife(u) <= 0.405 then
''', '''    local integer k
    if Est_SinBarras then
        return
    endif
    if fuente == null or GetUnitTypeId(u) == 0 or GetWidgetLife(u) <= 0.405 then
''')
s = once(s, '''        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''', '''        if Est_SinModelo then
        elseif Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''')

s = funcion(s, 'Est_Modo_Poner', '''function Est_Modo_Poner takes integer m returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
    set Est_Modo = m
    set Est_Cat = 1
    set Est_Tir = 8
    if m == 0 then
        set Est_Tir = 0
    endif
    set Est_CamLejos = false
    set Est_SinInclina = m == 2 or m == 3 or m == 6
    set Est_SinGiro = m == 3 or m == 6
    set Est_SinBarras = m == 4 or m == 6
    set Est_SinModelo = m == 5 or m == 6
endfunction
''')
s = funcion(s, 'Est_Paso', '''function Est_Paso takes nothing returns nothing
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
    call Est_Log("seg " + I2S(Est_K) + " fase " + I2S(Est_Fase) + " pob " + I2S(Est_Pob) + " modo " + I2S(Est_Modo) + " cat " + I2S(Est_Cat) + " vuelta " + I2S(Est_Vuelta) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " nuevas " + I2S(s__MissileStats_newTotal) + " reusadas " + I2S(s__MissileStats_reusedTotal))
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
    elseif Est_Vuelta < 1 then
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
print('dibujo v16t:', pre, '7 modos x 2 vueltas, 120 enemigos, 8 MP5 de antes, cámara en el héroe')
