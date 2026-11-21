#!/usr/bin/env python3
"""v14zr (07/11/2026): textos de la tarjeta de rachas más abajo, según las capturas de Leon de v14zq (el nombre tocaba el
borde de arriba y la racha iba pegada a la línea): nombre 6 px y racha 8 px más abajo (lo de «-ajuste 0 0 1 6 8»).
Uso: v14zr.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '( y - 24. + Racha_AjN )', '( y - 18. + Racha_AjN )')
s = base.once(s, '( y + 1. + Racha_AjL )', '( y + 9. + Racha_AjL )')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
