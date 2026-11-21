#!/usr/bin/env python3
"""Sólo prueba, v14zr: las mismas de prueba_v14zq.py, con el registro en lat\\v14zr-N.txt.
Uso: prueba_v14zr.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sal = sys.argv[2]
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v14zq.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
n = s.count('lat\\\\v14zq-')
assert n == 4, n
Path(sal).write_text(s.replace('lat\\\\v14zq-', 'lat\\\\v14zr-'), encoding='latin-1', newline='')
