#!/usr/bin/env python3
"""v19a (18/11/2026): copia espiritual del Tauren y su primera habilidad, Embestida espiritual.

Leon (18/11/2026): al lanzar una habilidad se crea una copia dummy invulnerable del personaje y es ella la que hace
la habilidad; el héroe sigue libre.
- w3u 'hCp0' "Copia espiritual (Tauren)": base 'otau' (unidad normal, no héroe, para que no salga en la barra de
  héroes), modelo y escala de 'h005' (Tauren.mdl, 1,1). Aloc + Avul, sin colisión, sin comida, sin ataque, sin
  recompensa, oculta en el minimapa, visión mínima.
- w3a 'ATb1' "Embestida espiritual": 'ANcl' de punto como los puentes de D.O.N (alcance 90000, lanzamiento 0, 1 de
  maná, sin enfriamiento), orden "blizzard", casilla (0,0) tecla Q, icono BTNSpiritWalker.
- w3a 'ALTb': libro propio del Tauren (como 'ALTa', casilla (3,2), tecla V) con 'ATb1' y los dos iconos sin efecto de v18k
  ('ATa1' Onda de choque W, 'ATa2' Pisotón E), como 'ALTa', que sigue para Cairne.
Uso: objetos_v19a.py DIR_ENTRADA (w3a y w3u de v18z) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')

# --- w3a ---
b = (src / 'war3map.w3a').read_bytes()
version, tablas = parse_w3a(b)
assert encode_w3a(version, tablas) == b
usados = {r[1] for t in tablas for r in t}
for rid in (b'ATb1', b'ALTb'):
    assert rid not in usados, rid
desc = ('Una copia espiritual del Tauren aparece a su lado y carga hasta el punto (350 a 1000): daña 300 y aparta a '
        'cada enemigo que atraviesa, y al final golpea el suelo (500 en 260). El Tauren sigue libre: no se para ni '
        'se arriesga.')
tablas[1].append((b'ANcl', b'ATb1', [
    (b'anam', 3, 0, 0, S('Tauren: Embestida espiritual'), Z),
    (b'aher', 0, 0, 0, I(0), Z), (b'alev', 0, 0, 0, I(1), Z),
    (b'ahky', 3, 0, 0, b'Q', Z),
    (b'aart', 3, 0, 0, S('ReplaceableTextures\\CommandButtons\\BTNSpiritWalker.blp'), Z),
    (b'atp1', 3, 1, 0, S('Embestida espiritual (|cffffcc00Q|r)'), Z),
    (b'aub1', 3, 1, 0, S(desc), Z),
    (b'aran', 2, 1, 0, R(90000.), Z), (b'acdn', 2, 1, 0, R(0.), Z), (b'amcs', 0, 1, 0, I(1), Z),
    (b'acas', 2, 1, 0, R(0.), Z),
    (b'Ncl1', 2, 1, 1, R(0.), Z), (b'Ncl2', 0, 1, 2, I(2), Z), (b'Ncl3', 0, 1, 3, I(1), Z),
    (b'Ncl4', 2, 1, 4, R(0.), Z), (b'Ncl5', 0, 1, 5, I(0), Z), (b'Ncl6', 3, 1, 6, b'blizzard', Z),
    (b'abpx', 0, 0, 0, I(0), Z), (b'abpy', 0, 0, 0, I(0), Z),
    (b'aeat', 3, 0, 0, b'', Z), (b'atat', 3, 0, 0, b'', Z), (b'acat', 3, 0, 0, b'', Z)]))
tablas[1].append((b'Aspb', b'ALTb', [
    (b'anam', 3, 0, 0, S('Tauren: libro de habilidades'), Z),
    (b'aart', 3, 0, 0, S('ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp'), Z),
    (b'abpx', 0, 0, 0, I(3), Z), (b'abpy', 0, 0, 0, I(2), Z),
    (b'ahky', 3, 0, 0, b'V', Z),
    (b'atp1', 3, 1, 0, S('Habilidades especiales (|cffffcc00V|r)'), Z),
    (b'aub1', 3, 1, 0, S('Abre las habilidades especiales del Tauren.'), Z),
    (b'spb1', 3, 1, 1, b'ATb1,ATa1,ATa2', Z),
    (b'spb2', 0, 1, 2, I(0), Z), (b'spb3', 0, 1, 3, I(1), Z), (b'spb4', 0, 1, 4, I(1), Z),
    (b'spb5', 3, 1, 5, b'spellbook', Z)]))
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
(dst / 'war3map.w3a').write_bytes(salida)

# --- w3u ---
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
ids = {r[1] for t in tablas for r in t}
assert b'hCp0' not in ids
tauren = next(r for r in tablas[1] if r[1] == b'h005')
d = {m[0]: m for m in tauren[2]}
assert d[b'umdl'][2] == b'units\\orc\\Tauren\\Tauren.mdl'
F = lambda k, t, v: (k, t, v, Z)
tablas[1].append((b'otau', b'hCp0', [
    F(b'unam', 3, S('Copia espiritual (Tauren)')),
    F(b'umdl', 3, d[b'umdl'][2]), F(b'usca', 1, d[b'usca'][2]),
    F(b'uabi', 3, b'Aloc,Avul'),
    F(b'ucol', 2, R(0.)), F(b'ufoo', 0, I(0)), F(b'uaen', 0, I(0)),
    F(b'ubba', 0, I(0)), F(b'ubdi', 0, I(0)), F(b'ubsi', 0, I(0)),
    F(b'uhom', 0, I(1)), F(b'usid', 0, I(200)), F(b'usin', 0, I(200)),
    F(b'upoi', 0, I(0)), F(b'umvr', 2, R(3.))]))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3a v19a: ATb1, ALTb; w3u: hCp0')
