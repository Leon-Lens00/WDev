#!/usr/bin/env python3
"""v17q (14/11/2026): cabecera HM3W del w3x con el nombre del mapa y las marcas de v17p.

Leon tras ver v17p en la sala: "dentro de la seccion de mapa sale el nombre anterior en los mapa pero ya se muestra la
correcta en el mapa". La lista de mapas lee el nombre de la cabecera HM3W (512 bytes antes del MPQ), no del w3i.
- nombre "Swamped Temple_v2" -> "Proyect Dev Us";
- marcas |= 0x20 (ajustes de jugador fijos) | 0x40 (fuerzas propias), como el w3i desde v17p; jugadores 8 igual.
El MPQ desde el byte 512 no cambia. Uso: cabecera_v17q.py ENTRADA.w3x SALIDA.w3x
"""
from pathlib import Path
import struct, sys

d = Path(sys.argv[1]).read_bytes()
assert d[:4] == b'HM3W' and d[512:516] == b'MPQ\x1a'
n = d.index(b'\0', 8)
assert d[8:n] == b'Swamped Temple_v2', d[8:n]
marcas, jugadores = struct.unpack('<II', d[n + 1:n + 9])
assert marcas == 0x1fc18 and jugadores == 8 and not any(d[n + 9:512])
cab = d[:8] + b'Proyect Dev Us\0' + struct.pack('<II', marcas | 0x60, jugadores)
cab += bytes(512 - len(cab))
Path(sys.argv[2]).write_bytes(cab + d[512:])
print(hex(marcas | 0x60))
