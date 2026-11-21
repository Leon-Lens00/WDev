#!/usr/bin/env python3
"""v14zb: luz del héroe de 1500 y más oscuridad en Tarde y Noche. Parte del j de v14za.

- Luz_Poner usa war3mapImported\\LightWhite1500.mdx (luz_1500.cjs: LightWhite700 con alcance 1500).
- Tarde a las 19:09 (sol de Dark Nights ~0,08, antes ~0,15), misma niebla marrón.
- Noche: la hora ya da el mínimo de Dark Nights (0,05), así que se oscurece la niebla azul: 0,07/0,14/0,26 (antes
  0,10/0,20/0,35).
Uso: v14zb.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '"war3mapImported\\\\LightWhite700.mdx"', '"war3mapImported\\\\LightWhite1500.mdx"')
s = base.once(s, 'call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 19.)\n', 'call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 19.15)\n')
s = base.once(s, '''        set Storm_TF_red = 0.1
        set Storm_TF_green = 0.2
        set Storm_TF_blue = 0.35
''', '''        set Storm_TF_red = 0.07
        set Storm_TF_green = 0.14
        set Storm_TF_blue = 0.26
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
