#!/usr/bin/env python3
"""Sólo prueba, v14zs: las de prueba_v14zq.py, con el registro en lat\\v14zs-N.txt; «-rachas» describe las 5 tarjetas
con su hueco (0 arriba izquierda, 1 arriba derecha, 2 abajo izquierda, 3 abajo derecha).
Uso: prueba_v14zs.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

sal = sys.argv[2]
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v14zq.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
n = s.count('lat\\\\v14zq-')
assert n == 4, n
s = s.replace('lat\\\\v14zq-', 'lat\\\\v14zs-')
s = base.once(s, '" tarjetas" + Prueba_Tarjeta(0) + Prueba_Tarjeta(1) +',
              '" tarjetas" + Prueba_Tarjeta(0) + Prueba_Tarjeta(1) + Prueba_Tarjeta(2) + Prueba_Tarjeta(3) + Prueba_Tarjeta(4) +')
s = base.once(s, 'return " [" + I2S(k) + " activa "', 'return " [" + I2S(k) + " hueco " + I2S(Racha_CHueco[k]) + " activa "')
Path(sal).write_text(s, encoding='latin-1', newline='')
