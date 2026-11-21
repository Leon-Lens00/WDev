#!/usr/bin/env python3
"""Objetos de v14zn (07/11/2026): misil de calor en el botón C.
- war3map.w3a: Aw00 («Pistolas») pasa a «Misiles»: icono war3mapImported\\BTNMisil.blp y, por nivel, el nombre
  «<misil> T<n> (C)» y la descripción «Activa esta arma. <rasgo>.» de v14zn.py. Lo demás (tecla, posición, orden) igual.
- war3map.w3b / war3map.imp: destructible 'DS17' con la foto war3mapImported\\Arma-misil.blp (como las DS10..DS16) e
  imports de Arma-misil.blp, BTNMisil.blp e InterceptorShell1..6.mdx.
Uso: objetos_v14zn.py DIR_ENTRADA DIR_SALIDA (w3a, w3b e imp del mapa v14zm)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
import w3b_modos
from v14zn_datos import MISILES, rasgo

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
assert parse_w3a(encode_w3a(version, tablas)) == (version, tablas)
n = next(k for k, f in enumerate(tablas[1]) if f[1] == b'Aw00')
f = tablas[1][n]
mods, vistos = [], set()
for mid, typ, lvl, data, val, end in f[2]:
    if mid == b'anam':
        assert val == b'Pistolas', val
        val = b'Misiles'
    elif mid == b'aart':
        assert val == b'war3mapImported\\BTNArma0.blp', val
        val = b'war3mapImported\\BTNMisil.blp'
    elif mid == b'atp1':
        assert val.endswith(b'T%d (|cffffcc00C|r)' % lvl), val
        val = ('%s T%d (|cffffcc00C|r)' % (MISILES[lvl - 1][0], lvl)).encode()
    elif mid == b'aub1':
        val = ('Activa esta arma. %s.' % rasgo(lvl - 1)).encode()
    vistos.add((mid, lvl))
    mods.append((mid, typ, lvl, data, val, end))
assert {(b'atp1', t) for t in range(1, 7)} | {(b'aub1', t) for t in range(1, 7)} <= vistos
tablas[1][n] = (f[0], f[1], mods)
(dst / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))
imports = ['war3mapImported\\Arma-misil.blp', 'war3mapImported\\BTNMisil.blp'] + \
          ['war3mapImported\\InterceptorShell%d.mdx' % t for t in range(1, 7)]
w3b_modos.add([('DS17', 'Arma-misil')], imports,
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
