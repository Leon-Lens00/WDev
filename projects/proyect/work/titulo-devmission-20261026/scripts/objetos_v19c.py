#!/usr/bin/env python3
"""v19c (19/11/2026): copias de los personajes de D.O.N (Leon: "que sus habilidades los lanze el dummy como con el
tauren y asi ejecute todas las animaciones").
- w3u: 'hCpG' Goku, 'hCpF' Freezer, 'hCpT' Trunks, 'hCpN' Naruto, 'hCpK' Naruto Kyuubi. Igual que 'hCp0'
  (base 'otau', Aloc+Avul, sin colisión, sin ataque, sin comida) con el modelo y la escala del héroe y 10000 de maná:
  la copia recibe la habilidad real de D.O.N al nivel del héroe y la lanza ella.
- w3a: descripciones de Q (arrastra), E (540) y R (450) del Tauren.
Uso: objetos_v19c.py DIR_ENTRADA (w3a y w3u de v19b) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')

# --- w3a: textos del Tauren ---
b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b
TEXTOS = {
    b'ATb1': ('daña 300 y aparta a cada enemigo que atraviesa'.encode(),
              'golpea con el arma durante la carga, daña 300 a cada enemigo que toca y se lo lleva por delante'.encode()),
    b'ATb3': (b'300 en 180', b'300 en 540'),
    b'ATb4': (b'180 en 150', b'180 en 450'),
}
hechos = set()
for t in ta:
    for k, (base, rid, mods) in enumerate(t):
        if rid in TEXTOS:
            viejo, nuevo = TEXTOS[rid]
            for j, m in enumerate(mods):
                if m[0] == b'aub1':
                    assert m[4].count(viejo) == 1, (rid, m[4])
                    mods[j] = m[:4] + (m[4].replace(viejo, nuevo),) + m[5:]
                    hechos.add(rid)
assert hechos == set(TEXTOS), hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))

# --- w3u: copias ---
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
filas = {r[1]: r for t in tablas for r in t}
assert b'hCp0' in filas and b'hCp1' in filas


def F(mid, ty, v):
    return (mid, ty, v, b'\0\0\0\0')


def campo(rid, mid):
    for m in filas[rid][2]:
        if m[0] == mid:
            return m[2]
    raise KeyError((rid, mid))


def copia(rid, heroe, nom):
    assert rid not in filas, rid
    tablas[1].append((b'otau', rid, [
        F(b'unam', 3, S(nom)), F(b'umdl', 3, campo(heroe, b'umdl')), F(b'usca', 1, campo(heroe, b'usca')),
        F(b'uabi', 3, b'Aloc,Avul'),
        F(b'ucol', 2, R(0.)), F(b'ufoo', 0, I(0)), F(b'uaen', 0, I(0)),
        F(b'ubba', 0, I(0)), F(b'ubdi', 0, I(0)), F(b'ubsi', 0, I(0)),
        F(b'uhom', 0, I(1)), F(b'usid', 0, I(200)), F(b'usin', 0, I(200)),
        F(b'upoi', 0, I(0)), F(b'umvr', 2, R(3.)),
        F(b'umpm', 0, I(10000)), F(b'umpi', 0, I(10000))]))


copia(b'hCpG', b'hGok', 'Copia de Goku')
copia(b'hCpF', b'hFrz', 'Copia de Freezer')
copia(b'hCpT', b'hTrk', 'Copia de Trunks')
copia(b'hCpN', b'hNar', 'Copia de Naruto')
copia(b'hCpK', b'hNaK', 'Copia de Naruto Kyuubi')
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3a v19c: textos ATb1, ATb3, ATb4; w3u v19c: hCpG, hCpF, hCpT, hCpN, hCpK')
