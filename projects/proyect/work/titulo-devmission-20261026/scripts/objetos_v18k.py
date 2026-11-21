#!/usr/bin/env python3
"""v18k (15/11/2026), fase 6: libro de habilidades del controlador (w3a).

Leon (15/11/2026): las 6 habilidades de D.O.N de Goku, Freezer, Trunks y Naruto pasan dentro del libro y siguen
funcionando; el libro del Tauren lleva Onda de choque y Pisotón de guerra como iconos sin efecto.
- 'ALGk', 'ALFz', 'ALTr', 'ALNa', 'ALTa': 'Aspb' (libro de hechizos) en la casilla (3,2), tecla V, icono
  BTNSpellBookBLS, sin enfriamiento compartido; la lista son los puentes de cada héroe (AGk1..5, AFz1..6, ATr1..6,
  ANa1..6) o los dos iconos del Tauren. Orden base "spellbook": cada controlador lleva un solo libro.
- Dentro del libro la casilla (3,2) es la de cerrar: el último puente (AGk5, AFz6, ATr6, ANa6), que estaba ahí, pasa
  a (0,0) con tecla Q (también en su descripción). Los demás siguen en (1,0), (2,0), (3,0), (1,2), (2,2).
- 'ATa1' Onda de choque y 'ATa2' Pisotón de guerra: copias de 'ACev' (evasión de criaturas, pasiva) con 0 % de
  evasión y el icono de la habilidad del Tauren (BTNShockWave, BTNWarStomp): se ven, no hacen nada y no interrumpen
  la orden del controlador (un canal sí lo haría al pulsarlo).
Uso: objetos_v18k.py IN_W3A OUT_W3A
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')
src = Path(sys.argv[1]).read_bytes()
version, tablas = parse_w3a(src)
assert encode_w3a(version, tablas) == src
A = {r[1]: r for r in tablas[1]}
usados = {r[1] for t in tablas for r in t}

# Último puente de cada héroe: de (3,2) a (0,0), tecla Q.
for bid in (b'AGk5', b'AFz6', b'ATr6', b'ANa6'):
    base, new, mods = A[bid]
    d = {m[0]: m for m in mods}
    assert struct.unpack('<i', d[b'abpx'][4])[0] == 3 and struct.unpack('<i', d[b'abpy'][4])[0] == 2, bid
    assert d[b'ahky'][4] == b'T' and b'(|cffffcc00T|r)' in d[b'atp1'][4], bid
    cambio = {b'abpx': I(0), b'abpy': I(0), b'ahky': b'Q', b'atp1': d[b'atp1'][4].replace(b'|cffffcc00T|r', b'|cffffcc00Q|r')}
    mods = [(m[0], m[1], m[2], m[3], cambio.get(m[0], m[4]), m[5]) for m in mods]
    i = tablas[1].index(A[bid]); tablas[1][i] = (base, new, mods); A[bid] = tablas[1][i]

# Iconos del Tauren (pasivas sin efecto).
ICONOS = [('ATa1', 'Onda de choque', 'BTNShockWave', 1, 0, 'E',
           'Cairne lanza una onda de fuerza en línea recta que daña a los enemigos a su paso.'),
          ('ATa2', 'Pisotón de guerra', 'BTNWarStomp', 2, 0, 'W',
           'Cairne golpea el suelo y aturde y daña a los enemigos cercanos.')]
for rid, nom, ico, x, y, tecla, desc in ICONOS:
    assert rid.encode() not in usados, rid
    mods = [(b'anam', 3, 0, 0, S(f'Tauren: {nom}'), Z),
            (b'aart', 3, 0, 0, S(f'ReplaceableTextures\\CommandButtons\\{ico}.blp'), Z),
            (b'abpx', 0, 0, 0, I(x), Z), (b'abpy', 0, 0, 0, I(y), Z),
            (b'atp1', 3, 1, 0, S(nom), Z),
            (b'aub1', 3, 1, 0, S(desc + '|n|n|cff808080Sólo el icono por ahora: todavía no tiene efecto.|r'), Z),
            (b'Eev1', 2, 1, 1, R(0.), Z)]
    tablas[1].append((b'ACev', rid.encode(), mods)); usados.add(rid.encode())

LIBROS = [('ALGk', 'Goku', [f'AGk{k}' for k in range(1, 6)]),
          ('ALFz', 'Freezer', [f'AFz{k}' for k in range(1, 7)]),
          ('ALTr', 'Future Trunks', [f'ATr{k}' for k in range(1, 7)]),
          ('ALNa', 'Naruto', [f'ANa{k}' for k in range(1, 7)]),
          ('ALTa', 'Tauren', ['ATa1', 'ATa2'])]
for rid, quien, lista in LIBROS:
    assert rid.encode() not in usados, rid
    assert all(x.encode() in usados for x in lista), lista
    n = len(lista)
    mods = [(b'anam', 3, 0, 0, S(f'{quien}: libro de habilidades'), Z),
            (b'aart', 3, 0, 0, S('ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp'), Z),
            (b'abpx', 0, 0, 0, I(3), Z), (b'abpy', 0, 0, 0, I(2), Z),
            (b'ahky', 3, 0, 0, b'V', Z),
            (b'atp1', 3, 1, 0, S('Habilidades especiales (|cffffcc00V|r)'), Z),
            (b'aub1', 3, 1, 0, S(f'Abre las habilidades especiales de {quien}.'), Z),
            (b'spb1', 3, 1, 1, S(','.join(lista)), Z),
            (b'spb2', 0, 1, 2, I(0), Z), (b'spb3', 0, 1, 3, I(n), Z), (b'spb4', 0, 1, 4, I(n), Z),
            (b'spb5', 3, 1, 5, b'spellbook', Z)]
    tablas[1].append((b'Aspb', rid.encode(), mods)); usados.add(rid.encode())

salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
Path(sys.argv[2]).write_bytes(salida)
print('w3a v18k: 5 libros, 2 iconos del Tauren, 4 puentes a (0,0)')
