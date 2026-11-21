#!/usr/bin/env python3
"""v18f (15/11/2026): destructibles 'DSE0'..'DSE7' con las texturas de las 8 etiquetas fijas de la tienda
(etiquetas_v18f.py: war3mapImported\\TiendaEt0..7.blp) y sus imports. Sólo cambian w3b e imp.
Uso: objetos_v18f.py DIR_ENTRADA (w3b, imp de v18e) DIR_SALIDA DIR_ETIQUETAS
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

src, dst, et = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
dst.mkdir(exist_ok=True)
E = json.loads((et / 'etiquetas.json').read_text())['etiquetas']
w3b_modos.add([(e['id'], e['nombre']) for e in E], [f"war3mapImported\\{e['nombre']}.blp" for e in E],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
