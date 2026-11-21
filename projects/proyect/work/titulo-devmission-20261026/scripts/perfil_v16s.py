#!/usr/bin/env python3
"""Sólo prueba (08/11/2026), no se entrega: medición por modos sobre el j de v16s-estres (estres_v16s.py, MP5).
Corrige el de v16q: enemigos invulnerables (la población ya no baja) y cada cambio de tramo corta las ráfagas en curso.

Separa cuánto cuesta cada parte con 8 tiradores. Desde la primera ronda (ronda 5, oleadas de 8 jugadores):
- 25 s de llenado: los enemigos aparecen hasta su límite y no mueren (invulnerables y con vida llena cada 0,1 s).
- 16 tramos de 15 s: dos vueltas de [MP5, SPAS-12] x [0 enemigos solos, 1 normal, 2 sin colisión, 3 sin modelo].
  0: nadie dispara. 1: 8 tiradores. 2: las balas vuelan sin colisión ni daño (RapidBolt_resolve sale enseguida).
  3: colisión y daño normales, la bala sin modelo (no se llama a Missile.model=).
- COMPLETE a los 265 s de ronda: cerrar entonces.
Registros lat\\perfil-N.txt: «seg K modo M arma A tiradores N t T pasos P enums E iter I tandas D cortes C nodos B
fallos F sondas S rescates R cand C maxvivas V oleada O golpes G». Antes de la ronda (sin enemigos ni disparos) sirve de base.
Uso: perfil_v16s.py ENTRADA.j SALIDA.j   (ENTRADA = v16s-estres/war3map.j)
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')


def funcion(s, nombre, nuevo):
    i = s.index('function ' + nombre + ' takes')
    j = s.index('endfunction\r\n', i) + len('endfunction\r\n')
    return s[:i] + nuevo.replace('\n', N) + s[j:]


s = once(s, 'boolean Est_Abierto= false\n', '''boolean Est_Abierto= false
integer Est_CatV= 1
integer Est_Modo= 0
boolean Est_SinColision= false
boolean Est_SinModelo= false
''')
s = once(s, '        local unit caster= s__RapidBolt_source[m]\n', '''        local unit caster= s__RapidBolt_source[m]
        if Est_SinColision then
            set caster=null
            return false
        endif
''')
s = once(s, '''        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''', '''        if Est_SinModelo then
        elseif Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''')
s = s.replace('lat\\\\e16s-', 'lat\\\\perfil-')
assert s.count('lat\\\\perfil-') == 1

s = funcion(s, 'Est_Armar', '''function Est_Armar takes integer p returns nothing
    set Arm_Cat[p] = Est_CatV
    set Arm_Tier[p * 7 + Est_CatV] = 6
    set Arm_Clip[p * 7 + Est_CatV] = Arm_Mag[Est_CatV * 6 + 5]
    set Arm_Rva[p * 7 + Est_CatV] = Arm_Res[Est_CatV * 6 + 5]
    set Arm_Listo[p * 7 + Est_CatV] = 0.
    call Arm_Pareja(p)
endfunction
''')

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
    // Enemigos que no mueren: la población queda fija en su límite.
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

# Disparar: el arma del tramo (Est_CatV, tier 6) en lugar de la constante.
i = s.index('function Est_Disparar takes')
j = s.index('endfunction\r\n', i)
f = s[i:j]
f2 = re.sub(r'local integer w = \d+ \* 6 \+ 6 - 1', 'local integer w = Est_CatV * 6 + 5', f)
f2 = re.sub(r'set Arm_Cat\[p\] = \d+', 'set Arm_Cat[p] = Est_CatV', f2)
f2 = re.sub(r'p \* 7 \+ \d+\]', 'p * 7 + Est_CatV]', f2)
f2 = f2.replace('Arm_Familia(6)', 'Arm_Familia(Arm_Tier[p * 7 + Est_CatV])')
assert f2.count('Est_CatV') == 7 and 'Arm_Familia(6)' not in f2, f2.count('Est_CatV')
s = s[:i] + f2 + s[j:]

s = funcion(s, 'Est_Paso', '''// 25 s de llenado y 16 tramos de 15 s: vuelta (2) x arma (MP5, SPAS-12) x modo (0-3). COMPLETE a los 265 s.
function Est_Tramo takes integer k returns nothing
    local integer p = 0
    local integer cat = 1
    set Est_Modo = ModuloInteger(k, 4)
    if ModuloInteger(k / 4, 2) == 1 then
        set cat = 4
    endif
    set Est_SinColision = Est_Modo == 2
    set Est_SinModelo = Est_Modo == 3
    set Est_Tir = 8
    if Est_Modo == 0 then
        set Est_Tir = 0
    endif
    // Corta las ráfagas en curso: el tramo nuevo empieza sin balas del anterior en camino de salir.
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
    set p = 0
    if cat != Est_CatV then
        set Est_CatV = cat
        loop
            exitwhen p > 7
            if Game_Pair[p] != 0 then
                call Est_Armar(p)
            endif
            set p = p + 1
        endloop
    endif
endfunction

function Est_Paso takes nothing returns nothing
    local integer k
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. or (Est_S >= 25. and ModuloReal(Est_S - 25., 15.) == 0. and Est_S <= 265.) then
        if Est_S == 0. then
            call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)))
        else
            call Est_Log("seg " + I2S(Est_K) + " modo " + I2S(Est_Modo) + " arma " + I2S(Est_CatV) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " pasos " + I2S(Est_Pasos) + " enums " + I2S(Est_Enums) + " iter " + I2S(Est_Iter) + " tandas " + I2S(Est_Tandas) + " cortes " + I2S(Est_Cortes) + " nodos " + I2S(Est_Nodos) + " fallos " + I2S(Est_Fallos) + " sondas " + I2S(Est_Sondas) + " rescates " + I2S(Est_Rescates) + " cand " + I2S(Est_Cand) + " maxvivas " + I2S(Est_MaxVivas) + " oleada " + I2S(Est_Vivas()) + " golpes " + I2S(s__RapidBolt_hits))
        endif
        set Est_Pasos = 0
        set Est_Enums = 0
        set Est_Iter = 0
        set Est_Tandas = 0
        set Est_Cortes = 0
        set Est_Nodos = 0
        set Est_Fallos = 0
        set Est_Sondas = 0
        set Est_Rescates = 0
        set Est_Cand = 0
        set Est_MaxVivas = 0
        set s__RapidBolt_hits = 0
        if Est_S == 0. then
            // Llenado: nadie dispara; el primer registro «seg 0» lo cierra.
            set Est_Tir = 0
            set Est_Modo = 9
        elseif Est_S < 265. then
            call Est_Tramo(Est_K)
            set Est_K = Est_K + 1
        else
            set Est_Tir = 0
            call Est_Log("COMPLETE")
        endif
    endif
endfunction
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
print('perfil v16s')
