#!/usr/bin/env python3
"""v14e: intro de vuelta; menús y tienda en la franja norte del mapa ampliado, con la máscara negra desde el arranque.

El juego conserva su cámara: sólo la escena usa la franja. La visión de la escena se abre después de la máscara, y por
eso necesita afterUnits.

Uso: v14e.py ENTRADA.j SALIDA.j [OJO_EN_ESCENA]
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

Y = 8700.
X = 2400.  # tienda
SUELO = 209.5  # (8518 - 8192) / 4 + 128
ALTO = 9728.0

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
ojo = float(sys.argv[3]) if len(sys.argv) > 3 else 1859.5  # medido en la franja

# Escena
s = base.once(s, 'constant function Title_Y takes nothing returns real\n    return 4096.\n',
              f'constant function Title_Y takes nothing returns real\n    return {Y}\n')
s = base.once(s, 'call SetCameraPosition(0., 4096.)', f'call SetCameraPosition({X}, {Y})')
s = base.once(s, 'call SetCameraBounds(-1, 4095, -1, 4097, 1, 4097, 1, 4095)',
              f'call SetCameraBounds({X - 1:.0f}, {Y - 1:.0f}, {X - 1:.0f}, {Y + 1:.0f}, {X + 1:.0f}, {Y + 1:.0f}, {X + 1:.0f}, {Y - 1:.0f})')
s = base.once(s, 'real Title_Eye= -119.65\n', f'real Title_Eye= {ojo - SUELO - 1650.:.2f}\n')
s = base.once(s, 'constant real Shop_OJO = 1865.66\n', f'constant real Shop_OJO = {ojo:.2f}\n')

# Tienda aparte: los trackables no se destruyen y los de los menús, más altos, taparían los suyos en el mismo sitio.
s = base.once(s, 'constant function Title_X takes nothing returns real\n    return 0.\n', 'function Title_X takes nothing returns real\n    return Title_CX\n')
s = base.once(s, 'real Title_Eye=', f'real Title_CX= 0.\nreal Title_Eye=')
s = base.once(s, 'function Shop_Construir takes nothing returns nothing\n    local integer p = 0\n    local integer i = 0\n    local integer s = GetPlayerStartLocation(Player(0))\n    local trigger t = CreateTrigger()\n    local unit u\n',
              f'function Shop_Construir takes nothing returns nothing\n    local integer p = 0\n    local integer i = 0\n    local integer s = GetPlayerStartLocation(Player(0))\n    local trigger t = CreateTrigger()\n    local unit u\n    set Title_CX = {X}\n')

# Cámara: área jugable hasta la franja; el juego sigue con sus límites de antes.
viejo = '5632.0 - GetCameraMargin(CAMERA_MARGIN_TOP)'
assert s.count(viejo) == 2
s = s.replace(viejo, f'{ALTO} - GetCameraMargin(CAMERA_MARGIN_TOP)')
s = base.once(s, '    call InitBlizzard()\n', '''    call InitBlizzard()
    set bj_mapInitialCameraBounds = Rect(-7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5888.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5632.0 - GetCameraMargin(CAMERA_MARGIN_TOP))
''')

# Máscara desde el arranque; la escena se ve con afterUnits, sin alcanzar el terreno de la izquierda.
s = base.once(s, 'local rect zone = Rect(Title_X() - 2400, Title_Y() - 2400, Title_X() + 2400, Title_Y() + 2400)',
              'local rect zone = Rect(Title_X() - 2400, Title_Y() - 1400, Title_X() + 2400, Title_Y() + 1400)')
s = base.once(s, '    loop\n        exitwhen p > 11\n        set Title_Vision[p] = CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, zone, true, false)\n',
              '    call HudMask_Apply()\n    loop\n        exitwhen p > 11\n        set Title_Vision[p] = CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, zone, true, true)\n')
s = base.once(s, '    call SetCameraPosition(GetStartLocationX(s), GetStartLocationY(s))\n    call HudMask_Apply()\n',
              '    call SetCameraPosition(GetStartLocationX(s), GetStartLocationY(s))\n')
# Piezas de la tienda con el cuadro plano: el billboard de 'uidb' las pone de canto lejos de X 0.
s = base.once(s, "    local unit u = Title_Pic('uidb', px, py, w, h, depth, tex)\n    local real x = Title_WX(Shop_PY(py), depth)\n",
              "    local unit u = Title_Pic('uids', px, py, w, h, depth, tex)\n    local real x = Title_WX(Shop_PY(py), depth)\n")
# La tienda queda fuera del rectángulo del juego.
s = base.once(s, 'call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(-7296.0, -7296.0, 5888.0, 5632.0), true, true))\n',
              f'''call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(-7296.0, -7296.0, 5888.0, 5632.0), true, true))
    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect({X - 1600}, {Y - 1000}, {X + 1600}, {Y + 1000}), true, true))
''')

# Intro completa
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)', 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
