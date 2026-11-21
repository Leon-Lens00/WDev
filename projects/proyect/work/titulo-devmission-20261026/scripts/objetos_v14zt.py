#!/usr/bin/env python3
"""Objetos de v14zt (07/11/2026): destructible 'DS19' con la textura del marco del retrato de las rachas
war3mapImported\\RachaMarco.blp y su import. RachaCaja.blp ya está importada ('DS18'); sólo cambia el archivo.
Uso: objetos_v14zt.py DIR_ENTRADA DIR_SALIDA (w3b e imp del mapa v14zs)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DS19', 'RachaMarco')], ['war3mapImported\\RachaMarco.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
