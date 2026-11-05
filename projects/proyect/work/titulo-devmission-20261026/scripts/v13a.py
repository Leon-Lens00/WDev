#!/usr/bin/env python3
"""v13a: script de Dev Mission sobre el terreno de IziPizi, arena central.

Mueve inicios, puntos de oleada y escena de menús; ajusta cámara, niebla y ambiente, y apaga el clima del mapa anterior.
Uso: v13a.py IN_J OUT_J PUNTOS
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

CENTRO = -9408., -3072.
INICIOS = ((203, 84), (84, 203), (-84, 203), (-203, 84), (-203, -84), (-84, -203), (84, -203), (203, -84))
L, B, R, T = -23808., -7680., 7424., 7168.
VISION = 'Rect(-13888., -6080., -4928., -1600.)'  # arena central con 192 de margen
CAMARA = (f'    call SetCameraBounds({L} + GetCameraMargin(CAMERA_MARGIN_LEFT), {B} + GetCameraMargin(CAMERA_MARGIN_BOTTOM), '
          f'{R} - GetCameraMargin(CAMERA_MARGIN_RIGHT), {T} - GetCameraMargin(CAMERA_MARGIN_TOP), '
          f'{L} + GetCameraMargin(CAMERA_MARGIN_LEFT), {T} - GetCameraMargin(CAMERA_MARGIN_TOP), '
          f'{R} - GetCameraMargin(CAMERA_MARGIN_RIGHT), {B} + GetCameraMargin(CAMERA_MARGIN_BOTTOM))\r\n')

if __name__ == '__main__':
    j_in, j_out, puntos = sys.argv[1:4]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s, n = re.subn(r'    call SetCameraBounds\(- 27776\.0[^\r\n]*\r\n', CAMARA, s)
    assert n == 1
    s = base.once(s, 'call SetTerrainFogEx(0, 1900.0, 4000.0, 0.150, 1.000, 1.000, 0.000)\n', 'call SetTerrainFogEx(1, 3000.0, 5000.0, 0.000, 1.000, 1.000, 1.000)\n')
    s = base.once(s, 'call SetWaterBaseColor(0, 255, 255, 255)\n', 'call SetWaterBaseColor(0, 0, 0, 255)\n')
    s = base.once(s, 'call SetAmbientDaySound("SunkenRuinsDay")\n', 'call SetAmbientDaySound("BarrensDay")\n')
    s = base.once(s, 'call SetAmbientNightSound("SunkenRuinsNight")\n', 'call SetAmbientNightSound("BarrensNight")\n')
    s = base.once(s, 'Rect(GetLocationX(start) - Ronda_VISION, GetLocationY(start) - Ronda_VISION, GetLocationX(start) + Ronda_VISION, GetLocationY(start) + Ronda_VISION)', VISION)
    s = base.once(s, '    call CreateRegions()\n    call InitBlizzard()\n', '    call InitBlizzard()\n')
    s = base.once(s, 'constant function Title_Y takes nothing returns real\n    return -8704.\n', 'constant function Title_Y takes nothing returns real\n    return 4096.\n')
    for i, (dx, dy) in enumerate(INICIOS):
        s, n = re.subn(rf'call DefineStartLocation\({i}, [^\r\n]*\)', f'call DefineStartLocation({i}, {CENTRO[0] + dx}, {CENTRO[1] + dy})', s)
        assert n == 1
    s, n = re.subn(r'(function DevWave_Puntos takes integer w returns nothing\r\n).*?(    endfunction\r\n)',
                   lambda m: m[1] + Path(puntos).read_text().replace('\n', '\r\n') + m[2], s, count=1, flags=re.S)
    assert n == 1
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
