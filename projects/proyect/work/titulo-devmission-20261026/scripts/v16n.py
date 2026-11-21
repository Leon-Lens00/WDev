#!/usr/bin/env python3
"""v16n (08/11/2026): rachas a tiros de verdad. En la prueba de v16m (lat/v16m-1.txt) la Winchester terminó la escena
de tiers con 0/80, así que en las fases 96..98 no salió ningún tiro (tiros 193 fijo) y los tres enemigos cayeron por el
KillUnit de la fase 99; la fase 95 además agotó sus 6 s esperando que llegaran. Ahora la fase 95 llena el cargador de
la Winchester y los enemigos salen más cerca (X+750..800 en lugar de 950..1000) hacia X+300..330.
Uso: v16n.py ENTRADA.j SALIDA.j (el j de v16m o v16m-prueba)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, '''        call Tut_Enemigo('nmcf', Tut_X + 950., Tut_Y - 100., 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 330., Tut_Y - 100.)
        call Tut_Enemigo('nmcf', Tut_X + 1000., Tut_Y, 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 360., Tut_Y)
        call Tut_Enemigo('nmcf', Tut_X + 950., Tut_Y + 100., 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 330., Tut_Y + 100.)
''', '''        // v16n: la Winchester llega vacía de la escena de tiers.
        set Arm_Clip[Tut_P * 7 + 4] = Arm_Mag[25]
        set Arm_Rva[Tut_P * 7 + 4] = Arm_Res[25]
        set Arm_Fin[Tut_P] = 0.
        call Tut_Enemigo('nmcf', Tut_X + 750., Tut_Y - 100., 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 300., Tut_Y - 100.)
        call Tut_Enemigo('nmcf', Tut_X + 800., Tut_Y, 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 330., Tut_Y)
        call Tut_Enemigo('nmcf', Tut_X + 750., Tut_Y + 100., 45.)
        call Tut_Destino(Tut_NEnem - 1, Tut_X + 300., Tut_Y + 100.)
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16n ok')
