#!/usr/bin/env python3
"""Reserva del reciclador de balas (14/11/2026): 8 sectores × 32 = 256 unidades precargadas.

Leon: "nos hace falta configurar bien las reservas entonces" y "Sí, aplicarla" tras la prueba reserva-v16t (240 enemigos,
8 MP5: sin reserva 43 fps, 8 × 12 49 y se agota si todos disparan al mismo lado, 8 × 32 53,5 y ninguna unidad nueva).
- Recupera la precarga original de MissileRecycler___Init (el bloque de v13e, que v13g quitó) y el configure de
  MissileStats con ANG_N × ANG_STORAGE_MAX.
- ANG_STORAGE_MAX 12 → 32. DEATH_TIME no cambia (0,3).
Uso: reserva32.py ENTRADA.j V13E.j SALIDA.j
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
v13e = Path(sys.argv[2]).read_text(encoding='latin-1', newline='')
ini = v13e.index('function MissileRecycler___Init takes nothing returns nothing')
a = v13e.index('            call s__MissileStats_configure(', ini)
b = v13e.index('        call TimerStart(MissileRecycler___gameTime', a)
bloque = v13e[a:b]
assert bloque.count('CreateUnit(') == 1 and 'exitwhen n == end' in bloque
ini = s.index('function MissileRecycler___Init takes nothing returns nothing')
a = s.index('            call s__MissileStats_configure(0)\r\n', ini)
b = s.index('        call TimerStart(MissileRecycler___gameTime', a)
assert b - a < 80, s[a:b]
s = s[:a] + bloque + s[b:]
viejo = 'constant integer MissileRecycler___ANG_STORAGE_MAX= 12\r\n'
assert s.count(viejo) == 1
s = s.replace(viejo, 'constant integer MissileRecycler___ANG_STORAGE_MAX= 32\r\n')
assert s.count('constant real MissileRecycler___DEATH_TIME= 0.3\r\n') == 1
Path(sys.argv[3]).write_text(s, encoding='latin-1', newline='')
print('reserva: 8 x 32 = 256 balas precargadas')
