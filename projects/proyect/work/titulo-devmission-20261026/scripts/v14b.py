#!/usr/bin/env python3
"""v14b: más tiempo de compra. Descanso de 30 s y la tienda abierta lo detiene hasta 120 s.

Uso: v14b.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys
S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'constant integer Ronda_DESCANSO = 10', 'constant integer Ronda_DESCANSO = 30')
s = base.once(s, 'hasta 60 s por descanso.', 'hasta 120 s por descanso.')
s = base.once(s, 'Shop_Pausa < 60 then', 'Shop_Pausa < 120 then')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
