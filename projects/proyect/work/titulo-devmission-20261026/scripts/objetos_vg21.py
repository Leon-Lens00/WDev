#!/usr/bin/env python3
"""v22b (22/11/2026): objetos de Vegeta de Battle Stadium D.O.N 2.1a (H00P Saiyan Soldier) sobre los de v22a.

Personaje nuevo en la celda 7. Mismo método que objetos_nk21.py (v21y):
- Filas que cita el código trasplantado (vg21_trasplante.py, IDS): nuevas, se copian; compartidas o con cambios propios
  (NUESTRAS), se queda la nuestra. A00S ya entró con Goku (AG2a); h05X (RaikageLightning en 2.1a, Purge en 1.8c) y h0CA
  (en 2.1a sin vuelo) entran como hVg5 y hVg6.
- Técnicas reales (las lanza la copia hCpV; la X el cuerpo): sin recarga ni maná y no de héroe, como REALES de v21y.
  Bases que la copia no puede lanzar (precedentes v21p y v21t): A01D Big Bang (AUim Impale) y A01E Galick Gun (AOsw
  Serpent Ward) pasan a Channel (ANcl) de blanco punto con orden propia ("flamestrike" y "clusterrockets"); A01F Final
  Flash ya es ANrf con Hbz a 0 en 2.1a (sin daño nativo).
- hVeg (cuerpo) y hCpV (copia) salen de hTrk/hCpT con Vegeta21.mdl (cuerpo de 2.1a, recursos_vg21.py) y la escala de
  H00P (0,9). La cabeza base (A080) la pone Don_Armar, como las piezas de Trunks. hMf8 (frente del MVP) y hbi8 (icono
  de la barra de vida) salen de hMf4/hbi5.
- Icono BTNSaiyanVegeta.blp de 2.1a en el cuerpo, la selección (DT4V) y la barra (HealthIconVe.mdx).
- Puentes AVp1-AVp5 (Q W E R X) copiados de ATr4, ATr2, ATr3, ATr5 y ATr1: misma casilla y orden de botón; sin maná;
  recargas como Kurama (Q 20, W 30, E 30, R 90) y la X como Power Up de Trunks (10 s, una forma por uso).
  Cartas DK0S-DK0W con el icono de cada técnica.
Uso: objetos_vg21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
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


# Se quedan las nuestras (compartidas con Goku/Freezer/Trunks/Kurama o con cambios propios de Dev Mission).
NUESTRAS = {b'h00G', b'h01J', b'h05E', b'h05F', b'h0DN', b'h0G1', b'h0D3', b'h0GE', b'h054', b'h052', b'h0CH', b'h0GB',
            b'A00Y'}
EXTRA = []
# Técnicas reales: niveles de 2.1a (la E y la X a nivel 1); sin recarga, maná ni condición de héroe.
REALES = {b'A01D': 4, b'A01E': 4, b'A01F': 3, b'A0HT': 4, b'A0HM': 4}
NO = {b'BTLF', b'Amrf', b'S000', b'H00P', b'B00E'}
YA = {n for n in RE.values() if n in U or n in A or n in H}  # remapeos que ya trajo Goku (AG2a)


def mismo(a, b, es_a):
    """Igual a la nuestra salvo TRIGSTR (sin remapear: la nuestra cita nuestros ids)."""
    k = 4 if es_a else 2
    ma = [m[:k] + (valor(m[k], False) if m[1] == 3 else m[k],) + m[k + 1:] for m in a[2]]
    return a[0] == b[0] and sorted(ma) == sorted(b[2])

INV = {n: i for i, n in RE.items()}  # IDS viene ya remapeado
ids = [INV.get(i.encode(), i.encode()) for i in Path(ids_path).read_text().split() if i.encode() not in NO] + EXTRA
pend, vistos = list(ids), set()
cu, ca, ch = [], [], []
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
    elif i not in mios:
        sale.append((i, None))
    elif i in NUESTRAS:
        continue
    else:
        assert mismo(tab[i], mios[i], tab is FA), f'{i} distinta y sin decisión'
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
for i, n in RE.items():
    assert n in YA or (n not in U and n not in A and n not in H), n
assert set(REALES) <= {i for i, _ in ca}, ca

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
    """Channel de blanco punto, visible, sin espera ni arte, con orden propia (como A0GV en v21t)."""
    assert not any(m[0].startswith(b'Ncl') for m in mods)
    for lv in range(1, niveles + 1):
        mods += [(b'Ncl1', 2, lv, 1, Z, Z), (b'Ncl2', 0, lv, 2, I(2), Z), (b'Ncl3', 0, lv, 3, I(1), Z),
                 (b'Ncl4', 2, lv, 4, Z, Z), (b'Ncl5', 0, lv, 5, Z, Z), (b'Ncl6', 3, lv, 6, orden, Z)]
    return mods


for i, n in ca:
    base, nid, mods = fila_a(FA[i], n)
    if i in REALES:
        mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher')]
        mods += [(b'acdn', 2, k, 0, R(0.), Z) for k in range(1, REALES[i] + 1)]
        mods += [(b'amcs', 0, k, 0, I(0), Z) for k in range(1, REALES[i] + 1)]
        mods.append((b'aher', 0, 0, 0, I(0), Z))
    if i == b'A01D':
        assert base == b'AUim', base
        mods = canal([m for m in mods if m[0] not in (b'Uim1', b'Uim2', b'Uim3', b'Uim4', b'abuf', b'atar', b'aare')],
                     4, b'flamestrike')
        base = b'ANcl'
    elif i == b'A01E':
        assert base == b'AOsw', base
        k = len(mods)
        mods = [m for m in mods if m[0] != b'Hwe2']
        assert k - len(mods) == 4, k - len(mods)
        mods = canal(mods, 4, b'clusterrockets')
        base = b'ANcl'
    elif i == b'A01F':
        assert base == b'ANrf' and all(struct.unpack('<f' if m[1] else '<i', m[4])[0] == 0
                                       for m in mods if m[0].startswith(b'Hbz')), 'Final Flash sin daño nativo'
    atab[1].append((base, nid, mods))
for tab in (utab[1], atab[1], htab[1]):
    for r in tab:
        if r[1] in nuevas_u | nuevas_a | nuevas_h:
            assert all(b'TRIGSTR' not in m[-2] for m in r[2]), r[1]
            assert all(x not in m[-2] for m in r[2] for x in (b'H00P', b'B00E')), r[1]
A = {r[1]: r for r in atab[1]}

# --- Vegeta: cuerpo, copia, frente del MVP, icono de la barra de vida ---
MODELO = S('war3mapImported\\Vegeta21.mdl')
ICONO = S('war3mapImported\\BTNSaiyanVegeta.blp')
ESCALA = R(0.9)  # usca de H00P


def copia_u(i, nid, cambios):
    base, _, mods = U[i]
    assert nid not in U
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, nid, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1].append(nueva)
    U[nid] = nueva


copia_u(b'hTrk', b'hVeg', {b'umdl': MODELO, b'usca': ESCALA, b'uico': ICONO, b'unam': S('Vegeta'), b'umvs': I(300)})
copia_u(b'hCpT', b'hCpV', {b'umdl': MODELO, b'usca': ESCALA, b'unam': S('Copia de Vegeta')})
copia_u(b'hMf4', b'hMf8', {b'umdl': S('war3mapImported\\MvpFrenteVegeta21.mdl'), b'unam': S('Vegeta MVP')})
copia_u(b'hbi5', b'hbi8', {b'umdl': S('UI\\HealthBarsHorizontal\\HealthIconVe.mdx'), b'unam': S('Health icon Vegeta')})

# --- puentes del controlador: copia de, nombre, tecla, icono, objetivo (0 inmediato, 1 unidad, 2 punto), recarga ---
PUENTE = {
    b'AVp1': (b'ATr4', 'Big Bang Attack', 'Q', 'ReplaceableTextures\\CommandButtons\\BTNAnimateDead.blp', 2, 20.,
              'Vegeta lanza una esfera de energía hacia el punto; se para al chocar con árboles o precipicios y '
              'estalla al acabar su recorrido sobre todos los enemigos de alrededor.'),
    b'AVp2': (b'ATr2', 'Galick Gun', 'W', 'ReplaceableTextures\\CommandButtons\\BTNWandOfShadowSight.blp', 2, 30.,
              'Un rayo púrpura avanza hacia el punto y daña a los enemigos que cruza; se para al chocar y estalla al '
              'final de su vida.'),
    b'AVp3': (b'ATr3', 'Final Explosion', 'E', 'ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp', 0, 30.,
              'Vegeta concentra su energía y explota: daña a todos los enemigos de alrededor y los aparta.'),
    b'AVp4': (b'ATr5', 'Final Flash', 'R', 'ReplaceableTextures\\CommandButtons\\BTNBearBlink.blp', 2, 90.,
              'Vegeta se eleva, carga y dispara un rayo enorme hacia el punto con daño muy alto en área.'),
    b'AVp5': (b'ATr1', 'Power Up', 'X', 'ReplaceableTextures\\CommandButtons\\BTNAvatar.blp', 0, 10.,
              'Carga 1 s y sube una forma: Super Saiyan, Super Saiyan 2 y Super Saiyan Blue. Cada forma dura 50 s.'),
}
for bid, (de, nom, tecla, arte, obj, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Vegeta: ' + nom), b'ahky': S(tecla), b'aart': S(arte),
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

# --- icono de selección y cartas del libro (btxf) ---
for de, nid, tex, nom in [(b'DT4T', b'DT4V', ICONO, S('BTN Ve'))] + [
        (b'DK0B', b'DK0' + c.encode(), S(PUENTE[p.encode()][3]), S('Carta ' + p)) for c, p in [
            ('S', 'AVp4'), ('T', 'AVp3'), ('U', 'AVp2'), ('V', 'AVp1'), ('W', 'AVp5')]]:
    base, _, mods = B[de]
    assert nid not in B and {m[0] for m in mods} >= {b'btxf', b'bnam'}, nid
    nueva = (base, nid, [(mid, ty, tex if mid == b'btxf' else nom if mid == b'bnam' else v, end) for mid, ty, v, end in mods])
    btab[1].append(nueva)
    B[nid] = nueva

us, As, hs, bs = encode(uver, utab), encode_w3a(aver, atab), encode(hver, htab), encode(bver, btab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As and encode(*parse(hs)) == hs
assert encode(*parse(bs)) == bs
for p, b in [(u_out, us), (a_out, As), (h_out, hs), (b_out, bs)]:
    Path(p).write_bytes(b)
if len(sys.argv) > 12:  # filas nuevas o cambiadas, para recursos_vg21.py
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + [b'hVeg', b'hCpV', b'hMf8', b'hbi8', b'DT4V'] + \
              [b'DK0' + c for c in (b'S', b'T', b'U', b'V', b'W')]
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| nuevas',
      b' '.join(n or i for i, n in cu + ca + ch).decode())
