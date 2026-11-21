#!/usr/bin/env python3
"""v20q (20/11/2026): CD y maná de las habilidades del libro, maná de los personajes y orden del libro por tecla.
Leon: "agregar CD a las habilidades del libro, ajustar el mana ... comenzando de dos cifras para habilidades suaves y
mas para fuertes ... un nuevo valor de mana a los personajes ... una regeneracion lenta a recomendacion ... la Q que
deberia estar primero estaba en el 3er slot". Valores elegidos por el agente ("te dejo a recomendacion").
- w3a: los puentes ANcl del libro (los gasta el controlador) con acdn/amcs de la tabla; posición: fila de arriba Q W E R
  en las columnas 0-3, fila de abajo las demás teclas en orden A S T X D desde la columna 0 (las pasivas del Tauren y
  Cairne quedan donde estaban). Descripción: la nota "Prueba: sin enfriamiento, 1 de maná." pasa a la recarga y el
  maná reales; en el Tauren y Cairne se añade (o se cambia la "Recarga N s." que ya tenían).
- w3u: h005, h006, hGok, hFrz, hTrk, hNar, hNaK con maná base 135 y regeneración base 0,95/s; con la inteligencia 1
  que ya tienen (15 de maná y 0,05/s por punto) quedan en 150 de maná y 1/s. Maná inicial 150.
Uso: objetos_v20q.py DIR_ENTRADA (w3a y w3u de v20o) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
R = lambda v: struct.pack('<f', v)
I = lambda v: struct.pack('<i', v)

# puente: (tecla, recarga s, maná)
TABLA = {
    # Goku
    'AGk1': ('Q', 6, 25), 'AGk2': ('W', 10, 40), 'AGk3': ('R', 25, 80), 'AGk5': ('T', 45, 100), 'AGk4': ('X', 30, 50),
    # Freezer
    'AFz3': ('Q', 6, 25), 'AFz5': ('W', 10, 40), 'AFz2': ('E', 12, 45), 'AFz4': ('R', 25, 80), 'AFz6': ('T', 30, 50),
    'AFz1': ('X', 8, 30),
    # Future Trunks
    'ATr4': ('Q', 6, 25), 'ATr2': ('W', 10, 40), 'ATr3': ('E', 12, 45), 'ATr5': ('R', 25, 80), 'ATr6': ('T', 18, 60),
    'ATr1': ('X', 30, 50),
    # Naruto
    'ANa5': ('Q', 6, 25), 'ANa4': ('E', 10, 40), 'ANa3': ('R', 45, 90), 'ANa2': ('T', 18, 60), 'ANa1': ('X', 20, 50),
    'ANa6': ('D', 15, 60),
    # Tauren
    'ATb1': ('Q', 6, 25), 'ATb2': ('W', 9, 35), 'ATb3': ('E', 10, 40), 'ATb4': ('R', 25, 80), 'ATb5': ('A', 12, 40),
    'ATb6': ('S', 15, 45),
    # Cairne
    'ACb1': ('Q', 6, 25), 'ACb2': ('W', 9, 35), 'ACb3': ('E', 10, 40), 'ACb4': ('R', 25, 80), 'ACb5': ('A', 14, 45),
    'ACb6': ('S', 12, 40),
}
ARRIBA = 'QWER'
ABAJO = 'ASTXD'
LIBROS = {'AGk': 'Goku', 'AFz': 'Freezer', 'ATr': 'Trunks', 'ANa': 'Naruto', 'ATb': 'Tauren', 'ACb': 'Cairne'}
pos = {}
for lib in LIBROS:
    teclas = sorted({TABLA[k][0] for k in TABLA if k.startswith(lib)} - set(ARRIBA), key=ABAJO.index)
    for k, (t, _, _) in TABLA.items():
        if k.startswith(lib):
            pos[k] = (ARRIBA.index(t), 0) if t in ARRIBA else (teclas.index(t), 1)
VIEJA = 'Prueba: sin enfriamiento, 1 de maná.'.encode('utf-8')

b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b, 'w3a: ida y vuelta distinta'
hechos = set()
for t in ta:
    for k, (base, rid, mods) in enumerate(t):
        r = rid.decode('latin-1')
        if r not in TABLA:
            continue
        assert base == b'ANcl', (r, base)
        tecla, cd, mana = TABLA[r]
        assert [m[4] for m in mods if m[0] == b'ahky'] == [tecla.encode()], (r, tecla)
        nota = f'Recarga {cd} s, {mana} de maná.'.encode('utf-8')
        nuevos, vistos = [], set()
        for m in mods:
            mid, ty, lv, dat, v, end = m
            if mid == b'acdn':
                assert lv == 1; v = R(float(cd))
            elif mid == b'amcs':
                assert lv == 1; v = I(mana)
            elif mid == b'abpx':
                v = I(pos[r][0])
            elif mid == b'abpy':
                v = I(pos[r][1])
            elif mid == b'aub1':
                if VIEJA in v:
                    v = v.replace(VIEJA, nota)
                elif b'Recarga ' in v:
                    i = v.index(b'Recarga ')
                    j = v.index(b'.', i)
                    v = v[:i] + nota + v[j + 1:]
                else:
                    v = v + b'|n|cff808080' + nota + b'|r'
            vistos.add(mid)
            nuevos.append((mid, ty, lv, dat, v, end))
        assert {b'acdn', b'amcs', b'abpx', b'abpy', b'aub1'} <= vistos, (r, vistos)
        t[k] = (base, rid, nuevos)
        hechos.add(r)
assert hechos == set(TABLA), set(TABLA) - hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))

b = (src / 'war3map.w3u').read_bytes()
vu, tu = parse(b)
assert encode(vu, tu) == b, 'w3u: ida y vuelta distinta'
TIPOS = {b'h005', b'h006', b'hGok', b'hFrz', b'hTrk', b'hNar', b'hNaK'}
VALORES = {b'umpm': (0, I(135)), b'umpi': (0, I(150)), b'umpr': (2, R(0.95))}
tocados = set()
for t in tu:
    for k, (base, rid, mods) in enumerate(t):
        if rid not in TIPOS:
            continue
        nuevos = []
        for m, ty, v, end in mods:
            if m in VALORES:
                assert ty == VALORES[m][0], (rid, m, ty)
                v = VALORES[m][1]
            nuevos.append((m, ty, v, end))
        for m, (ty, v) in VALORES.items():
            assert any(x[0] == m for x in mods), (rid, m)
        t[k] = (base, rid, nuevos)
        tocados.add(rid)
assert tocados == TIPOS, TIPOS - tocados
(dst / 'war3map.w3u').write_bytes(encode(vu, tu))
print('v20q:', len(hechos), 'puentes;', len(tocados), 'tipos con maná 135+15 y 0,95+0,05/s')
for r in sorted(TABLA):
    print(' ', r, TABLA[r], 'pos', pos[r])
