#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): cámara lejos y armas solas sin oleadas, con las armas de antes (armas_antes.py) y reserva
8 × 64 = 512, sobre el j de un estrés de estres_v16t.py (v16t-reserva + armas_antes, tier 6).
Leon: "toma una arma y ejecutala, luego lleva la camara a otro lado del mapa para ver como se ve el rendimiento asi,
tambien probemos las armas solas sin oleadas subiendo de 1 a 8 jugadores para ver desde donde va tal rendimiento".

- Fase 1: ronda 9, 120 enemigos que no mueren, MP5 de antes (880 rpm). 12 s de llenado y 2 vueltas de 4 modos de 10 s:
  0 nadie, cámara en el héroe; 1 8 tiradores, cámara en el héroe; 2 nadie, cámara lejos; 3 8 tiradores, cámara lejos.
  Cámara lejos: FollowCamera centra la cámara cerca de la esquina del área jugable (mín. + 1500) en vez del héroe; las balas y los
  enemigos se siguen calculando, pero no se dibujan.
- Fase 2: se quitan los enemigos (RemoveUnit) y no aparecen más (Wave.trySpawn sale). Cámara en el héroe.
  Modo 0 de la fase 2: nadie, sin enemigos (10 s); modos 11-18: 1 a 8 tiradores MP5 de antes; modos 21-28: 1 a 8 tiradores FN SCAR de antes.
  Sin enemigos, cada tirador dispara hacia su dirección (p × 45°) y las balas llegan a su alcance.
Registros lat\\\\cam-N.txt. Uso: camara_v16t.py ENTRADA.j SALIDA.j
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


# --- reserva 8 × 64 ---
s = once(s, 'constant integer MissileRecycler___ANG_STORAGE_MAX= 32\n', 'constant integer MissileRecycler___ANG_STORAGE_MAX= 64\n')
assert 'call s__MissileStats_configure(MissileRecycler___ANG_N * MissileRecycler___ANG_STORAGE_MAX)' in s

s = once(s, 'integer Est_Balas= 0\n', '''integer Est_Balas= 0
integer Est_Pob= 120
integer Est_Fase= 0
integer Est_Modo= 0
integer Est_Vuelta= 0
real Est_Fin= 12.
boolean Est_Fijo= false
boolean Est_Mismo= false
boolean Est_CamLejos= false
boolean Est_SinOleada= false
real Est_CamX= 0.
real Est_CamY= 0.
''')
s = once(s, '                call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n',
         '                if not Est_Fijo then\n                    call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)\n                endif\n')
s = once(s, '                    set a = I2R(p) * bj_PI / 4.\n',
         '                    set a = I2R(p) * bj_PI / 4.\n                    if Est_Mismo then\n                        set a = 0.\n                    endif\n')
s = s.replace('lat\\\\e16t-', 'lat\\\\cam-')
assert s.count('lat\\\\cam-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')
s = once(s, '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n',
         '        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)\n        // camara: límite fijo.\n        set DevWave_Limite=Est_Pob\n')

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

# cámara lejos: FollowCamera centra en un punto vacío en lugar del héroe (la interfaz sigue igual)
s = once(s, '''                set x=GetUnitX(u)
                set y=GetUnitY(u)
                set z=UserInterface_GetTerrainZ(x , y) + GetUnitFlyHeight(u)
                call s__Camera_setPosition(cam,x , y , z)
''', '''                set x=GetUnitX(u)
                set y=GetUnitY(u)
                if Est_CamLejos then
                    set x=Est_CamX
                    set y=Est_CamY
                endif
                set z=UserInterface_GetTerrainZ(x , y) + GetUnitFlyHeight(u)
                call s__Camera_setPosition(cam,x , y , z)
''')
# sin oleadas: no aparecen más enemigos
s = once(s, '''            if DevWave_Limite > 0 and s__Wave_activeOnMap[this] >= DevWave_Limite then
                return
            endif
''', '''            if DevWave_Limite > 0 and s__Wave_activeOnMap[this] >= DevWave_Limite then
                return
            endif
            if Est_SinOleada then
                return
            endif
''')

s = funcion(s, 'Est_Paso', '''function Est_Quitar takes nothing returns nothing
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local unit u
    set Est_SinOleada = true
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Est_G, Player(o), null)
        loop
            set u = FirstOfGroup(Est_G)
            exitwhen u == null
            call GroupRemoveUnit(Est_G, u)
            call RemoveUnit(u)
        endloop
        set o = o + 1
    endloop
    set u = null
endfunction

// Fase 1 (120 enemigos, MP5 de antes): modo 0 nadie, 1 disparan, 2 nadie y cámara lejos, 3 disparan y cámara lejos.
// Fase 2 (sin enemigos): modo 10 + n = n tiradores con MP5 de antes, 20 + n = n tiradores con FN SCAR de antes.
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
    set Est_Cat = 1
    set Est_Tir = 0
    set Est_CamLejos = false
    if m < 10 then
        if m == 1 or m == 3 then
            set Est_Tir = 8
        endif
        set Est_CamLejos = m >= 2
    elseif m < 20 then
        set Est_Tir = m - 10
    else
        set Est_Cat = 2
        set Est_Tir = m - 20
    endif
endfunction

function Est_Paso takes nothing returns nothing
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. then
        set DevWave_Limite = Est_Pob
        // dentro del área jugable (v1: los límites de cámara del momento dieron Y -10920, fuera del mapa, y el juego se cerró)
        set Est_CamX = GetRectMinX(bj_mapInitialPlayableArea) + 1500.
        set Est_CamY = GetRectMinY(bj_mapInitialPlayableArea) + 1500.
        call Est_Modo_Poner(0)
        call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite) + " camara " + R2S(Est_CamX) + " " + R2S(Est_CamY))
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
    elseif Est_Fase == 1 then
        if Est_Modo < 3 then
            call Est_Modo_Poner(Est_Modo + 1)
        elseif Est_Vuelta < 1 then
            set Est_Vuelta = Est_Vuelta + 1
            call Est_Modo_Poner(0)
        else
            // sin oleadas: quitar enemigos y 2 s para asentar (tramo de fase 2 que no se mide)
            call Est_Quitar()
            set Est_Fase = 2
            set Est_Pob = 0
            call Est_Modo_Poner(0)
        endif
    else
        if Est_Fase == 2 then
            set Est_Fase = 3
            call Est_Modo_Poner(11)
        elseif Est_Modo == 18 then
            call Est_Modo_Poner(21)
        elseif Est_Modo == 28 then
            call Est_Modo_Poner(0)
            set Est_Fin = 100000.
            call Est_Log("COMPLETE")
        else
            call Est_Modo_Poner(Est_Modo + 1)
        endif
    endif
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('camara v16t: 120 enemigos con cámara cerca y lejos; sin oleadas 0-8 MP5 y 1-8 SCAR de antes')
