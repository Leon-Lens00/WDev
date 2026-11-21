#!/usr/bin/env python3
"""v19v (19/11/2026): cartas de Mutación Evo con la ventana de la tienda.
- w3b: 'DS1V' CuaMutCarta (270 × 250) y 'DS1W' CuaMutDes (270 × 130), de texturas_v19v.py, con sus imports.
Uso: objetos_v19v.py DIR_ENTRADA (w3b e imp de v19u) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DS1V', 'CuaMutCarta'), ('DS1W', 'CuaMutDes')],
              ['war3mapImported\\CuaMutCarta.blp', 'war3mapImported\\CuaMutDes.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
print('w3b v19v: DS1V DS1W; imp +2')
