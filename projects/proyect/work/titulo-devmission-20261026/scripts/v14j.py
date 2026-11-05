#!/usr/bin/env python3
"""v14j: el script de v14i con los límites de cámara del terreno ensanchado (scripts/terreno_v14j.py).

El minimapa muestra la zona de los límites de cámara que fija main, no la del terreno: con el mapa ensanchado 48 casillas
a cada lado, main pasa de X -7296..5888 a -13440..12032 (los márgenes del editor, 15 y 10 casillas). El área jugable
inicial crece igual; las franjas nuevas están selladas en el pathing y quedan bajo la máscara negra.

Idea del usuario (04/11/2026, probada con scripts/vista2_v14j.py): lo que está bajo la máscara negra no se pinta en el
minimapa, que además encaja la zona conservando su proporción. Con los límites de la partida en todo el mapa ensanchado
(apaisado), sólo la zona visible queda negra y el cuadro ya no sobresale de la consola. La intro y la tienda usan esos
mismos límites en lugar del punto de 2 x 2, con la cámara fijada a un 'dumi' (Menu_Ancla) en el centro de la escena.
Con el bloqueo la cámara informa el ojo 127,25 más alto, pero la tienda se dibuja igual píxel a píxel sin compensarlo
(evidencia/vista-v14j-dz0); compensarlo con ZOFFSET la ampliaba 1,4 veces.
Uso: v14j.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
viejo = '    call SetCameraBounds(-7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5888.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 9728.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 9728.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5888.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))\n'
nuevo = viejo.replace('-7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT)', '-13440.0 + GetCameraMargin(CAMERA_MARGIN_LEFT)').replace('5888.0', '12032.0')
s = base.once(s, viejo, nuevo)
s = base.once(s, '    set bj_mapInitialCameraBounds = Rect(-7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5888.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5632.0 - GetCameraMargin(CAMERA_MARGIN_TOP))\n',
              '    set bj_mapInitialCameraBounds = Rect(-13440.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 12032.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 9728.0 - GetCameraMargin(CAMERA_MARGIN_TOP))\n')
punto = 'call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + 1, Title_X() + 1, Title_Y() + 1, Title_X() + 1, Title_Y() - 1)'
assert s.count(punto) == 3
s = s.replace(punto, 'call SetCameraBoundsToRect(bj_mapInitialCameraBounds)')
s = base.once(s, '        call SetCameraBounds(2399, 8699, 2399, 8701, 2401, 8701, 2401, 8699)\n', '        call SetCameraBoundsToRect(bj_mapInitialCameraBounds)\n')
s = base.once(s, 'real Title_CX= 0.\n', 'real Title_CX= 0.\nunit array Menu_Ancla\n')
s = base.once(s, """        call SetCameraField(CAMERA_FIELD_FARZ, 5000., 0)
        call SetCameraPosition(2400.0, 8700.0)
""", """        call SetCameraField(CAMERA_FIELD_FARZ, 5000., 0)
        call SetCameraTargetController(Menu_Ancla[1], 0., 0., false)
""")
s = base.once(s, """function Title_Camera takes nothing returns nothing
""", """// v14j: Title_Camera sólo corre en código sincronizado (temporizadores de la intro y el título).
function Title_Camera takes nothing returns nothing
    if Menu_Ancla[0] == null then
        set Menu_Ancla[0] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', Title_X(), Title_Y(), 0.)
    endif
""")
s = base.once(s, """    call SetCameraField(CAMERA_FIELD_FARZ, 5000., 0)
    call SetCameraPosition(Title_X(), Title_Y() + Title_PanY)
""", """    call SetCameraField(CAMERA_FIELD_FARZ, 5000., 0)
    call SetCameraTargetController(Menu_Ancla[0], 0., Title_PanY, false)
""")
s = base.once(s, '    set Title_CX = 2400.0\n', "    set Title_CX = 2400.0\n    set Menu_Ancla[1] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 2400., 8700., 0.)\n")
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
