#!/usr/bin/env python3
"""v19x (19/11/2026): iconos del juego (sin import) para las cartas de la linterna, copiados de la plantilla 'D000':
'DC0O' BTNShadowPact (Pacto de sombras), 'DC0P' BTNManaStone (Pilas reforzadas), 'DC0Q' BTNReplenishMana
(Recarga rápida).
Uso: objetos_v19x.py DIR_ENTRADA (w3b de v19w) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
crudo = (src / 'war3map.w3b').read_bytes()
version, tablas = parse(crudo)
assert encode(version, tablas) == crudo, 'w3b: ida y vuelta distinta'
plantilla = next(r for r in tablas[1] if r[1] == b'D000')
existentes = {r[1] for t in tablas for r in t}
for rid, btn in (('DC0O', 'BTNShadowPact'), ('DC0P', 'BTNManaStone'), ('DC0Q', 'BTNReplenishMana')):
    assert rid.encode() not in existentes, rid
    ruta = f'ReplaceableTextures\\CommandButtons\\{btn}.blp'.encode()
    mods = [(m, t, ruta if m == b'btxf' else btn.encode() if m == b'bnam' else v, rid.encode())
            for m, t, v, _ in plantilla[2]]
    tablas[1].append((plantilla[0], rid.encode(), mods))
(dst / 'war3map.w3b').write_bytes(encode(version, tablas))
print('w3b v19x: DC0O-DC0Q')
