#!/usr/bin/env python3
"""Sólo prueba, v14j: para que Leon juegue él mismo, sin atajos ni muertes automáticas. MODO intro arranca con la intro y
el título; MODO directa entra directo a la partida (Entrada_Directa).

Registro oculto (Preload, un archivo por línea en lat\\v14j-N.txt), cada 2 s y hasta 900 líneas (30 min): tiempo,
objetivo y ojo de la cámara local, tienda abierta del jugador local, ronda y descanso. Sirve para ver si la cámara
se movió de su ancla en el título o la tienda.
Uso: prueba_v14j.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa')
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Prueba_N= 0\ninteger Prueba_T= 0\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_v14j.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v14j-" + I2S(Prueba_N) + ".txt")
endfunction

function Prueba_Tick takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    set Prueba_T = Prueba_T + 2
    if Prueba_N >= 900 then
        call PauseTimer(GetExpiredTimer())
        return
    endif
    call Prueba_Log("t " + I2S(Prueba_T) + " objetivo " + R2S(GetCameraTargetPositionX()) + " " + R2S(GetCameraTargetPositionY()) + " ojo " + R2S(GetCameraEyePositionZ()) + " tienda " + I2S(IntegerTertiaryOp(Shop_Open[p], 1, 0)) + " ronda " + I2S(Ronda_Numero) + " descanso " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)))
endfunction

function Intro_Begin takes nothing returns nothing
''')
inicio = 'Entrada_Directa' if modo == 'directa' else 'Intro_Begin'
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
              'call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n    call TimerStart(CreateTimer(), 0.1, false, function ' + inicio + ')')
Path(sal).write_text(s, encoding='latin-1', newline='')
