#!/usr/bin/env python3
"""v18n (15/11/2026): Leon, "a eso restale 2 segundos para que suene algo antes": el recuento de bolsas empieza 2 s
antes del final del sonido de misión completada (Punt_Ini[1] 5,45 -> 3,45 s; el resto se encadena igual).
Prueba: registros v18m -> v18n.  Uso: v18n.py ENTRADA.j SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
viejo = '    set Punt_Ini[1] = 5.45'
assert src.count(viejo) == 1
src = src.replace(viejo, '    set Punt_Ini[1] = 3.45 // v18n: 2 s antes del final de QuestCompleted.wav')
if len(sys.argv) > 3 and sys.argv[3] == 'prueba':
    assert src.count('lat\\\\v18m-') == 4
    src = src.replace('lat\\\\v18m-', 'lat\\\\v18n-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
