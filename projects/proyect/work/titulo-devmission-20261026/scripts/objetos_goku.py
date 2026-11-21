#!/usr/bin/env python3
"""v16t-goku (13/11/2026): objetos de Goku de Battle Stadium D.O.N 1.8c sobre los de v16t-ivan.

Leon (13/11/2026): Goku pasa de héroe a unidad normal atada a la pareja de Dev Mission, con los parámetros del Tauren
(h005: puntos de animación 0, vida, maná, colisión…); sin enfriamiento para probar y 1 de maná por habilidad.
- 'hGok': fila de h005 con nombre, modelo, icono y escala de Goku (H00C de D.O.N 1.8c).
- 'hbi3': icono de vida de Goku para la interfaz (fila de hbi0 con HealthIconGoku.mdx).
- Habilidades reales de D.O.N (en el cuerpo): sin enfriamiento ni maná en todos sus niveles y sin marca de héroe.
- AGk1..AGk5: botones Canal del controlador (fila de Arp1) con 1 de maná, sin enfriamiento, alcance infinito, icono de
  la habilidad real y una orden propia cada uno. Teclas: E Kamehameha (Q es Subfusiles), W Warp Kamehameha, R Super
  Dragon Fist, X Power Up (SSJ), T Spirit Bomb.
- Dummies, habilidades auxiliares y buffs de D.O.N que usa el código (goku_trasplante.py), con sus ids originales.
Las filas de D.O.N salen del mapa f2 (DevMission-DON18c-f2.w3x), con las rutas DON_ ya cambiadas.
Uso: objetos_goku.py F2.w3u F2.w3a F2.w3h IDS.txt ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h SALIDA.w3u SALIDA.w3a SALIDA.w3h
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a

fu, fa, fh, ids_path, u_in, a_in, h_in, u_out, a_out, h_out = sys.argv[1:11]
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')

_, f_u = parse(Path(fu).read_bytes())
_, f_a = parse_w3a(Path(fa).read_bytes())
_, f_h = parse(Path(fh).read_bytes())
FU = {r[1]: r for r in f_u[1]}
FA = {r[1]: r for r in f_a[1]}
FH = {r[1]: r for r in f_h[1]}
uver, utab = parse(Path(u_in).read_bytes())
aver, atab = parse_w3a(Path(a_in).read_bytes())
hver, htab = parse(Path(h_in).read_bytes())
for p, (v, t) in [(u_in, (uver, utab)), (h_in, (hver, htab))]:
    assert encode(v, t) == Path(p).read_bytes(), p
assert encode_w3a(aver, atab) == Path(a_in).read_bytes()
U = {r[1]: r for r in utab[1]}
A = {r[1]: r for r in atab[1]}
H = {r[1]: r for r in htab[1]}

ids = [i.encode() for i in Path(ids_path).read_text().split()]
REALES = [b'A00P', b'A0IA', b'A0BZ', b'A0G2', b'A01G']
unidades = [i for i in ids if i in FU and i[:1] == b'h']
habs = [i for i in ids if i in FA] + [b'A0IQ']
pend = list(unidades)
for u in unidades:  # habilidades propias de los dummies
    for m in FU[u][2]:
        if m[0] == b'uabi':
            habs += [x for x in m[2].split(b',') if x in FA]
habs = list(dict.fromkeys(habs))
buffs = []
for a in habs:
    for m in FA[a][2]:
        if m[0] in (b'abuf', b'aeff'):
            buffs += [x for x in m[4].split(b',') if x in FH]
buffs = list(dict.fromkeys(buffs + [i for i in ids if i in FH]))
nuevos_u = unidades + [b'hGok', b'hbi3']
nuevos_a = habs + [b'AGk1', b'AGk2', b'AGk3', b'AGk4', b'AGk5']
assert not set(nuevos_u) & set(U), set(nuevos_u) & set(U)
assert not set(nuevos_a) & set(A), set(nuevos_a) & set(A)
assert not set(buffs) & set(H), set(buffs) & set(H)


def sin_trigstr(rows, k):
    for r in rows:
        assert all(b'TRIGSTR' not in m[k] for m in r[2]), r[1]


for u in unidades:
    utab[1].append(FU[u])
sin_trigstr([FU[u] for u in unidades], 2)

# --- Goku: fila del Tauren con lo visual de Goku ---
goku = {m[0]: m[2] for m in FU[b'H00C'][2]}
VIS = {b'unam': S('Son Goku'), b'umdl': goku[b'umdl'], b'uico': goku[b'uico'], b'usca': goku[b'usca']}
gm = [(mid, ty, VIS.get(mid, v), end) for mid, ty, v, end in U[b'h005'][2]]
assert {m[0] for m in gm} >= set(VIS)
utab[1].append((U[b'h005'][0], b'hGok', gm))
utab[1].append((U[b'hbi0'][0], b'hbi3', [(mid, ty, {b'umdl': S('UI\\HealthBarsHorizontal\\HealthIconGoku.mdx'),
                                                      b'unam': S('Health icon Goku')}.get(mid, v), end)
                                         for mid, ty, v, end in U[b'hbi0'][2]]))

# --- habilidades de D.O.N ---
for a in habs:
    base, _, mods = FA[a]
    if a in REALES:
        niveles = max([m[2] for m in mods] + [struct.unpack('<i', m[4])[0] for m in mods if m[0] == b'alev'] + [1])
        mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher')]
        mods += [(b'acdn', 2, n, 0, R(0.), Z) for n in range(1, niveles + 1)]
        mods += [(b'amcs', 0, n, 0, I(0), Z) for n in range(1, niveles + 1)]
        mods.append((b'aher', 0, 0, 0, I(0), Z))
    atab[1].append((base, a, mods))
sin_trigstr([FA[a] for a in habs], 4)

# --- botones puente del controlador (fila de Arp1) ---
BOTON = [  # id, real, nombre, tecla, x, y, objetivo (0 nada, 1 unidad, 2 punto), orden, descripción
    (b'AGk1', b'A00P', 'Kamehameha', 'E', 1, 0, 2, 'blizzard',
     'Goku carga y lanza el Kamehameha hacia el punto: daña a los enemigos en su camino.'),
    (b'AGk2', b'A0IA', 'Warp Kamehameha', 'W', 2, 0, 1, 'chainlightning',
     'Goku se teletransporta junto al enemigo y le lanza un Kamehameha a quemarropa.'),
    (b'AGk3', b'A0BZ', 'Super Dragon Fist', 'R', 3, 0, 2, 'earthquake',
     'Goku se lanza hacia el punto con el puño del dragón: golpea a los enemigos que encuentra.'),
    (b'AGk4', b'A0G2', 'Power Up (SSJ)', 'X', 1, 2, 0, 'roar',
     'Goku canaliza su poder: al terminar la carga sube un nivel de Super Saiyan. Moverse, disparar o hacer dash la corta.'),
    (b'AGk5', b'A01G', 'Spirit Bomb', 'T', 3, 2, 2, 'inferno',
     'Goku reúne energía y lanza la Genkidama sobre el punto.'),
]
AREA = {b'AGk5': 1500.}  # Spirit Bomb: radio del daño en D.O.N (grupo de 1500 en el punto objetivo)
usados = {m[4] for r in atab[1] for m in r[2] if m[0] == b'Ncl6'}
for bid, real, nom, tecla, x, y, obj, orden, desc in BOTON:
    assert orden.encode() not in usados, orden
    arte = next(m[4] for m in FA[real][2] if m[0] == b'aart')
    CAMBIO = {b'anam': S('Goku: ' + nom), b'ahky': S(tecla), b'aart': arte,
              b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
              b'aub1': S(desc + '|n|n|cff808080Battle Stadium D.O.N 1.8c. Prueba: sin enfriamiento, 1 de maná.|r'),
              b'acdn': R(0.), b'amcs': I(1), b'Ncl2': I(obj), b'Ncl6': S(orden), b'abpx': I(x), b'abpy': I(y)}
    mods = [(mid, ty, lvl, data, CAMBIO.get(mid, v), end) for mid, ty, lvl, data, v, end in A[b'Arp1'][2]]
    assert {m[0] for m in mods} >= set(CAMBIO)
    if obj == 1:
        mods.append((b'atar', 3, 1, 0, S('air,ground,enemy,neutral'), Z))
    if bid in AREA:  # Leon (13/11): apuntar con el círculo del área real (Canal: opción 2 = objetivo de área)
        mods = [m if m[0] != b'Ncl3' else (m[0], m[1], m[2], m[3], I(struct.unpack('<i', m[4])[0] | 2), m[5])
                for m in mods if m[0] != b'aare']
        mods.append((b'aare', 2, 1, 0, R(AREA[bid]), Z))
    atab[1].append((b'ANcl', bid, mods))

for b in buffs:
    htab[1].append(FH[b])
sin_trigstr([FH[b] for b in buffs], 2)

us, As, hs = encode(uver, utab), encode_w3a(aver, atab), encode(hver, htab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As and encode(*parse(hs)) == hs
Path(u_out).write_bytes(us); Path(a_out).write_bytes(As); Path(h_out).write_bytes(hs)
print('unidades', len(unidades), '+ hGok hbi3; habilidades', len(habs), '+ 5 botones; buffs', b' '.join(buffs).decode())
