#!/usr/bin/env python3
"""v14zx (07/11/2026): la noche (Variante 2) es la hora predeterminada al entrar a la partida; antes era la tarde (1).
Mapa para jugar con amigos: sin registros, sin atajos de prueba.
Uso: v14zx.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'integer Variante= 1\n', 'integer Variante= 2\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('ok', len(s))
