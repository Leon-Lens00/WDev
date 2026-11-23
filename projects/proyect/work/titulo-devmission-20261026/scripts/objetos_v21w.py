#!/usr/bin/env python3
"""v21w (22/11/2026): el botón ATr1 (Power Up de Trunks) usa el icono de D.O.N 2.1a ya importado
(war3mapImported\\BTNPowerupTrunks.blp) en lugar de BTNReincarnation.
Uso: objetos_v21w.py ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

ver, tabs = parse_w3a(Path(sys.argv[1]).read_bytes())
hecho = 0
for t in tabs:
    for k, (base, nid, mods) in enumerate(t):
        if nid != b'ATr1':
            continue
        for i, m in enumerate(mods):
            if m[0] == b'aart':
                assert m[4] == b'ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp', m
                mods[i] = m[:4] + (b'war3mapImported\\BTNPowerupTrunks.blp',) + m[5:]
                hecho += 1
        t[k] = (base, nid, mods)
assert hecho == 1, hecho
Path(sys.argv[2]).write_bytes(encode_w3a(ver, tabs))
print('v21w: icono de ATr1')
