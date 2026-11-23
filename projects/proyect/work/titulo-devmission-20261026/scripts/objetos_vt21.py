#!/usr/bin/env python3
"""v22d (23/11/2026): objetos de Vegito de Battle Stadium D.O.N 2.1a (H02T) sobre los de v22c (= fuentes/vg21-obj).

Personaje nuevo en la celda 8. Mismo método que objetos_vg21.py (v22b):
- Filas que cita el código trasplantado (vt21_trasplante.py, IDS): nuevas, se copian; compartidas o con cambios propios
  (NUESTRAS), se queda la nuestra. A00S ya entró con Goku (AG2a) y h05X con Vegeta (hVg5).
- A03E (Banshee Blast) ya estaba en el mapa, igual que en 2.1a y sin uso (sólo la citaba el Homing): se sustituye.
- Técnicas reales (las lanza la copia hCpW; la X el cuerpo): sin recarga ni maná y no de héroe. Bases que la copia no
  puede lanzar o que hacen daño propio pasan a Channel (ANcl) de blanco punto con orden propia: A03E (ANcs, Cluster
  Rockets) "clusterrockets", A033 (AUim, Impale) "flamestrike", A0DS (AOsw, Serpent Ward) "rainoffire". A03F Spirit
  Sword sigue siendo Aenr (blanco unidad, "entanglingroots", como A0J1 de Freezer) con daño de raíces a 0 y alcance 600.
- Afterimage (A0HN, Absk de héroe en 2.1a) pasa a ser una pasiva del libro (v22d.py): no entra como objeto.
- hVto (cuerpo) y hCpW (copia) salen de hVeg/hCpV con Vegito21.mdl (el cuerpo de 2.1a, que ya trae cabeza,
  recursos_vt21.py) y la escala de H02T (0,9). hMf9 (frente del MVP) y hbi9 (barra de vida) de hMf8/hbi8.
- Icono BTNGogeta.blp de 2.1a (el de H02T) en el cuerpo, la selección (DT4W) y la barra (HealthIconVt.mdx).
- Puentes AVt1-AVt5 (Q W E R X) copiados de AVp1-AVp5 (Vegeta): misma casilla y orden de botón; la E pasa a blanco
  unidad. Recargas como Vegeta (Q 20, W 30, E 30, R 90, X 10). Cartas DK0X-DK12 (DK12: la pasiva Afterimage).
Uso: objetos_vt21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
     SALIDA.w3h SALIDA.w3b [SALIDA-filas.txt]
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a

d21, ids_path, remapeo, u_in, a_in, h_in, b_in, u_out, a_out, h_out, b_out = sys.argv[1:12]
d21 = Path(d21)
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')

txt = (d21 / 'war3map.wts').read_bytes().decode('utf-8', 'replace')
WTS = {int(m.group(1)): m.group(2).strip() for m in
       re.finditer(r'STRING (\d+)\s*(?://[^\n]*\n)?\s*\{\r?\n(.*?)\r?\n\}', txt, re.S)}
RE = {a.encode(): b.encode() for a, b in (x.split('=') for x in remapeo.split(','))}
RE_PAT = re.compile(b'|'.join(re.escape(k) for k in RE))


def valor(v, remap=True):
    """TRIGSTR de 2.1a -> texto; rawcodes remapeados dentro de listas y cadenas."""
    m = re.fullmatch(rb'TRIGSTR_(\d+)\0?', v)
    if m:
        v = S(WTS[int(m.group(1))]) + (b'\0' if v.endswith(b'\0') else b'')
    return RE_PAT.sub(lambda m: RE[m.group(0)], v) if remap else v


def fila_u(r, nid=None):
    base, i, mods = r
    return (base, nid or i, [(mid, ty, valor(v) if ty == 3 else v, end) for mid, ty, v, end in mods])


def fila_a(r, nid=None):
    base, i, mods = r
    return (base, nid or i, [(mid, ty, lvl, dat, valor(v) if ty == 3 else v, end) for mid, ty, lvl, dat, v, end in mods])


_, f_u = parse((d21 / 'war3map.w3u').read_bytes())
_, f_a = parse_w3a((d21 / 'war3map.w3a').read_bytes())
_, f_h = parse((d21 / 'war3map.w3h').read_bytes())
FU = {r[1]: r for r in f_u[1]}
FA = {r[1]: r for r in f_a[1]}
FH = {r[1]: r for r in f_h[1]}
uver, utab = parse(Path(u_in).read_bytes())
aver, atab = parse_w3a(Path(a_in).read_bytes())
hver, htab = parse(Path(h_in).read_bytes())
bver, btab = parse(Path(b_in).read_bytes())
for p, (v, t) in [(u_in, (uver, utab)), (h_in, (hver, htab)), (b_in, (bver, btab))]:
    assert encode(v, t) == Path(p).read_bytes(), p
assert encode_w3a(aver, atab) == Path(a_in).read_bytes()
U = {r[1]: r for r in utab[1]}
A = {r[1]: r for r in atab[1]}
H = {r[1]: r for r in htab[1]}
B = {r[1]: r for r in btab[1]}


# Se quedan las nuestras (compartidas con Goku/Freezer/Trunks/Kurama/Vegeta o con cambios propios de Dev Mission).
NUESTRAS = {b'h00G', b'h01J', b'h05E', b'h05F', b'h0DN', b'h0G1', b'h0D3', b'h0GE', b'h054', b'h052', b'h0CH', b'h0GB',
            b'A00Y',
            # v22d: con cambios propios de Dev Mission (vuelo, muerte, A0DA, altura mínima) de personajes anteriores.
            b'h00F', b'h0BB', b'h0BI', b'h0EN'}
# Técnicas reales: 4 niveles (los de 2.1a); sin recarga, maná ni condición de héroe.
REALES = {b'A03E': 4, b'A033': 4, b'A03F': 4, b'A0DS': 4, b'A0HL': 4}
SUSTITUYE = {b'A03E'}  # ya en el mapa, igual que en 2.1a y sin uso
NO = {b'BTLF', b'Amrf', b'S000', b'H02T', b'A0HN', b'B046'}
YA = {n for n in RE.values() if n in U or n in A or n in H}  # remapeos que ya trajeron Goku (AG2a) y Vegeta (hVg5)


def mismo(a, b, es_a):
    """Igual a la nuestra salvo TRIGSTR (sin remapear: la nuestra cita nuestros ids)."""
    k = 4 if es_a else 2
    ma = [m[:k] + (valor(m[k], False) if m[1] == 3 else m[k],) + m[k + 1:] for m in a[2]]
    return a[0] == b[0] and sorted(ma) == sorted(b[2])

INV = {n: i for i, n in RE.items()}  # IDS viene ya remapeado
ids = [INV.get(i.encode(), i.encode()) for i in Path(ids_path).read_text().split() if i.encode() not in NO]
pend, vistos = list(ids), set()
cu, ca, ch = [], [], []
distintas = []
while pend:
    i = pend.pop(0)
    if i in vistos or i in NO:
        continue
    vistos.add(i)
    if i in FU:
        tab, mios, sale = FU, U, cu
    elif i in FA:
        tab, mios, sale = FA, A, ca
    elif i in FH:
        tab, mios, sale = FH, H, ch
    else:
        continue  # estándar
    if i in RE and RE[i] in YA:
        continue
    if i in RE:
        sale.append((i, RE[i]))
    elif i in SUSTITUYE:
        assert i in mios and mismo(tab[i], mios[i], tab is FA), i
        sale.append((i, None))
    elif i not in mios:
        sale.append((i, None))
    elif i in NUESTRAS:
        continue
    else:
        if not mismo(tab[i], mios[i], tab is FA):
            distintas.append(i)
        continue
    r = tab[i]
    if tab is FU:
        for m in r[2]:
            if m[0] == b'uabi':
                pend += [x for x in m[2].rstrip(b'\0').split(b',') if x]
    elif tab is FA:
        for m in r[2]:
            if m[0] in (b'abuf', b'aeff'):
                pend += [x for x in m[4].rstrip(b'\0').split(b',') if x]
assert not distintas, ('distintas y sin decisión', distintas)
for i, n in RE.items():
    assert n in YA or (n not in U and n not in A and n not in H), n
assert set(REALES) <= {i for i, _ in ca}, ca

atab[1][:] = [r for r in atab[1] if r[1] not in SUSTITUYE]
A = {r[1]: r for r in atab[1]}
nuevas_u = {n or i for i, n in cu}
nuevas_a = {n or i for i, n in ca}
nuevas_h = {i for i, _ in ch}
assert not (nuevas_u & set(U)), nuevas_u & set(U)
assert not (nuevas_a & set(A)), nuevas_a & set(A)
assert not (nuevas_h & set(H)), nuevas_h & set(H)

for i, n in cu:
    utab[1].append(fila_u(FU[i], n))
for i, n in ch:
    htab[1].append(fila_u(FH[i], n))


def canal(mods, niveles, orden):
    """Channel de blanco punto, visible, sin espera ni arte, con orden propia (como A0GV en v21t y A01D en v22b).
    Se quitan los campos propios de la base vieja (los que no empiezan por 'a') y los de blancos y efectos."""
    mods = [m for m in mods if m[0][:1] == b'a' and m[0] not in (b'abuf', b'atar', b'aare', b'aeff')]
    for lv in range(1, niveles + 1):
        mods += [(b'Ncl1', 2, lv, 1, Z, Z), (b'Ncl2', 0, lv, 2, I(2), Z), (b'Ncl3', 0, lv, 3, I(1), Z),
                 (b'Ncl4', 2, lv, 4, Z, Z), (b'Ncl5', 0, lv, 5, Z, Z), (b'Ncl6', 3, lv, 6, orden, Z)]
    return mods


CANAL = {b'A03E': (b'ANcs', b'clusterrockets'), b'A033': (b'AUim', b'flamestrike'), b'A0DS': (b'AOsw', b'rainoffire')}
for i, n in ca:
    base, nid, mods = fila_a(FA[i], n)
    if i in REALES:
        mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher')]
        mods += [(b'acdn', 2, k, 0, R(0.), Z) for k in range(1, REALES[i] + 1)]
        mods += [(b'amcs', 0, k, 0, I(0), Z) for k in range(1, REALES[i] + 1)]
        mods.append((b'aher', 0, 0, 0, I(0), Z))
    if i in CANAL:
        assert base == CANAL[i][0], (i, base)
        mods = canal(mods, REALES[i], CANAL[i][1])
        base = b'ANcl'
    elif i == b'A03F':
        assert base == b'Aenr', base
        mods = [m for m in mods if m[0] not in (b'aran', b'Eer1', b'atar')]
        for k in range(1, 5):
            mods += [(b'Eer1', 2, k, 1, R(0.), Z), (b'aran', 2, k, 0, R(600.), Z),
                     (b'atar', 3, k, 0, b'air,enemies,ground,neutral,organic', Z)]
    atab[1].append((base, nid, mods))
for tab in (utab[1], atab[1], htab[1]):
    for r in tab:
        if r[1] in nuevas_u | nuevas_a | nuevas_h:
            assert all(b'TRIGSTR' not in m[-2] for m in r[2]), r[1]
            assert all(x not in m[-2] for m in r[2] for x in (b'H02T', b'A0HN', b'B046')), r[1]
A = {r[1]: r for r in atab[1]}

# --- Vegito: cuerpo, copia, frente del MVP, icono de la barra de vida ---
MODELO = S('war3mapImported\\Vegito21.mdl')
ICONO = S('war3mapImported\\BTNGogeta.blp')
ESCALA = R(0.9)  # usca de H02T


def copia_u(i, nid, cambios):
    base, _, mods = U[i]
    assert nid not in U
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, nid, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1].append(nueva)
    U[nid] = nueva


copia_u(b'hVeg', b'hVto', {b'umdl': MODELO, b'usca': ESCALA, b'uico': ICONO, b'unam': S('Vegito'), b'umvs': I(300)})
copia_u(b'hCpV', b'hCpW', {b'umdl': MODELO, b'usca': ESCALA, b'unam': S('Copia de Vegito')})
copia_u(b'hMf8', b'hMf9', {b'umdl': S('war3mapImported\\MvpFrenteVegito21.mdl'), b'unam': S('Vegito MVP')})
copia_u(b'hbi8', b'hbi9', {b'umdl': S('UI\\HealthBarsHorizontal\\HealthIconVt.mdx'), b'unam': S('Health icon Vegito')})

# --- puentes del controlador: copia de, nombre, tecla, icono, objetivo (0 inmediato, 1 unidad, 2 punto), recarga ---
PUENTE = {
    b'AVt1': (b'AVp1', 'Banshee Blast', 'Q', 'ReplaceableTextures\\CommandButtons\\BTNControlMagic.blp', 2, 20.,
              'Vegito lanza una lluvia de esferas sobre la zona: cada esfera grande estalla en área. Se paran al '
              'chocar con árboles o precipicios.'),
    b'AVt2': (b'AVp2', 'Big Bang Attack', 'W', 'ReplaceableTextures\\CommandButtons\\BTNDarkRitual.blp', 2, 30.,
              'Una esfera avanza hacia el punto dañando a los enemigos que cruza y deja una cadena de explosiones; '
              'se para al chocar con árboles o precipicios.'),
    b'AVt3': (b'AVp3', 'Spirit Sword', 'E', 'war3mapImported\\BTNScepterOfMastery.blp', 1, 30.,
              'Vegito aparece junto al enemigo, lo arrastra y lo atraviesa con la espada de energía: daña a todos los '
              'enemigos de alrededor y lanza por los aires a los cercanos.'),
    b'AVt4': (b'AVp4', 'Final Kamehameha', 'R', 'war3mapImported\\BTNMoonWell.blp', 2, 90.,
              'Vegito carga y dispara un rayo enorme hacia el punto: daña una vez a cada enemigo que cruza y estalla '
              'al final. Se para al chocar con árboles o precipicios.'),
    b'AVt5': (b'AVp5', 'Power Up', 'X', 'ReplaceableTextures\\CommandButtons\\BTNPurge.blp', 0, 10.,
              'Carga 1 s y sube una forma (hasta 3). Cada forma dura 50 s.'),
}
for bid, (de, nom, tecla, arte, obj, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Vegito: ' + nom), b'ahky': S(tecla), b'aart': S(arte),
              b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
              b'aub1': S(desc + f'|n|n|cff808080Battle Stadium D.O.N 2.1a. Recarga {cd:g} s, sin maná.|r'),
              b'acdn': R(cd), b'amcs': I(0), b'Ncl2': I(obj)}
    assert bid not in A, bid
    base, _, mods = A[de]
    mods = [m for m in mods if m[0] not in (b'aare', b'atar')]
    mods = [(mid, ty, lvl, dat, CAMBIO.get(mid, v), end) for mid, ty, lvl, dat, v, end in mods]
    mods = [m if m[0] != b'Ncl3' else (m[0], m[1], m[2], m[3], I(struct.unpack('<i', m[4])[0] & ~2), m[5]) for m in mods]
    if obj == 1:
        mods.append((b'atar', 3, 1, 0, S('air,ground,enemy,neutral'), Z))
    assert {m[0] for m in mods} >= set(CAMBIO), (bid, set(CAMBIO) - {m[0] for m in mods})
    nueva = (base, bid, mods)
    atab[1].append(nueva)
    A[bid] = nueva
assert len({[m[4] for m in A[b][2] if m[0] == b'Ncl6'][0] for b in PUENTE}) == 5, 'órdenes repetidas'

# --- icono de selección y cartas del libro (btxf); DK12 es la pasiva Afterimage (icono de A0HN en 2.1a) ---
CARTAS = [(b'DK0X', 'AVt4'), (b'DK0Y', 'AVt3'), (b'DK0Z', 'AVt2'), (b'DK10', 'AVt1'), (b'DK11', 'AVt5')]
for de, nid, tex, nom in [(b'DT4V', b'DT4W', ICONO, S('BTN Vt'))] + [
        (b'DK0B', c, S(PUENTE[p.encode()][3]), S('Carta ' + p)) for c, p in CARTAS] + [
        (b'DK0B', b'DK12', S('ReplaceableTextures\\CommandButtons\\BTNInvisibility.blp'), S('Carta Afterimage'))]:
    base, _, mods = B[de]
    assert len(nid) == 4 and nid not in B and {m[0] for m in mods} >= {b'btxf', b'bnam'}, nid
    nueva = (base, nid, [(mid, ty, tex if mid == b'btxf' else nom if mid == b'bnam' else v, end) for mid, ty, v, end in mods])
    btab[1].append(nueva)
    B[nid] = nueva

us, As, hs, bs = encode(uver, utab), encode_w3a(aver, atab), encode(hver, htab), encode(bver, btab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As and encode(*parse(hs)) == hs
assert encode(*parse(bs)) == bs
for p, b in [(u_out, us), (a_out, As), (h_out, hs), (b_out, bs)]:
    Path(p).write_bytes(b)
if len(sys.argv) > 12:  # filas nuevas o cambiadas, para recursos_vt21.py
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + [b'hVto', b'hCpW', b'hMf9', b'hbi9', b'DT4W'] + \
              [b'DK0X', b'DK0Y', b'DK0Z', b'DK10', b'DK11', b'DK12']
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| nuevas',
      b' '.join(n or i for i, n in cu + ca + ch).decode())
