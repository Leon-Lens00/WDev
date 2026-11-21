#!/usr/bin/env python3
"""v14u: Dark Nights (The_Silent, Hive 324142) con Storm. Parte del j de v14t.

- Niebla de la partida: vuelve a la negra de v14s (1730/5190, la de Storm escalada a la cámara de juego).
- DNC: SetDayNightModels pasa a DNCDarkNightsLordaeron (terreno y unidades) de Dark Nights, importados en
  war3mapImported. El día sigue con luz; de 19:12 a 5:24 la luz baja a 0,05.
- Al entrar en la partida la hora pasa a 0:00 y se para (SuspendTimeOfDay), para ver la noche con las tormentas. Los
  menús y la intro siguen de día (8:00) hasta entonces.

Uso: v14u.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base


def once(s, old, new):
    return base.once(s, old.encode('utf-8').decode('latin-1'), new.encode('utf-8').decode('latin-1'))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, '''// v14t: niebla negra de la partida, más cerrada que la de Storm escalada (v14s: 1730/5190). El periódico de Storm la aplica.
function Storm_Oscuro takes nothing returns nothing
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1000.
    set Storm_TF_zend = 4500.
''', '''// v14u: niebla negra de la partida (la de Storm escalada a la cámara de juego, como v14s) y noche fija de Dark Nights.
// El periódico de Storm aplica la niebla.
function Storm_Oscuro takes nothing returns nothing
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
    call SuspendTimeOfDay(true)
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1730.
    set Storm_TF_zend = 5190.
''')
s = once(s, '''    call SetDayNightModels("Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronTerrain\\\\DNCLordaeronTerrain.mdl", "Environment\\\\DNC\\\\DNCLordaeron\\\\DNCLordaeronUnit\\\\DNCLordaeronUnit.mdl")
''', '''    call SetDayNightModels("war3mapImported\\\\DNCDarkNightsLordaeronTerrain.mdx", "war3mapImported\\\\DNCDarkNightsLordaeronUnit.mdx")
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14u: Dark Nights, noche fija y niebla 1730/5190')
