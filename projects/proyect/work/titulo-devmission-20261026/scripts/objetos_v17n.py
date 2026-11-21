#!/usr/bin/env python3
"""Vida de las oleadas ×2, v17n (14/11/2026).

Leon: "como nuestras armas son fuertes tambien necesitamos ajustar la vidas de las unidades y boss y elites un adicional
mas, y no caigan tan rapida como de un solo disparo". 'uhpm' × 2 en los 10 tipos de oleada, las 10 élites 'ne0k' y los
9 jefes 'nj0n' (la mejora de vida de jefe por jugador 'Rdjv' es en porcentaje y sigue igual).
Uso: objetos_v17n.py IN_W3U OUT_W3U
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

F = 2
TIPOS = ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd']
IDS = set(TIPOS) | {f'ne0{k}' for k in range(10)} | {f'nj0{c}' for c in '23456789A'}

src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src
hechos = {}
for tab in tables:
    for i, (base, new, mods) in enumerate(tab):
        rid = (new if new != b'\0\0\0\0' else base).decode('latin-1')
        if rid not in IDS:
            continue
        nuevos = []
        for mid, ty, v, end in mods:
            if mid == b'uhpm':
                assert ty == 0
                antes = struct.unpack('<i', v)[0]
                v = struct.pack('<i', antes * F)
                hechos[rid] = [antes, antes * F]
            nuevos.append((mid, ty, v, end))
        tab[i] = (base, new, nuevos)
assert set(hechos) == IDS, sorted(IDS - set(hechos))
Path(sys.argv[2]).write_bytes(encode(version, tables))
print(json.dumps(hechos))
