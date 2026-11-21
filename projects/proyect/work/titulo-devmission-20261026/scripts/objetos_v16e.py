#!/usr/bin/env python3
"""Objetos de v16e (08/11/2026): 'DS1O' TutCargar, icono de Recarga (F) para la consola del tutorial, con la textura
del juego ReplaceableTextures\\CommandButtons\\BTNLoad.blp (la del botón real Aw08). No añade imports.
Uso: objetos_v16e.py DIR_ENTRADA DIR_SALIDA (war3map.w3b y war3map.imp del mapa v16d; sólo escribe war3map.w3b)
"""
from pathlib import Path
import sys, tempfile
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory() as tmp:
    imp = Path(tmp) / 'war3map.imp'
    w3b_modos.add([('DS1O', 'TutCargar')], [], ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', imp])
    assert imp.read_bytes() == (src / 'war3map.imp').read_bytes()
version, tablas = parse((dst / 'war3map.w3b').read_bytes())
n = 0
for i, (base, nuevo, mods) in enumerate(tablas[1]):
    if nuevo == b'DS1O':
        tablas[1][i] = (base, nuevo, [(m, t, b'ReplaceableTextures\\CommandButtons\\BTNLoad.blp' if m == b'btxf' else v, o)
                                      for m, t, v, o in mods])
        n += 1
assert n == 1
(dst / 'war3map.w3b').write_bytes(encode(version, tablas))
print('DS1O -> BTNLoad')
