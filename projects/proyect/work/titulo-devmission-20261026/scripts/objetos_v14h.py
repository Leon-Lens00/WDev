#!/usr/bin/env python3
"""v14h: objetos sobre los de v14g.

- Colisión (`ucol`) 0 en los 10 tipos de oleada, sus élites y los jefes: no se estorban entre ellos. Las balas usan el
  círculo de selección (UnitHitShape), no la colisión.
- Escala: élites × 2,1 y jefes × 2,7 sobre el modelo del tipo (antes 1,25 y 1,8), con la selección (`ussc`) igual.
- Vida base de las élites 360 (45% de los 800 del jefe de la ronda 1); v14h.py suma el resto al aparecer con
  'ALh0'..'ALhA'.
- 'ALh0'..'ALhA': copias de 'AIlf' de dos niveles, +10 × 2^k y +0 de vida. Añadidas (suman el nivel 1), pasadas al
  nivel 2 y quitadas (restan el nivel 2, 0), dejan la vida máxima subida. Medido en la prueba del 04/11/2026: con los
  niveles al revés la vida bajaba.
- Icono de la tienda 'hbjt': como los de jefe (objetos_v14g.py), con BTNRockGolem; esfera 'ubjt' con TiendaEsfera.mdx.

Uso: objetos_v14h.py V14G_W3U V14F_W3A ICONO_MDX V14F_J DIR_SALIDA
"""
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
from objetos_v14g import ESCALA, LETRA, TIPOS, centrado, escalada, formas, prioridad
from w3b_titulo import encode, parse

ELITE, JEFE = 2.1, 2.7
VIDA_ELITE = 360
Z = b'\0\0\0\0'

w3u, w3a, icono, j, out = (Path(a) for a in sys.argv[1:6])
out.mkdir(exist_ok=True)
forma = formas(j.read_text(encoding='latin-1'))
assert sorted(forma) == sorted(TIPOS)


def f32(x): return struct.pack('<f', float(x))
def i32(n): return struct.pack('<i', int(n))


def poner(mods, cambios):
    vistos, res = set(), []
    for mid, ty, v, end in mods:
        if mid in cambios:
            ty, v = cambios[mid]
            vistos.add(mid)
        res.append((mid, ty, v, end))
    return res + [(mid, ty, v, Z) for mid, (ty, v) in cambios.items() if mid not in vistos]


version, tablas = parse(w3u.read_bytes())
assert encode(version, tablas) == w3u.read_bytes()
cambios = {t: {b'ucol': (2, f32(0))} for t in TIPOS}
for k, t in enumerate(TIPOS):
    cambios[f'ne0{k}'] = {b'ucol': (2, f32(0)), b'usca': (1, f32(ESCALA[t] * ELITE)),
                          b'ussc': (1, f32(escalada(forma[t], ELITE)[0])), b'uhpm': (0, i32(VIDA_ELITE))}
    if k:
        cambios[f'nj0{LETRA[k - 1]}'] = {b'ucol': (2, f32(0)), b'usca': (1, f32(ESCALA[t] * JEFE)),
                                         b'ussc': (1, f32(escalada(forma[t], JEFE)[0]))}
hechos = set()
for n, tabla in enumerate(tablas):
    for i, fila in enumerate(tabla):
        clave = (fila[0] if n == 0 else fila[1]).decode()
        if clave in cambios:
            tabla[i] = (fila[0], fila[1], poner(fila[2], cambios[clave]))
            hechos.add(clave)
# Un tipo sin cambios en la tabla original se añade con sólo su colisión.
for t in TIPOS:
    if t not in hechos:
        tablas[0].append((t.encode(), b'\0\0\0\0', [(b'ucol', 2, f32(0), Z)]))
        hechos.add(t)
assert hechos == set(cambios), set(cambios) - hechos

hbi0_base, _, hbi0 = next(r for r in tablas[1] if r[1] == b'hbi0')
ubj0_base, _, ubj0 = next(r for r in tablas[1] if r[1] == b'ubj0')
usados = {r[1] for t in tablas for r in t}
for rid in (b'hbjt', b'ubjt'):
    assert rid not in usados, rid
tablas[1].append((hbi0_base, b'hbjt', poner(hbi0, {b'umdl': (3, b'UI\\HealthBarsHorizontal\\TiendaIcono.mdx'),
                                                    b'unam': (3, b'Shop icon'), b'usca': (1, f32(.5))})))
tablas[1].append((ubj0_base, b'ubjt', poner(ubj0, {b'umdl': (3, b'war3mapImported\\TiendaEsfera.mdx')})))
(out / 'war3map.w3u').write_bytes(encode(version, tablas))

viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
nuevo = b'ReplaceableTextures\\CommandButtons\\BTNRockGolem.blp'
m = icono.read_bytes()
i = m.index(viejo)
(out / 'TiendaIcono.mdx').write_bytes(centrado(prioridad(m[:i] + nuevo.ljust(260, b'\0') + m[i + 260:], 3)))

version, tablas = parse_w3a(w3a.read_bytes())
assert encode_w3a(version, tablas) == w3a.read_bytes()
usados = {r[1] for t in tablas for r in t}
for k in range(11):
    rid = f'ALh{k:X}'.encode()
    assert rid not in usados, rid
    tablas[1].append((b'AIlf', rid, [
        (b'alev', 0, 0, 0, i32(2), Z), (b'Ilif', 0, 1, 1, i32(10 * 2 ** k), Z), (b'Ilif', 0, 2, 1, i32(0), Z),
        (b'anam', 3, 0, 0, f'Vida de élite +{10 * 2 ** k}'.encode(), Z)]))
(out / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))
print('ok', len(cambios))
