#!/usr/bin/env python3
"""Sólo prueba (13/11/2026), no se entrega: coste del sistema de oleadas por partes, sobre el j de un estrés de
estres_v16t.py (8 tiradores, sin tutorial, interfaz normal).
Leon: "prepara tus pruebas evaluativas para wave, si se logra detectar algo mal hecho o repitiendose constantemente por
ahi como el sistema unidades acciones eventos y otros".

- Ronda 9 con oleadas de 8 jugadores: límite min(5 x 9 x 8, 240) = 240 enemigos vivos. No mueren (invulnerables y vida
  llena cada 0,1 s), así que la población queda fija y no salen élites.
- 30 s de llenado y 14 tramos de 15 s (2 vueltas de 7 modos); COMPLETE a los 240 s de ronda:
  0 normal, nadie dispara
  1 sin interfaz: para el reloj de 100 Hz de ConversationUI (cámara, barras, HUD, textos)
  2 sin IA: para el reloj de WaveAI (los enemigos siguen con su última orden)
  3 enemigos en pausa (PauseUnit) y sin IA: sin movimiento ni búsqueda de camino
  4 sin interfaz y cámara lejos de los enemigos: no se dibujan
  5 8 tiradores con MP5 tier 6, todo normal
  6 8 tiradores sin IA
- Contadores por tramo: piensa (WaveAI think), ataques y esperas (órdenes de la IA), reobjetivo, ordenes (eventos
  EVENT_PLAYER_UNIT_ISSUED_ORDER de cualquier unidad, contados en AbilitySilence_OnSilence), balas.
Registros lat\\\\olas-N.txt. Uso: oleadas_v16t.py ENTRADA.j SALIDA.j
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
integer Est_Modo= -1
integer Est_Ordenes= 0
integer Est_Piensa0= 0
integer Est_Ataques0= 0
integer Est_Esperas0= 0
integer Est_Reobj0= 0
boolean Est_Pausados= false
''')
s = once(s, 'function AbilitySilence_OnSilence takes nothing returns boolean\n',
         'function AbilitySilence_OnSilence takes nothing returns boolean\n    set Est_Ordenes = Est_Ordenes + 1\n')
s = s.replace('lat\\\\e16t-', 'lat\\\\olas-')
assert s.count('lat\\\\olas-') == 1
s = once(s, '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 5)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n')

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

// Pone el modo m; antes deja todo como en una partida normal.
function Est_Tramo takes integer m returns nothing
    local integer p = 0
    local real x
    local real y
    set Est_Modo = m
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
    call ResumeTimer(ConversationUI___Clock)
    call ResumeTimer(WaveAI__Clock)
    if Est_Pausados then
        call Est_Pausar(false)
    endif
    set Est_Tir = 0
    if m == 1 or m == 4 then
        call PauseTimer(ConversationUI___Clock)
    endif
    if m == 2 or m == 3 or m == 6 then
        call PauseTimer(WaveAI__Clock)
    endif
    if m == 3 then
        call Est_Pausar(true)
    endif
    if m == 4 then
        // Cámara a una esquina vacía: los enemigos no se dibujan (la lógica sigue igual).
        set x = GetCameraBoundMinX() + 200.
        set y = GetCameraBoundMinY() + 200.
        call SetCameraPosition(x, y)
    endif
    if m == 5 or m == 6 then
        set Est_Tir = 8
    endif
endfunction

function Est_Paso takes nothing returns nothing
    if not Est_Listo or (Est_S < 0. and not Ronda_Activa) then
        return
    endif
    set Est_S = Est_S + 0.5
    if Est_S == 0. or (Est_S >= 30. and ModuloReal(Est_S - 30., 15.) == 0. and Est_S <= 240.) then
        if Est_S == 0. then
            call Est_Log("inicio t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite))
        else
            call Est_Log("seg " + I2S(Est_K) + " modo " + I2S(Est_Modo) + " tiradores " + I2S(Est_Tir) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " oleada " + I2S(Est_Vivas()) + " ia " + I2S(WaveAIGetUnitCount()) + " piensa " + I2S(WaveAI__ThinkCount - Est_Piensa0) + " ataques " + I2S(WaveAI__AttackOrderCount - Est_Ataques0) + " esperas " + I2S(WaveAI__WaitOrderCount - Est_Esperas0) + " reobjetivo " + I2S(WaveAI__RetargetCount - Est_Reobj0) + " ordenes " + I2S(Est_Ordenes) + " balas " + I2S(Est_Balas) + " maxvivas " + I2S(Est_MaxVivas) + " golpes " + I2S(s__RapidBolt_hits) + " enums " + I2S(Est_Enums) + " cortes " + I2S(Est_Cortes))
            set Est_K = Est_K + 1
        endif
        set Est_Piensa0 = WaveAI__ThinkCount
        set Est_Ataques0 = WaveAI__AttackOrderCount
        set Est_Esperas0 = WaveAI__WaitOrderCount
        set Est_Reobj0 = WaveAI__RetargetCount
        set Est_Ordenes = 0
        set Est_Balas = 0
        set Est_MaxVivas = 0
        set Est_Enums = 0
        set Est_Cortes = 0
        set s__RapidBolt_hits = 0
        if Est_S == 0. then
            // Llenado: nadie dispara; el primer registro «seg 0» lo cierra.
            set Est_Tir = 0
            set Est_Modo = 9
        elseif Est_S < 240. then
            call Est_Tramo(ModuloInteger(Est_K - 1, 7))
        else
            call Est_Tramo(0)
            call Est_Log("COMPLETE")
        endif
    endif
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('oleadas v16t: ronda 9, 240 vivos, 14 tramos')
