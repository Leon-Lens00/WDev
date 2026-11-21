#!/usr/bin/env python3
"""Sólo prueba (13/11/2026): el fusil de asalto con el modelo y el radio de bala del subfusil (Shot II).
Leon: "ponle a la scar el modelo de la mp5 y veamos que pasa". El francotirador sigue con Daemonic Arrow.
Uso: scar_shot2.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
a = b'    elseif c == 1 then\r\n        set Arm_BalaModelo = "ShotsAjustados\\\\Shot II "'
b = b'    elseif c == 1 or c == 2 then\r\n        // prueba: fusil de asalto con el modelo del subfusil\r\n        set Arm_BalaModelo = "ShotsAjustados\\\\Shot II "'
assert j.count(a) == 1
j = j.replace(a, b)
Path(sys.argv[2]).write_bytes(j)
print('scar con Shot II')
