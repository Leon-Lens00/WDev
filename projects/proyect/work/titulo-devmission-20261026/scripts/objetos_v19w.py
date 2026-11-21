#!/usr/bin/env python3
"""v19w (19/11/2026): dash por cargas.
- w3a 'Ard1': sin coste de maná (amcs 1 -> 0) y texto de cargas.
- w3b: iconos del juego (sin import) para las 4 mejoras del dash y el HUD, copiados de la plantilla 'D000':
  'DC0K' BTNBlink (Impulso extra), 'DC0L' BTNWindWalkOn (Enfriamiento), 'DC0M' BTNSlippersOfAgility (Dash largo),
  'DC0N' BTNBootsOfSpeed (Dash veloz e icono del dash en el HUD).
Uso: objetos_v19w.py DIR_ENTRADA (w3a y w3b de v19v) DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)

# --- w3a ---
crudo = (src / 'war3map.w3a').read_bytes()
version, tablas = parse_w3a(crudo)
assert encode_w3a(version, tablas) == crudo, 'w3a: ida y vuelta distinta'
TEXTO = ('Avanza 450 en 0.375 s hacia el punto elegido. Cancela disparo rápido y recarga. '
         'Sin maná: 2 cargas, que vuelven de una en una cada 6 s.')
n = 0
for t in tablas:
    for i, (base, nuevo, mods) in enumerate(t):
        if nuevo == b'Ard1':
            nm = []
            for m in mods:
                if m[0] == b'amcs':
                    assert m[4] == (1).to_bytes(4, 'little')
                    m = (m[0], m[1], m[2], m[3], (0).to_bytes(4, 'little'), m[5])
                elif m[0] == b'aub1':
                    m = (m[0], m[1], m[2], m[3], TEXTO.encode('utf-8'), m[5])
                nm.append(m)
            t[i] = (base, nuevo, nm)
            n += 1
assert n == 1
(dst / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))

# --- w3b ---
crudo = (src / 'war3map.w3b').read_bytes()
version, tablas = parse(crudo)
assert encode(version, tablas) == crudo, 'w3b: ida y vuelta distinta'
plantilla = next(r for r in tablas[1] if r[1] == b'D000')
existentes = {r[1] for t in tablas for r in t}
for rid, btn in (('DC0K', 'BTNBlink'), ('DC0L', 'BTNWindWalkOn'), ('DC0M', 'BTNSlippersOfAgility'),
                 ('DC0N', 'BTNBootsOfSpeed')):
    assert rid.encode() not in existentes, rid
    ruta = f'ReplaceableTextures\\CommandButtons\\{btn}.blp'.encode()
    mods = [(m, t, ruta if m == b'btxf' else btn.encode() if m == b'bnam' else v, rid.encode())
            for m, t, v, _ in plantilla[2]]
    tablas[1].append((plantilla[0], rid.encode(), mods))
(dst / 'war3map.w3b').write_bytes(encode(version, tablas))
print('w3a v19w: Ard1 sin maná; w3b DC0K-DC0N')
