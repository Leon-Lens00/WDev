#!/usr/bin/env python3
"""Objetos de v14zq (07/11/2026): destructible 'DS18' con la textura de la tarjeta de rachas
war3mapImported\\RachaCaja.blp (como las DS10..DS17) y su import.
Uso: objetos_v14zq.py DIR_ENTRADA DIR_SALIDA (w3b e imp del mapa v14zp)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DS18', 'RachaCaja')], ['war3mapImported\\RachaCaja.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
