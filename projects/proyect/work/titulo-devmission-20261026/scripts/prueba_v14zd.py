#!/usr/bin/env python3
"""Sólo prueba, v14zd: la de v14zc (prueba_v14zc.py) con el registro en lat\\v14zd-N.txt. Los Luz1..10.mdx que importa
v14zd llevan la secuencia Death que apaga la luz al destruirla (luz_variantes_muerte.cjs).
Uso: prueba_v14zd.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

sal = sys.argv[2]
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v14zc.py'), *sys.argv[1:]], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call PreloadGenEnd("lat\\\\v14zc-"', 'call PreloadGenEnd("lat\\\\v14zd-"')
Path(sal).write_text(s, encoding='latin-1', newline='')
