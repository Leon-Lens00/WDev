#!/usr/bin/env python3
"""Sólo prueba, v16d: las notas del tutorial de prueba_v16a.py, en lat\\v16d-1.txt. Uso: prueba_v16d.py ENTRADA.j SALIDA.j"""
from pathlib import Path
import subprocess, sys
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v16a.py')] + sys.argv[1:3], check=True)
s = Path(sys.argv[2]).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v16a-') == 1
Path(sys.argv[2]).write_text(s.replace('lat\\\\v16a-', 'lat\\\\v16d-'), encoding='latin-1', newline='')
