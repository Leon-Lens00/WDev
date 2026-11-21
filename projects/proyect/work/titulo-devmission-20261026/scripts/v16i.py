#!/usr/bin/env python3
"""v16i (08/11/2026): hora del día parada durante el tutorial (vídeo de v16h).
En v16h la hora corría desde bj_MELEE_STARTING_TOD (8:00) y hacia los 200 s del tutorial anochecía: la tienda, la caja
verde y la despedida se veían casi negras. Tut_Begin fija las 12:00 y suspende la hora. Al entrar en la partida,
Storm_Oscuro (ya existente) pone la hora de la variante elegida y la vuelve a suspender, así que no hace falta restaurar.
Uso: v16i.py ENTRADA.j SALIDA.j (el j de v16h)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s
s = once(s, '''    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    call ClearSelection()
    call EnableUserControl(false)
''', '''    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    call ClearSelection()
    call EnableUserControl(false)
    // v16i: mediodia fijo durante el tutorial; Storm_Oscuro pone la hora de la partida al entrar.
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
    call SuspendTimeOfDay(true)
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16i ok')
