#!/usr/bin/env python3
"""v13b: script de Dev Mission sobre el terreno de Swamped Temple 3.0.

Los puntos de oleada salen de las unidades de tipo 'nPto': cada una se lee y se retira al iniciar el mapa.
Uso: v13b.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

INICIO = -5376., 2688.
OFFSETS = ((203, 84), (84, 203), (-84, 203), (-203, 84), (-203, -84), (-84, -203), (84, -203), (203, -84))
MARCADORES = ((-192., -512.),)  # centro del mapa, sitio de la taberna original
L, B, R, T = -7296., -7296., 5888., 5632.
VISION = f'Rect({L}, {B}, {R}, {T})'
CAMARA = (f'    call SetCameraBounds({L} + GetCameraMargin(CAMERA_MARGIN_LEFT), {B} + GetCameraMargin(CAMERA_MARGIN_BOTTOM), '
          f'{R} - GetCameraMargin(CAMERA_MARGIN_RIGHT), {T} - GetCameraMargin(CAMERA_MARGIN_TOP), '
          f'{L} + GetCameraMargin(CAMERA_MARGIN_LEFT), {T} - GetCameraMargin(CAMERA_MARGIN_TOP), '
          f'{R} - GetCameraMargin(CAMERA_MARGIN_RIGHT), {B} + GetCameraMargin(CAMERA_MARGIN_BOTTOM))\r\n')
GLOBALES = 'real array DevWave_MarcaX\nreal array DevWave_MarcaY\ninteger DevWave_Marcas = 0\n'
PUNTOS = '''        local integer i = 0
        loop
            exitwhen i == DevWave_Marcas
            call DevWave_Punto(w, DevWave_MarcaX[i], DevWave_MarcaY[i])
            set i = i + 1
        endloop
        if s__Wave_pointCount[w] == 0 and DevWave_Marcas > 0 then
            call s__Wave_addPoint(w, DevWave_MarcaX[0], DevWave_MarcaY[0])
        endif
'''
LECTOR = '''    // Reads and removes the 'nPto' markers; each one is a wave spawn point.
    function DevWave_Marcadores takes nothing returns nothing
        local group g = CreateGroup()
        local unit u
        call GroupEnumUnitsOfPlayer(g, Player(PLAYER_NEUTRAL_PASSIVE), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if GetUnitTypeId(u) == 'nPto' then
                set DevWave_MarcaX[DevWave_Marcas] = GetUnitX(u)
                set DevWave_MarcaY[DevWave_Marcas] = GetUnitY(u)
                set DevWave_Marcas = DevWave_Marcas + 1
                call RemoveUnit(u)
            endif
        endloop
        call DestroyGroup(g)
        set g = null
    endfunction
'''

if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s, n = re.subn(r'    call SetCameraBounds\(- 27776\.0[^\r\n]*\r\n', CAMARA, s)
    assert n == 1
    s = base.once(s, 'call SetTerrainFogEx(0, 1900.0, 4000.0, 0.150, 1.000, 1.000, 0.000)\n', 'call SetTerrainFogEx(0, 1700.0, 8000.0, 0.150, 1.000, 1.000, 0.000)\n')
    s = base.once(s, '    call CreateRegions()\n    call InitBlizzard()\n', '    call InitBlizzard()\n')
    s = base.once(s, 'constant function Title_Y takes nothing returns real\n    return -8704.\n', 'constant function Title_Y takes nothing returns real\n    return 4096.\n')
    s = base.once(s, 'Rect(GetLocationX(start) - Ronda_VISION, GetLocationY(start) - Ronda_VISION, GetLocationX(start) + Ronda_VISION, GetLocationY(start) + Ronda_VISION)', VISION)
    s = base.once(s, 'constant real Ronda_VISION = 4000.\n', 'constant real Ronda_VISION = 4000.\n' + GLOBALES)
    for i, (dx, dy) in enumerate(OFFSETS):
        s, c = re.subn(rf'call DefineStartLocation\({i}, [^\r\n]*\)', f'call DefineStartLocation({i}, {INICIO[0] + dx}, {INICIO[1] + dy})', s)
        assert c == 1
    s, n = re.subn(r'(    // Grid over the walkable arena[^\r\n]*\r\n)?(    function DevWave_Puntos takes integer w returns nothing\r\n).*?(    endfunction\r\n)',
                   lambda m: LECTOR.replace('\n', '\r\n') + m[2] + PUNTOS.replace('\n', '\r\n') + m[3], s, count=1, flags=re.S)
    assert n == 1
    crear = ''.join(f"    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nPto', {x}, {y}, 270.)\n" for x, y in MARCADORES)
    s = base.once(s, '    call Title_Init()\n    call TrackTest_Init()\n', crear + '    call DevWave_Marcadores()\n    call Title_Init()\n    call TrackTest_Init()\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
