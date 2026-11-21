#!/usr/bin/env python3
"""v14zi (06/11/2026): tarde fija en la más oscura y día con neblina blanca. Parte del j de v14zh.

- Tarde: Tarde_N pasa a 4 (niebla 0,09 0,035 0,008), elegida por Leon.
- Día: ya no es el día claro de las 12 h. Va a la meseta de las 3,0 h de dia_v14zi.cjs (luz tenue y blanca) con una
  niebla gris blanquecina según Dia_N (1 la más clara .. 4 la más oscura; por defecto 3) de 1500 a 5000, como la
  tarde y la noche. La niebla depende de la distancia a la cámara, no de la linterna: fuera del círculo de luz sólo
  se ve la neblina y dentro el terreno con su color.
- De día también hay linterna y la batería baja (antes no había luz de día).

Uso: v14zi.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')
s = once(s, 'integer Tarde_N= 3\n', 'integer Tarde_N= 4\n// v14zi: niebla del día (dia_v14zi.cjs).\nreal Dia_Hora= 3.0\ninteger Dia_N= 3\n')
s = once(s, '    if Variante == 0 or GetUnitTypeId(Game_Hero[p]) == 0 or Bat_T[p] <= 0. then\n',
         '    if GetUnitTypeId(Game_Hero[p]) == 0 or Bat_T[p] <= 0. then\n')
s = once(s, 'Ronda_Activa and not Ronda_Descanso and Variante != 0 and GetUnitTypeId(Game_Hero[p]) != 0',
         'Ronda_Activa and not Ronda_Descanso and GetUnitTypeId(Game_Hero[p]) != 0')
s = once(s, '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
        set Storm_TF_zstart = 2500.
        set Storm_TF_zend = 8000.
        set Storm_TF_red = 0.55
        set Storm_TF_green = 0.62
        set Storm_TF_blue = 0.72
''', '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, Dia_Hora)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        call Dia_Niebla()
''')
s = once(s, 'function Tarde_Niebla takes nothing returns nothing\n', '''function Dia_Niebla takes nothing returns nothing
    if Dia_N == 1 then
        set Storm_TF_red = 0.62
        set Storm_TF_green = 0.64
        set Storm_TF_blue = 0.67
    elseif Dia_N == 2 then
        set Storm_TF_red = 0.50
        set Storm_TF_green = 0.52
        set Storm_TF_blue = 0.55
    elseif Dia_N == 3 then
        set Storm_TF_red = 0.40
        set Storm_TF_green = 0.42
        set Storm_TF_blue = 0.45
    else
        set Storm_TF_red = 0.30
        set Storm_TF_green = 0.32
        set Storm_TF_blue = 0.35
    endif
endfunction

function Tarde_Niebla takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
