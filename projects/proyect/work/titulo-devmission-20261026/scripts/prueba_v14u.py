#!/usr/bin/env python3
"""Sólo prueba, v14u. Además del chat «-rayo N», «-niebla INICIO FIN» cambia la niebla negra de la partida en vivo y
«-hora H» pone la hora (0..24, sigue parada; «-hora corre» la deja avanzar).
MODO muda (no se entrega): como rayos, pero sin registros durante las tormentas. Escribe «inicio» 4 s antes de la
primera, y «fin … COMPLETE» 12 s después de la última; así ninguna escritura cae cerca de una tormenta.
Lo de v14s: MODO intro y directa: los de prueba_v14q.py con el registro en lat\\v14u-N.txt y el chat «-rayo N»
(tormenta de la variante N, 1..3; otro valor la elige al azar).
MODO rayos (no se entrega): entrada directa; con la ronda activa lanza una tormenta cada 4 s (variantes 1, 2, 3 por
turno) y registra «rayo K variante V activas A dummies D lanzadas L». Tras 12 tormentas espera 10 s y registra «fin
activas A dummies D» y COMPLETE: al final no debe quedar ninguna tormenta y sí una unidad 'h00S' por jugador
(la luz persistente). «dist» es la distancia de cámara local, para ajustar la niebla.
Uso: prueba_v14u.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa', 'rayos', 'muda')
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14q.py'), ent, sal, 'intro' if modo == 'intro' else 'directa', 'v14u'],
               check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
s = base.once(s, '''    elseif m == "-vaciar" then
''', '''    elseif SubString(m, 0, 6) == "-rayo " then
        call Storm_Rayo(S2I(SubString(m, 6, StringLength(m))))
    elseif SubString(m, 0, 8) == "-niebla " then
        set Storm_TF_zstart = S2R(SubString(m, 8, 8 + Prueba_Espacio(SubString(m, 8, StringLength(m)))))
        set Storm_TF_zend = S2R(SubString(m, 9 + Prueba_Espacio(SubString(m, 8, StringLength(m))), StringLength(m)))
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, "Niebla " + R2S(Storm_TF_zstart) + " a " + R2S(Storm_TF_zend))
    elseif m == "-hora corre" then
        call SuspendTimeOfDay(false)
    elseif SubString(m, 0, 6) == "-hora " then
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, S2R(SubString(m, 6, StringLength(m))))
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, "Hora " + R2S(GetFloatGameState(GAME_STATE_TIME_OF_DAY)))
    elseif m == "-vaciar" then
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_Espacio takes string t returns integer
    local integer i = 0
    loop
        exitwhen i >= StringLength(t) or SubString(t, i, i + 1) == " "
        set i = i + 1
    endloop
    return i
endfunction

function Prueba_Chat takes nothing returns nothing
''')
if modo in ('rayos', 'muda'):
    s = base.once(s, 'integer Prueba_N= 0\n', 'integer Prueba_N= 0\ninteger Prueba_K= 0\ninteger Prueba_Espera= 0\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n',
                  '    call TimerStart(CreateTimer(), 4., true, function Prueba_Rayos)\n')
    s = base.once(s, 'function Prueba_Iniciar takes nothing returns nothing\n', r'''function Prueba_Dummies takes nothing returns string
    local integer n = 0
    local unit u
    call GroupEnumUnitsOfPlayer(Prueba_G, Player(PLAYER_NEUTRAL_PASSIVE), null)
    loop
        set u = FirstOfGroup(Prueba_G)
        exitwhen u == null
        call GroupRemoveUnit(Prueba_G, u)
        if GetUnitTypeId(u) == 'h00S' then
            set n = n + 1
        endif
    endloop
    return " activas " + I2S(s__Storm__TStorm_SIZE) + " dummies " + I2S(n) + " dist " + R2S(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE))
endfunction

function Prueba_Rayos takes nothing returns nothing
    if not Ronda_Activa or Ronda_Descanso then
        return
    endif
    if Prueba_K < 12 then
        set Prueba_K = Prueba_K + 1
        call Storm_Rayo(ModuloInteger(Prueba_K - 1, 3) + 1)
        call Prueba_Log("rayo " + I2S(Prueba_K) + " variante " + I2S(ModuloInteger(Prueba_K - 1, 3) + 1) + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
    elseif Prueba_Espera < 3 then
        set Prueba_Espera = Prueba_Espera + 1
        if Prueba_Espera == 3 then
            call Prueba_Log("fin" + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
            call Prueba_Log("COMPLETE")
        endif
    endif
endfunction

function Prueba_Iniciar takes nothing returns nothing
''')
if modo == 'muda':
    s = base.once(s, '''    if Prueba_K < 12 then
        set Prueba_K = Prueba_K + 1
        call Storm_Rayo(ModuloInteger(Prueba_K - 1, 3) + 1)
        call Prueba_Log("rayo " + I2S(Prueba_K) + " variante " + I2S(ModuloInteger(Prueba_K - 1, 3) + 1) + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
    elseif''', '''    if Prueba_Espera < 0 then
        set Prueba_Espera = 0
        call Prueba_Log("inicio" + Prueba_Dummies())
    elseif Prueba_K < 12 then
        set Prueba_K = Prueba_K + 1
        call Storm_Rayo(ModuloInteger(Prueba_K - 1, 3) + 1)
    elseif''')
    s = base.once(s, '''            call Prueba_Log("fin" + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
            call Prueba_Log("COMPLETE")''', '''            call Prueba_Log("fin" + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas) + " COMPLETE")''')
    s = base.once(s, 'integer Prueba_Espera= 0\n', 'integer Prueba_Espera= -1\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
