#!/usr/bin/env python3
"""v14zu (07/11/2026): en v14zt el retrato aún asomaba por la izquierda del marco. Marco de 80 × 56 px (antes 66) con la
misma ventana de 48 × 44 (RachaMarco y RachaCaja de tarjeta_v14zu.py), retrato y marco centrados en cx + 163 (antes
170,6) y texto centrado en cx − 44,4 (antes 36,4).
Uso: v14zu.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, "Racha_Foto(Racha_Marco[p * 5 + i] , 66. , 56. , 'DS19')", "Racha_Foto(Racha_Marco[p * 5 + i] , 80. , 56. , 'DS19')")
assert s.count('cx + 170.6') == 2 and s.count('( cx - 36.4 - ') == 2
s = s.replace('cx + 170.6', 'cx + 163.').replace('( cx - 36.4 - ', '( cx - 44.4 - ')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
