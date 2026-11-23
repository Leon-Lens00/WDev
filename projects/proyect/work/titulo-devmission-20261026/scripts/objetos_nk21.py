#!/usr/bin/env python3
"""v21y (22/11/2026): objetos de Naruto Kurama de Battle Stadium D.O.N 2.1a (H01A Kyuubi Chakra Mode) sobre los de v21x.

Personaje nuevo en la celda 6; el Naruto sabio (hNar/hNaK) no cambia. Mismo método que objetos_tr21.py (v21s):
- Filas que cita el código trasplantado (nk21_trasplante.py, IDS) más A0K5 (X) y su cierre: nuevas, se copian;
  compartidas o con cambios propios (NUESTRAS), se queda la nuestra. A00S/h0HB ya entraron con Goku (AG2a, hG2f).
  A0F5/A0F3/h0DI son también ids del sabio de 1.8c: las de 2.1a entran como AKu1, AKu4 y hKu0.
- Técnicas reales (las lanza la copia hCpU; la X el cuerpo): sin recarga ni maná y no de héroe, como REALES de v21s.
  A0K5 (Roar) con área 50: el manto sólo para quien lo lanza.
- hKur (cuerpo) y hCpU (copia) salen de hTrk/hCpT con el modelo NarutoKurama21 (recursos_nk21.py) y la escala de H01A
  (1,25). hMf7 (frente del MVP) y hbi7 (icono de la barra de vida) salen de hMf4/hbi5.
- Icono propio BTNNarutoKurama21.blp (BTNNaruto de 2.1a en dorado, recursos_nk21.py) en el cuerpo, la selección (DT4K)
  y la barra (HealthIconKu.mdx).
- Puentes AKp1-AKp5 (Q W E R X) copiados de ATr4, ATr2, ATr3, ATr5 y ATr1: misma casilla y orden de botón; sin maná,
  recarga larga como Trunks. Cartas DK0N-DK0R con el icono de cada técnica.
Uso: objetos_nk21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
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

# Se quedan las nuestras (compartidas con Goku/Freezer/Trunks/el sabio o con cambios propios de Dev Mission).
NUESTRAS = {b'A00Y', b'h01M', b'h03N', b'h0BB', b'h0ES', b'h0CH', b'h0D3', b'h0EN', b'h0GB', b'h03V', b'h052', b'A087',
            b'B004', b'h06E', b'h0G1', b'h04N'}
EXTRA = [b'A0K5']  # la X no la cita el código: la lanza el cuerpo
# Técnicas reales: niveles de 2.1a; sin recarga, maná ni condición de héroe (las lanza la copia o el cuerpo hKur).
REALES = {b'A0F5': 4, b'A0K2': 4, b'A0KY': 3, b'A0F3': 4, b'A0K5': 1}
NO = {b'BTLF', b'Amrf', b'S000', b'H01A', b'A00W', b'B008'}
YA = {n for n in RE.values() if n in U or n in A or n in H}  # remapeos que ya trajo Goku (AG2a, hG2f)


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
for i, n in ca:
    base, nid, mods = fila_a(FA[i], n)
    if i in REALES:
        mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher')]
        mods += [(b'acdn', 2, k, 0, R(0.), Z) for k in range(1, REALES[i] + 1)]
        mods += [(b'amcs', 0, k, 0, I(0), Z) for k in range(1, REALES[i] + 1)]
        mods.append((b'aher', 0, 0, 0, I(0), Z))
    if i == b'A0K5':
        assert sum(m[0] == b'aare' for m in mods) == 1
        mods = [m[:4] + (R(50.),) + m[5:] if m[0] == b'aare' else m for m in mods]
    atab[1].append((base, nid, mods))
for tab in (utab[1], atab[1], htab[1]):
    for r in tab:
        if r[1] in nuevas_u | nuevas_a | nuevas_h:
            assert all(b'TRIGSTR' not in m[-2] for m in r[2]), r[1]
            assert all(x not in m[-2] for m in r[2] for x in (b'H01A', b'A00W')), r[1]
A = {r[1]: r for r in atab[1]}

# --- Kurama: cuerpo, copia, frente del MVP, icono de la barra de vida ---
MODELO = S('war3mapImported\\NarutoKurama21.mdl')
ICONO = S('war3mapImported\\BTNNarutoKurama21.blp')
ESCALA = R(1.25)  # usca de H01A


def copia_u(i, nid, cambios):
    base, _, mods = U[i]
    assert nid not in U
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, nid, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1].append(nueva)
    U[nid] = nueva


copia_u(b'hTrk', b'hKur', {b'umdl': MODELO, b'usca': ESCALA, b'uico': ICONO, b'unam': S('Naruto Kurama'),
                           b'umvs': I(350)})
copia_u(b'hCpT', b'hCpU', {b'umdl': MODELO, b'usca': ESCALA, b'unam': S('Copia de Naruto Kurama')})
copia_u(b'hMf4', b'hMf7', {b'umdl': S('war3mapImported\\MvpFrenteKurama21.mdl'), b'unam': S('Naruto Kurama MVP')})
copia_u(b'hbi5', b'hbi7', {b'umdl': S('UI\\HealthBarsHorizontal\\HealthIconKu.mdx'),
                           b'unam': S('Health icon Naruto Kurama')})

# --- puentes del controlador: copia de, nombre, tecla, icono, objetivo (0 inmediato, 1 unidad, 2 punto), recarga ---
PUENTE = {
    b'AKp1': (b'ATr4', 'Rasenrengan', 'Q', 'war3mapImported\\BTNRasenKyuugan.blp', 1, 20.,
              'Naruto lanza Rasengan a quince enemigos alrededor del blanco, uno tras otro; al final estalla sobre '
              'todos los enemigos de alrededor.'),
    b'AKp2': (b'ATr2', 'RasenKyuugan', 'W', 'war3mapImported\\BTNRasenRengan.blp', 0, 30.,
              'Durante 5 s Naruto atrapa con brazos de chakra a los enemigos cercanos y los golpea con Rasengan; '
              'cada golpe estalla en área.'),
    b'AKp3': (b'ATr3', 'Bijuu RasenShuriken', 'E', 'war3mapImported\\BTNBijuuRasenShuriken.blp', 2, 30.,
              'Lanza un Rasenshuriken gigante hacia el punto: daña a los enemigos que cruza y estalla en un área '
              'enorme, una vez por enemigo.'),
    b'AKp4': (b'ATr5', 'Bijuu Dama', 'R', 'war3mapImported\\BTNBijuuDama.blp', 2, 90.,
              'Kurama reúne la bola de bestia con cola y la dispara hacia el punto: daña a todo lo que cruza y '
              'explota al final con daño enorme en área.'),
    b'AKp5': (b'ATr1', 'Kyuubi Chakra Cloak', 'X', 'ReplaceableTextures\\CommandButtons\\BTNInnerFireOn.blp', 0, 60.,
              'El manto de chakra del Kyuubi cubre a Naruto 25 s: sus armas hacen más daño (hasta +75 % en T6).'),
}
for bid, (de, nom, tecla, arte, obj, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Naruto Kurama: ' + nom), b'ahky': S(tecla), b'aart': S(arte),
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
for de, nid, tex, nom in [(b'DT4T', b'DT4K', ICONO, S('BTN Ku'))] + [
        (b'DK0B', b'DK0' + c.encode(), S(t), S('Carta ' + p)) for c, t, p in [
            ('N', 'war3mapImported\\BTNBijuuDama.blp', 'AKp4'),
            ('O', 'war3mapImported\\BTNBijuuRasenShuriken.blp', 'AKp3'),
            ('P', 'war3mapImported\\BTNRasenRengan.blp', 'AKp2'),
            ('Q', 'war3mapImported\\BTNRasenKyuugan.blp', 'AKp1'),
            ('R', 'ReplaceableTextures\\CommandButtons\\BTNInnerFireOn.blp', 'AKp5')]]:
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
if len(sys.argv) > 12:  # filas nuevas o cambiadas, para recursos_nk21.py
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + [b'hKur', b'hCpU', b'hMf7', b'hbi7', b'DT4K'] + \
              [b'DK0' + c for c in (b'N', b'O', b'P', b'Q', b'R')]
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| nuevas',
      b' '.join(n or i for i, n in cu + ca + ch).decode())
