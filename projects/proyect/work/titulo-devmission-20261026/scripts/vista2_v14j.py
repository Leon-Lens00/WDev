#!/usr/bin/env python3
"""Prueba de la idea del usuario (04/11/2026): límites de cámara de la partida más altos, con la franja de arriba bajo la
máscara negra, para ver si esa parte del minimapa deja de verse. Sólo para mapas de prueba; parte de v14j-vista.
Uso: vista2_v14j.py ENTRADA.j SALIDA.j XMIN XMAX YMAX
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, x0, x1, y1 = sys.argv[1:6]
s = Path(ent).read_text(encoding='latin-1', newline='')
s = base.once(s, '    set bj_mapInitialCameraBounds = Rect(-7296.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5888.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5632.0 - GetCameraMargin(CAMERA_MARGIN_TOP))\n',
              f'    set bj_mapInitialCameraBounds = Rect({x0} + GetCameraMargin(CAMERA_MARGIN_LEFT), -7296.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), {x1} - GetCameraMargin(CAMERA_MARGIN_RIGHT), {y1} - GetCameraMargin(CAMERA_MARGIN_TOP))\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
