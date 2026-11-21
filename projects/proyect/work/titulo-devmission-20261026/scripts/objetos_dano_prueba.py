#!/usr/bin/env python3
"""Sólo prueba (v14l-dano, 05/11/2026): una unidad por ranura de armadura, sin defensa, para medir la tabla pura.

'nda0'..'nda7' son copias de 'nmcf' con udef 0, 1000 de vida y la udty de cada ranura, en el orden de las columnas
de DamageBonus*: small, medium, large, fort, normal, hero, divine, none (Ágil, Acorazada, Caparazón, Pétrea, Jugador,
Colosal, Escudo, Orgánica). Falla si algún id ya existe. NO integrar.

Uso: objetos_dano_prueba.py IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

RANURAS = ['small', 'medium', 'large', 'fort', 'normal', 'hero', 'divine', 'none']
src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
usados = {new for t in tables for _, new, _ in t}
Z = b'\0\0\0\0'
for k, udty in enumerate(RANURAS):
    rid = f'nda{k}'.encode()
    assert rid not in usados, rid
    tables[1].append((b'nmcf', rid, [(b'unam', 3, f'Prueba {udty}'.encode(), Z), (b'udty', 3, udty.encode(), Z),
                                      (b'udef', 0, struct.pack('<i', 0), Z), (b'uhpm', 0, struct.pack('<i', 1000), Z)]))
Path(sys.argv[2]).write_bytes(encode(version, tables))
print('ok', len(RANURAS), 'unidades de prueba')
