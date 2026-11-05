#!/usr/bin/env python3
"""Sólo prueba, v14j con límites A: arranque normal (intro y título). Registra la cámara cada segundo, avisa "bloqueo"
a los 22 s para que vista.sh envíe las flechas y escribe FIN a los 40 s. NO integrar. Uso: vista3t_v14j.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Vista_N= 0\ninteger Vista_T= 0\nreal Title_CX=')
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/vista3t_v14j.py).
function Vista_Log takes string s returns nothing
    set Vista_N = Vista_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\vista-" + I2S(Vista_N) + ".txt")
endfunction

function Vista_Tick takes nothing returns nothing
    local string q = " t " + I2S(Vista_T)
    set Vista_T = Vista_T + 1
    if Vista_T == 22 then
        set q = "bloqueo" + q
    elseif Vista_T == 40 then
        set q = "FIN" + q
    else
        set q = "cam" + q
    endif
    call Vista_Log(q + " ojo " + R2S(GetCameraEyePositionX()) + " " + R2S(GetCameraEyePositionY()) + " " + R2S(GetCameraEyePositionZ()) + " objetivo " + R2S(GetCameraTargetPositionX()) + " " + R2S(GetCameraTargetPositionY()) + " " + R2S(GetCameraTargetPositionZ()) + " limites x " + R2S(GetRectMinX(bj_mapInitialCameraBounds)) + " " + R2S(GetRectMaxX(bj_mapInitialCameraBounds)))
endfunction

function Intro_Begin takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Vista_Tick)
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
