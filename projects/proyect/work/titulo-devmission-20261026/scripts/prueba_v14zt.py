#!/usr/bin/env python3
"""Sólo prueba, v14zt: las de prueba_v14zs.py, con el registro en lat\\v14zt-N.txt.
Uso: prueba_v14zt.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sal = sys.argv[2]
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v14zs.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
n = s.count('lat\\\\v14zs-')
assert n == 4, n
Path(sal).write_text(s.replace('lat\\\\v14zs-', 'lat\\\\v14zt-'), encoding='latin-1', newline='')
