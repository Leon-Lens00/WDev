#!/usr/bin/env python3
"""Barras de vida de los jefes de ronda, v17m (14/11/2026).

Cada barra es HealthEnemyTauren.mdx (la barra derecha del HUD, con su marco y su icono) con la textura del icono cambiada
por la del jefe de la ronda n, la misma que usa su JefeIcono{n}.mdx: el campo de ruta de textura del MDX mide 260 bytes
y se rellena con ceros, así que el modelo no cambia de tamaño.
Uso: jefe_barras_v17m.py HealthEnemyTauren.mdx DIR_CON_JefeIcono{n}.mdx SALIDA_DIR
"""
from pathlib import Path
import re, sys

RONDAS = '23456789A'
VIEJA = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'

base = Path(sys.argv[1]).read_bytes()
assert base.count(VIEJA) == 1
i = base.index(VIEJA)
assert base[i + len(VIEJA):i + 260] == bytes(260 - len(VIEJA)), 'el campo no es de 260 bytes con ceros'
out = Path(sys.argv[3]); out.mkdir(parents=True, exist_ok=True)
for c in RONDAS:
    icono = Path(sys.argv[2], f'JefeIcono{c}.mdx').read_bytes()
    m = re.findall(rb'ReplaceableTextures\\CommandButtons\\BTN[A-Za-z]+\.blp', icono)
    assert len(m) == 1, (c, m)
    nueva = m[0]
    mdx = base[:i] + nueva + bytes(260 - len(nueva)) + base[i + 260:]
    assert len(mdx) == len(base)
    (out / f'HealthJefe{c}.mdx').write_bytes(mdx)
    print(c, nueva.decode())
