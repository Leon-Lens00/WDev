#!/usr/bin/env python3
"""Sólo prueba (08/11/2026), no se entrega: el mismo estrés que estres_v16q.py, sobre el j de v16s (búsqueda ajustada, lista de grandes,
tandas de 4 y rescate). Mismos escalones de 10 s (0, 1, 2, 4 y 8 tiradores; COMPLETE a los 120 s).
Registros lat\\e16s-N.txt: «escalon K tiradores N t T pasos P enums E iter I tandas D cortes C nodos B fallos F
sondas S rescates R cand C maxvivas V oleada O golpes G». pasos: casillas consultadas por Bala_Barrer; enums: búsquedas de unidades (una por bala
y tick); tandas: TriggerEvaluate de Bala_TandaP; cortes: tandas que no llegaron a su return (límite de operaciones);
fallos: casillas por clase calculadas con Bala_Calcular (no estaban en la tabla); sondas: pruebas de suelo con
objeto (Bala_Celda, una por casilla de 16 nueva); rescates: balas terminadas porque su pasada anterior se cortó.
Uso: estres_v16s.py ENTRADA.j SALIDA.j [TIER] [CAT]  (por defecto 6 1 = MP5; 6 4 = SPAS-12)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

ent, sal = sys.argv[1:3]
tier = int(sys.argv[3]) if len(sys.argv) > 3 else 6
cat = int(sys.argv[4]) if len(sys.argv) > 4 else 1
assert 1 <= tier <= 6 and 1 <= cat <= 4
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
integer Est_Tandas= 0
integer Est_Fallos= 0
integer Est_Sondas= 0
integer Est_Rescates= 0
integer Est_Cand= 0
boolean Est_Abierto= false
boolean Est_Listo= false
group Est_G= CreateGroup()
''')

# Contadores de Bala_Barrer, Bala_Libre y las tandas (v16q).
s = once(s, '''            exitwhen i > steps or I2R(i) > lim
''', '''            exitwhen i > steps or I2R(i) > lim
            set Est_Pasos=Est_Pasos + 1
''')
s = once(s, '''        call GroupEnumUnitsInRange(s__GroundCollision_targets, ax + dx * 0.5''', '''        set Est_Enums=Est_Enums + 1
        call GroupEnumUnitsInRange(s__GroundCollision_targets, ax + dx * 0.5''')
s = once(s, '''        set libre=Bala_Calcular(s__WorldBounds_minX''', '''        set Est_Fallos=Est_Fallos + 1
        set libre=Bala_Calcular(s__WorldBounds_minX''')
s = once(s, '''            local integer n= 0
            loop
                exitwhen 0 == this or n == 4
''', '''            local integer n= 0
            if Est_Abierto then
                set Est_Cortes=Est_Cortes + 1
            endif
            set Est_Abierto=true
            set Est_Tandas=Est_Tandas + 1
            loop
                exitwhen 0 == this or n == 4
                set Est_Nodos=Est_Nodos + 1
''')
s = once(s, '''            return 0 == Bala_Cursor
''', '''            set Est_Abierto=false
            return 0 == Bala_Cursor
''')
s = once(s, '''            local integer i= 0
            if Bala_Tanda == null then
''', '''            local integer i= 0
            set Est_Iter=Est_Iter + 1
            if s__RapidBolt_live > Est_MaxVivas then
                set Est_MaxVivas=s__RapidBolt_live
            endif
            if Bala_Tanda == null then
''')

s = once(s, '''            set v=2
            if s__GroundCollision_point(''', '''            set v=2
            set Est_Sondas=Est_Sondas + 1
            if s__GroundCollision_point(''')
s = once(s, '''                    set Bala_Dentro[this]=false
                    call s__RapidBolt_missileTerminateP(this)
''', '''                    set Bala_Dentro[this]=false
                    set Est_Rescates=Est_Rescates + 1
                    call s__RapidBolt_missileTerminateP(this)
''')

s = once(s, '''        if not s__GroundCollision_isTarget(u , Bala_Src , Bala_Owner) or IsUnitInGroup(u, Bala_Skip) then
''', '''        set Est_Cand=Est_Cand + 1
        if not s__GroundCollision_isTarget(u , Bala_Src , Bala_Owner) or IsUnitInGroup(u, Bala_Skip) then
''')

# Oleadas como con 8 jugadores, desde la ronda 5.
s = once(s, '        set DevWave_Jug=IMaxBJ(1, WaveCountPlayingUsers())\n', '        set DevWave_Jug=8\n')
s = once(s, '    call DevWave_Start(Ronda_Numero)\n    call Ronda_TemaEmpezar()\n',
         '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n    call DevWave_Start(Ronda_Numero)\n    call Ronda_TemaEmpezar()\n')

TIRADORES = r'''// ===== Estrés de misiles (scripts/estres_v16s.py), sólo prueba =====
function Est_Log takes string m returns nothing
    set Est_N = Est_N + 1
    call PreloadGenClear()
    call Preload(m)
    call PreloadGenEnd("lat\\e16s-" + I2S(Est_N) + ".txt")
endfunction

function Est_Armar takes integer p returns nothing
    set Arm_Cat[p] = CAT
    set Arm_Tier[p * 7 + CAT] = TIER
    set Arm_Clip[p * 7 + CAT] = Arm_Mag[CAT * 6 + TIER - 1]
    set Arm_Rva[p * 7 + CAT] = Arm_Res[CAT * 6 + TIER - 1]
    set Arm_Listo[p * 7 + CAT] = 0.
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
    local integer w = CAT * 6 + TIER - 1
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
            set Arm_Cat[p] = CAT
            set Arm_Tier[p * 7 + CAT] = TIER
            set Arm_Clip[p * 7 + CAT] = Arm_Mag[w]
            set Arm_Rva[p * 7 + CAT] = Arm_Res[w]
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
            call Est_Log("escalon " + I2S(Est_K) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " pasos " + I2S(Est_Pasos) + " enums " + I2S(Est_Enums) + " iter " + I2S(Est_Iter) + " tandas " + I2S(Est_Tandas) + " cortes " + I2S(Est_Cortes) + " nodos " + I2S(Est_Nodos) + " fallos " + I2S(Est_Fallos) + " sondas " + I2S(Est_Sondas) + " rescates " + I2S(Est_Rescates) + " cand " + I2S(Est_Cand) + " maxvivas " + I2S(Est_MaxVivas) + " oleada " + I2S(Est_Vivas()) + " golpes " + I2S(s__RapidBolt_hits))
        else
            call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " tier " + I2S(TIER) + " cat " + I2S(CAT))
        endif
        set Est_K = Est_K + 1
        set Est_Pasos = 0
        set Est_Enums = 0
        set Est_Iter = 0
        set Est_Tandas = 0
        set Est_Fallos = 0
        set Est_Sondas = 0
        set Est_Rescates = 0
        set Est_Cand = 0
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

'''.replace('TIER', str(tier)).replace('CAT', str(cat))
s = once(s, 'function ConversationUI___Start takes nothing returns nothing\n', TIRADORES.replace('\n', '\n') +
         'function ConversationUI___Start takes nothing returns nothing\n')
s = once(s, '    call Bot_Entrar()\n    call Storm_Oscuro()\n', '    call Bot_Entrar()\n    call Est_Crear()\n    call Storm_Oscuro()\n')
s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)\n',
         '    call Est_Iniciar()\n    call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
print('estres v16s tier', tier, 'cat', cat)
