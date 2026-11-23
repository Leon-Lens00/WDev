#!/usr/bin/env python3
"""v21o (22/11/2026): corrige dos filas de objetos_fz21.py (v21n) vistas en el registro de v21n-prueba.

- A0OH Golden Form (ANcr): el cuerpo hFrz deriva de Hmgd, que es héroe; la duración del efecto es ahdu (35, de 2.1a) y
  adur es el tiempo de la transformación (0,35 por defecto). v21n puso adur 35: la transformación no acababa y la
  orden de parar del código, al segundo, la cancelaba (registro: bono a 118,0 s, fin a 119,1 s, sin cambio de tipo).
  Se quitan las filas adur.
- A0JD Imprisonment Ball (AUim): el nivel 1 venía con objetivos "none"; la copia aceptaba la orden y la soltaba sin
  lanzar (registro: tres pulsaciones de W sin CHANNEL de la copia). El nivel 1 pasa a los objetivos de los niveles 2-4.
Uso: objetos_v21o.py ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

ver, tabs = parse_w3a(Path(sys.argv[1]).read_bytes())
hecho = set()
for t in tabs:
    for k, (base, nid, mods) in enumerate(t):
        if nid == b'A0OH':
            n = len(mods)
            mods = [m for m in mods if m[0] != b'adur']
            assert n - len(mods) == 3, n - len(mods)
            assert any(m[0] == b'ahdu' for m in mods)
            hecho.add(nid)
        elif nid == b'A0JD':
            otros = {m[4] for m in mods if m[0] == b'atar' and m[2] in (2, 3, 4)}
            assert len(otros) == 1, otros
            uno = [i for i, m in enumerate(mods) if m[0] == b'atar' and m[2] == 1]
            assert len(uno) == 1 and mods[uno[0]][4] == b'none', uno
            m = mods[uno[0]]
            mods[uno[0]] = m[:4] + (otros.pop(),) + m[5:]
            hecho.add(nid)
        t[k] = (base, nid, mods)
assert hecho == {b'A0OH', b'A0JD'}, hecho
Path(sys.argv[2]).write_bytes(encode_w3a(ver, tabs))
print('v21o: A0OH sin adur; A0JD nivel 1 con objetivos')
