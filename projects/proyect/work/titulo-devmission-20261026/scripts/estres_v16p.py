#!/usr/bin/env python3
"""Sólo prueba (08/11/2026), no se entrega: estrés de misiles con 8 tiradores sobre el j de v16p (el mapa sin registros).

- Entrada directa a la partida (Entrada_Directa en lugar del tutorial). Oleadas como con 8 jugadores (DevWave_Jug = 8)
  desde la ronda 5 (límite 200).
- Tiradores: el jugador 0 (Leon) y 7 parejas más (jugadores 1..7, sin humano) con Game_Cuerpo en un anillo de 260
  alrededor del héroe. Todos con subfusil de tier ESTRES_TIER (6 = MP5, el más rápido), cargador lleno cada 0,25 s
  (balas ilimitadas) y vida llena cada 0,1 s. Cada 0,25 s cada tirador activo vuelve a lanzar la ráfaga hacia el
  enemigo más cercano a 1100, o hacia fuera del anillo si no hay ninguno.
- Escalones de 10 s desde que empieza la ronda: 0, 1, 2 y 4 tiradores; desde los 40 s, los 8 (COMPLETE a los 120 s),
  y siguen hasta cerrar el juego. El juego se pausa sin foco: dejar la ventana delante. Al cerrar cada escalón escribe un registro lat\\e16-N.txt:
  «escalon K tiradores N t T pasos P enums E iter I cortes C nodos B maxvivas V oleada O».
  pasos/enums: pasos y búsquedas de unidades de GroundCollision_trace; iter: pasadas de RapidBolt_missileIterateP;
  cortes: pasadas que no llegaron al final (límite de operaciones); nodos: balas recorridas; oleada: vivas.
  T es el tiempo de juego; la fecha del archivo da el reloj real (cociente juego/real = ralentización).
Uso: estres_v16p.py ENTRADA.j SALIDA.j [TIER]
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

ent, sal = sys.argv[1:3]
tier = int(sys.argv[3]) if len(sys.argv) > 3 else 6
assert 1 <= tier <= 6
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'integer Ronda_Numero = 1\n', '''integer Ronda_Numero = 1
integer Est_N= 0
integer Est_K= 0
real Est_S= -1.
integer Est_Tir= 0
integer Est_Pasos= 0
integer Est_Enums= 0
integer Est_Iter= 0
integer Est_Cortes= 0
integer Est_Nodos= 0
integer Est_MaxVivas= 0
boolean Est_Abierto= false
boolean Est_Listo= false
group Est_G= CreateGroup()
''')

# Contadores de la colisión.
s = once(s, '''            exitwhen i > steps
            set nx=ax + dx * I2R(i) / I2R(steps)
''', '''            exitwhen i > steps
            set Est_Pasos=Est_Pasos + 1
            set nx=ax + dx * I2R(i) / I2R(steps)
''')
s = once(s, '''            if units then
                call GroupEnumUnitsInRange(s__GroundCollision_targets, nx, ny, reach, null)
''', '''            if units then
                set Est_Enums=Est_Enums + 1
                call GroupEnumUnitsInRange(s__GroundCollision_targets, nx, ny, reach, null)
''')
# Pasadas de RapidBolt: el CRLF va escrito a mano porque hay líneas con espacios al final.
i = s.index('        function s__RapidBolt_missileIterateP takes nothing returns boolean\r\n')
j = s.index('        endfunction\r\n', i)
f = s[i:j]
a = '            local unit u\r\n            \r\n            loop\r\n'
assert f.count(a) == 1
f = f.replace(a, '            local unit u\r\n            if Est_Abierto then\r\n                set Est_Cortes=Est_Cortes + 1\r\n'
              '            endif\r\n            set Est_Abierto=true\r\n            set Est_Iter=Est_Iter + 1\r\n'
              '            if s__RapidBolt_live > Est_MaxVivas then\r\n                set Est_MaxVivas=s__RapidBolt_live\r\n'
              '            endif\r\n            loop\r\n')
b = '                set node=(s__Missile_Missile__MissileStructure____next[(this)])'
assert f.count(b) == 1
f = f.replace(b, '                set Est_Nodos=Est_Nodos + 1\r\n' + b)
c = '                return false\r\n'
assert f.count(c) == 1
f = f.replace(c, '            set Est_Abierto=false\r\n' + c)
s = s[:i] + f + s[j:]

# Oleadas como con 8 jugadores, desde la ronda 5.
s = once(s, '        set DevWave_Jug=IMaxBJ(1, WaveCountPlayingUsers())\n', '        set DevWave_Jug=8\n')
s = once(s, '    call DevWave_Start(Ronda_Numero)\n    call Ronda_TemaEmpezar()\n',
         '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n    call DevWave_Start(Ronda_Numero)\n    call Ronda_TemaEmpezar()\n')

TIRADORES = r'''// ===== Estrés de misiles (scripts/estres_v16p.py), sólo prueba =====
function Est_Log takes string m returns nothing
    set Est_N = Est_N + 1
    call PreloadGenClear()
    call Preload(m)
    call PreloadGenEnd("lat\\e16-" + I2S(Est_N) + ".txt")
endfunction

function Est_Armar takes integer p returns nothing
    set Arm_Cat[p] = 1
    set Arm_Tier[p * 7 + 1] = TIER
    set Arm_Clip[p * 7 + 1] = Arm_Mag[6 + TIER - 1]
    set Arm_Rva[p * 7 + 1] = Arm_Res[6 + TIER - 1]
    set Arm_Listo[p * 7 + 1] = 0.
    call Arm_Pareja(p)
endfunction

function Est_Crear takes nothing returns nothing
    local integer p = 1
    local real x
    local real y
    local real a
    if Game_First < 0 then
        return
    endif
    set x = GetUnitX(Game_Hero[Game_First])
    set y = GetUnitY(Game_Hero[Game_First])
    loop
        exitwhen p > 7
        if not Game_On[p] then
            set a = I2R(p) * bj_PI / 4.
            set Vidas_Actual[p] = Vidas_INICIO
            call Game_Cuerpo(p, x + 260. * Cos(a), y + 260. * Sin(a))
        endif
        set p = p + 1
    endloop
    set p = 0
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call Est_Armar(p)
        endif
        set p = p + 1
    endloop
    set Est_Listo = true
endfunction

function Est_Vida takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_Hero[p] != null and GetWidgetLife(Game_Hero[p]) > 0.405 then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
endfunction

// Cada 0,25 s: balas llenas y nueva ráfaga de los tiradores activos (los Est_Tir primeros con pareja).
function Est_Disparar takes nothing returns nothing
    local integer p = 0
    local integer n = 0
    local integer w = 6 + TIER - 1
    local unit h
    local unit u
    local unit mejor
    local real dm
    local real d
    local real x
    local real y
    local real a
    if not Est_Listo then
        return
    endif
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Arm_Cat[p] = 1
            set Arm_Tier[p * 7 + 1] = TIER
            set Arm_Clip[p * 7 + 1] = Arm_Mag[w]
            set Arm_Rva[p * 7 + 1] = Arm_Res[w]
            set Arm_Fin[p] = 0.
            if n < Est_Tir then
                set h = Game_Hero[p]
                set x = GetUnitX(h)
                set y = GetUnitY(h)
                set mejor = null
                set dm = 1100. * 1100.
                call GroupEnumUnitsInRange(Est_G, x, y, 1100., null)
                loop
                    set u = FirstOfGroup(Est_G)
                    exitwhen u == null
                    call GroupRemoveUnit(Est_G, u)
                    if s__GroundCollision_isTarget(u, h, Player(p)) then
                        set d = (GetUnitX(u) - x) * (GetUnitX(u) - x) + (GetUnitY(u) - y) * (GetUnitY(u) - y)
                        if d < dm then
                            set dm = d
                            set mejor = u
                        endif
                    endif
                endloop
                if mejor != null then
                    call s__RapidPair_castFamily(Game_Pair[p], GetUnitX(mejor), GetUnitY(mejor), Arm_Familia(TIER))
                else
                    set a = I2R(p) * bj_PI / 4.
                    call s__RapidPair_castFamily(Game_Pair[p], x + 600. * Cos(a), y + 600. * Sin(a), Arm_Familia(TIER))
                endif
            endif
            set n = n + 1
        endif
        set p = p + 1
    endloop
    set h = null
    set u = null
    set mejor = null
endfunction

function Est_Vivas takes nothing returns integer
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local integer v = 0
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Est_G, Player(o), null)
        loop
            set u = FirstOfGroup(Est_G)
            exitwhen u == null
            call GroupRemoveUnit(Est_G, u)
            if GetWidgetLife(u) > 0.405 then
                set v = v + 1
            endif
        endloop
        set o = o + 1
    endloop
    set u = null
    return v
endfunction

// Escalones de 10 s: 0, 1, 2 y 4 tiradores; desde los 40 s, 8 hasta el final (COMPLETE a los 120 s).
function Est_Paso takes nothing returns nothing
    local integer nuevo
    // Cuenta desde la primera ronda y sigue también en el descanso.
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. or Est_S == 10. or Est_S == 20. or Est_S == 30. or Est_S == 40. or Est_S == 120. then
        if Est_S > 0. then
            call Est_Log("escalon " + I2S(Est_K) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " pasos " + I2S(Est_Pasos) + " enums " + I2S(Est_Enums) + " iter " + I2S(Est_Iter) + " cortes " + I2S(Est_Cortes) + " nodos " + I2S(Est_Nodos) + " maxvivas " + I2S(Est_MaxVivas) + " oleada " + I2S(Est_Vivas()) + " golpes " + I2S(s__RapidBolt_hits))
        else
            call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " tier " + I2S(TIER))
        endif
        set Est_K = Est_K + 1
        set Est_Pasos = 0
        set Est_Enums = 0
        set Est_Iter = 0
        set Est_Cortes = 0
        set Est_Nodos = 0
        set Est_MaxVivas = 0
        if Est_S == 0. then
            set Est_Tir = 0
        elseif Est_S == 10. then
            set Est_Tir = 1
        elseif Est_S == 20. then
            set Est_Tir = 2
        elseif Est_S == 30. then
            set Est_Tir = 4
        else
            set Est_Tir = 8
        endif
        if Est_S == 120. then
            call Est_Log("COMPLETE")
        endif
    endif
endfunction

function Est_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.1, true, function Est_Vida)
    call TimerStart(CreateTimer(), 0.25, true, function Est_Disparar)
    call TimerStart(CreateTimer(), 0.5, true, function Est_Paso)
endfunction

'''.replace('TIER', str(tier))
s = once(s, 'function ConversationUI___Start takes nothing returns nothing\n', TIRADORES.replace('\n', '\n') +
         'function ConversationUI___Start takes nothing returns nothing\n')
s = once(s, '    call Bot_Entrar()\n    call Storm_Oscuro()\n', '    call Bot_Entrar()\n    call Est_Crear()\n    call Storm_Oscuro()\n')
s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)\n',
         '    call Est_Iniciar()\n    call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
print('estres v16p tier', tier)
