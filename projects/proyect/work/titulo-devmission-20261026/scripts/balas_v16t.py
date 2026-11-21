#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): qué parte de cada bala cuesta, sobre el j de un estrés de estres_v16t.py (v16t-relojes,
MP5 tier 6). Leon: "Sí, medir balas" (tras ver que el lag crece con enemigos × balas).

- Ronda 9, límite por escalones 120 y 240; enemigos que no mueren (invulnerables y vida llena).
- Por escalón: 12 s de llenado y 2 vueltas de 6 modos de 10 s. COMPLETE tras la última (unos 264 s de ronda).
  0 nadie dispara
  1 8 tiradores, normal
  2 sin colisión: RapidBolt_resolve sale al empezar (sin búsqueda de unidades, paredes ni daño; la bala vuela hasta
    su alcance)
  3 sin modelo: la bala no lleva modelo (no se llama a Missile.model=)
  4 sin barras: el golpe no avisa a las barras de enemigos (Barras_Golpe)
  5 sin daño ni barras: el golpe no llama a UnitDamageTarget ni a Barras_Golpe (la bala sí muere al chocar)
Aviso: los enemigos son invulnerables, así que en esta prueba el daño ya no mata ni lanza muertes.
Registros lat\\\\balas-N.txt. Uso: balas_v16t.py ENTRADA.j SALIDA.j
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
boolean Est_SinColision= false
boolean Est_SinModelo= false
boolean Est_SinBarras= false
boolean Est_SinDano= false
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
s = once(s, '''        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
        call Barras_Golpe(caster, target)
''', '''        if not Est_SinDano then
            call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
        endif
        if not Est_SinBarras then
            call Barras_Golpe(caster, target)
        endif
''')
s = s.replace('lat\\\\e16t-', 'lat\\\\balas-')
assert s.count('lat\\\\balas-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // balas: límite por escalones.\n        set DevWave_Limite=Est_Pob\n')

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
    set Est_SinColision = m == 2
    set Est_SinModelo = m == 3
    set Est_SinBarras = m == 4 or m == 5
    set Est_SinDano = m == 5
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
print('balas v16t: 120 y 240 enemigos, 6 modos x 2 vueltas')
