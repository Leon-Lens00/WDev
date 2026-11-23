#!/usr/bin/env python3
"""v21n (22/11/2026): objetos de Freezer de Battle Stadium D.O.N 2.1a (H0GX Final Form, H0LH Golden) sobre los de v21m.

Mismo método que objetos_goku21.py (fase 2):
- Filas que cita el código trasplantado (fz21_trasplante.py, IDS) y su cierre (habilidades de los dummies, buffs):
  * nuevas en Dev Mission: se copian con el mismo id;
  * con diferencias menores o compartidas con otros personajes (NUESTRAS): se queda la nuestra;
  * con otro contenido y el mismo id: id nuevo (REMAPEO). A00S, h05X y h0HB ya entraron con Goku (AG2a, hG2d, hG2f);
    h002 pasa a hF2a.
- Técnicas de Freezer (A0IX Q, A0JD W, A0J1 E, A0IW R, A0IY X): fila de 2.1a, sin enfriamiento, maná ni marca de héroe;
  el coste está en los puentes AFz1-AFz6.
- Golden Form (A0OH, T): transformación del cuerpo hFrz en hFrG, la unidad nueva con el modelo Frieza Golden; 3 niveles
  (como en 2.1a), 35 s (adur, el cuerpo no es héroe), sin enfriamiento ni maná. La copia hCpH es la de Golden.
- hFrz, hCpF: modelo Frieza Final Form y escala de 2.1a (0,78). hMf3 (frente del MVP) lo genera recursos_fz21.py;
  hbi4 sigue igual: el icono BTNFreeza de 2.1a es el mismo archivo que el nuestro.
- Puentes: Leon (22/11) "le quitaremos el mana a las habiliades tambien pero en contrar aunmentaremos mucho mas el CD".
  Q 20 s, W 30 s, E 30 s, X 30 s, R 90 s, T 80 s; sin maná. W pasa a punto, como AUim en 2.1a.
- Cartas DK05-DK0A con el icono de cada técnica de 2.1a.
Uso: objetos_fz21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
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

# Se quedan las nuestras (sonda: diferencias en muerte, sombra, icono, nombre o altura; varias las usa Goku).
NUESTRAS = {b'A00Y', b'A0G4', b'h00F', b'h03V', b'h052', b'h054', b'h05E', b'h08L', b'h0CH', b'h0D3', b'h0DN', b'h0EN',
            b'h0GB', b'h0GE', b'h0H0', b'h0HH'}
SUSTITUYE = [b'A0IX', b'A0JD', b'A0J1', b'A0IW', b'A0IY']
REALES = {b'A0IX': 4, b'A0JD': 4, b'A0J1': 4, b'A0IW': 3, b'A0IY': 4, b'A0OH': 4}
NO = {b'BTLF', b'Amrf', b'S000'}
YA = {n for n in RE.values() if n in U or n in A or n in H}  # remapeos que ya trajo Goku (AG2a, hG2d, hG2f)


def mismo(a, b, es_a):
    """Igual a la nuestra salvo TRIGSTR (sin remapear: la nuestra cita nuestros ids)."""
    k = 4 if es_a else 2
    ma = [m[:k] + (valor(m[k], False) if m[1] == 3 else m[k],) + m[k + 1:] for m in a[2]]
    return a[0] == b[0] and sorted(ma) == sorted(b[2])


INV = {n: i for i, n in RE.items()}  # IDS viene ya remapeado
ids = [INV.get(i.encode(), i.encode()) for i in Path(ids_path).read_text().split() if i.encode() not in NO]
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
    elif i in SUSTITUYE:
        sale.append((i, None))
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
assert set(SUSTITUYE) <= {i for i, _ in ca} and b'A0OH' in {i for i, _ in ca}, ca

nuevas_u = {n or i for i, n in cu}
nuevas_a = {n or i for i, n in ca}
assert not (nuevas_u & set(U)), nuevas_u & set(U)
assert not ((nuevas_a - set(SUSTITUYE)) & set(A)), (nuevas_a - set(SUSTITUYE)) & set(A)
assert not ({i for i, _ in ch} & set(H))

for i, n in cu:
    utab[1].append(fila_u(FU[i], n))
for i, n in ch:
    htab[1].append(fila_u(FH[i], n))
atab[1] = [r for r in atab[1] if r[1] not in SUSTITUYE]
for i, n in ca:
    base, nid, mods = fila_a(FA[i], n)
    if i in REALES:
        mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher')]
        mods += [(b'acdn', 2, k, 0, R(0.), Z) for k in range(1, REALES[i] + 1)]
        mods += [(b'amcs', 0, k, 0, I(0), Z) for k in range(1, REALES[i] + 1)]
        mods.append((b'aher', 0, 0, 0, I(0), Z))
    if i == b'A0OH':
        # Golden Form: hFrz -> hFrG, 3 niveles (el 4 de 2.1a es la Beast Transform de otro héroe).
        mods = [m for m in mods if m[2] <= 3 and m[0] != b'alev']
        mods = [(mid, ty, lvl, dat, {b'Eme1': S('hFrz'), b'Emeu': S('hFrG')}.get(mid, v), end)
                for mid, ty, lvl, dat, v, end in mods]
        assert sum(m[0] in (b'Eme1', b'Emeu') for m in mods) == 6, mods
        mods.append((b'alev', 0, 0, 0, I(3), Z))
        # El cuerpo no es héroe: usa la duración normal (adur), no la de héroe (ahdu 35 en 2.1a).
        assert not any(m[0] == b'adur' for m in mods)
        mods += [(b'adur', 2, k, 0, R(35.), Z) for k in (1, 2, 3)]
        mods = [m if m[0] != b'aart' else m[:4] + (S('BTNGoldFrieza.blp'),) + m[5:] for m in mods]
        mods = [m if m[0] != b'arar' else m[:4] + (S('BTNGoldFrieza.blp'),) + m[5:] for m in mods]
    atab[1].append((base, nid, mods))
for tab in (utab[1], atab[1], htab[1]):
    for r in tab:
        if r[1] in nuevas_u | nuevas_a | {i for i, _ in ch}:
            assert all(b'TRIGSTR' not in m[-2] for m in r[2]), r[1]
            assert all(x not in m[-2] for m in r[2] for x in (b'H0GX', b'H0LH')), r[1]

# --- Freezer: modelo, escala, copias, Golden ---
MODELO = S('war3mapImported\\Frieza Final Form.mdl')
DORADO = S('war3mapImported\\Frieza Golden.mdl')
ESCALA = R(0.78)  # usca de H0GX y H0LH


def cambia_u(i, cambios):
    base, _, mods = U[i]
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, i, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1][utab[1].index(U[i])] = nueva
    U[i] = nueva


def copia_u(i, nid, cambios):
    base, _, mods = U[i]
    assert nid not in U
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, nid, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1].append(nueva)
    U[nid] = nueva


cambia_u(b'hFrz', {b'umdl': MODELO, b'usca': ESCALA})
cambia_u(b'hCpF', {b'umdl': MODELO, b'usca': ESCALA})
cambia_u(b'hMf3', {b'umdl': S('war3mapImported\\MvpFrenteFreezer21.mdl')})
copia_u(b'hFrz', b'hFrG', {b'umdl': DORADO, b'unam': S('Freezer (Golden)'),
                           b'uico': S('BTNGoldFrieza.blp')})
copia_u(b'hCpF', b'hCpH', {b'umdl': DORADO, b'unam': S('Copia de Freezer (Golden)')})

# --- puentes del controlador: nombre, tecla, icono, objetivo (0 inmediato, 1 unidad, 2 punto), recarga ---
PUENTE = {
    b'AFz3': ('You Will Die By My Hand!', 'Q', 'war3mapImported\\BTNYoullDie.blp', 2, 20.,
              'Freezer dispara un rayo hacia el punto que daña a todos los enemigos que cruza.'),
    b'AFz5': ('Imprisonment Ball', 'W', 'ReplaceableTextures\\CommandButtons\\BTNFireRocks.blp', 2, 30.,
              'Lanza una esfera hacia el punto: atrapa al primer enemigo que toca y la hace estallar sobre todos '
              'los enemigos cercanos.'),
    b'AFz2': ('Death Break', 'E', 'ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp', 1, 30.,
              'Freezer aparece junto al enemigo y lo golpea sin parar; cada golpe alcanza también a los enemigos '
              'de alrededor. Termina con una patada que lo lanza y estalla en área.'),
    b'AFz4': ('Death Ball', 'R', 'war3mapImported\\BTNDeathBall.blp', 2, 90.,
              'Freezer reúne la Death Ball y la lanza sobre el punto: daño enorme en área.'),
    b'AFz1': ('Death Saucer', 'X', 'war3mapImported\\BTNDeathSaucer.blp', 0, 30.,
              'Dos discos cortantes salen a los lados y vuelven hacia Freezer; dañan a cada enemigo que cruzan.'),
    b'AFz6': ('Golden Form', 'T', 'BTNGoldFrieza.blp', 0, 80.,
              'Freezer se transforma en Golden Freezer durante 35 s: estalla al transformarse y sus armas hacen '
              'más daño (+25/50/75 % según el nivel).'),
}
for bid, (nom, tecla, arte, obj, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Freezer: ' + nom), b'ahky': S(tecla), b'aart': S(arte), b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
              b'aub1': S(desc + f'|n|n|cff808080Battle Stadium D.O.N 2.1a. Recarga {cd:g} s, sin maná.|r'),
              b'acdn': R(cd), b'amcs': I(0), b'Ncl2': I(obj)}
    base, _, mods = A[bid]
    mods = [m for m in mods if m[0] not in (b'aare', b'atar')]
    mods = [(mid, ty, lvl, dat, CAMBIO.get(mid, v), end) for mid, ty, lvl, dat, v, end in mods]
    mods = [m if m[0] != b'Ncl3' else (m[0], m[1], m[2], m[3], I(struct.unpack('<i', m[4])[0] & ~2), m[5]) for m in mods]
    if obj == 1:
        mods.append((b'atar', 3, 1, 0, S('air,ground,enemy,neutral'), Z))
    assert {m[0] for m in mods} >= set(CAMBIO), (bid, set(CAMBIO) - {m[0] for m in mods})
    nueva = (base, bid, mods)
    atab[1][atab[1].index(A[bid])] = nueva
    A[bid] = nueva

# --- cartas del libro (btxf) ---
CARTA = {b'DK05': 'war3mapImported\\BTNDeathBall.blp', b'DK06': 'war3mapImported\\BTNDeathSaucer.blp',
         b'DK07': 'ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp',
         b'DK08': 'ReplaceableTextures\\CommandButtons\\BTNFireRocks.blp', b'DK09': 'war3mapImported\\BTNYoullDie.blp',
         b'DK0A': 'BTNGoldFrieza.blp'}
for i, tex in CARTA.items():
    base, _, mods = B[i]
    assert any(m[0] == b'btxf' for m in mods), i
    nueva = (base, i, [(mid, ty, S(tex) if mid == b'btxf' else v, end) for mid, ty, v, end in mods])
    btab[1][btab[1].index(B[i])] = nueva

us, As, hs, bs = encode(uver, utab), encode_w3a(aver, atab), encode(hver, htab), encode(bver, btab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As and encode(*parse(hs)) == hs
assert encode(*parse(bs)) == bs
for p, b in [(u_out, us), (a_out, As), (h_out, hs), (b_out, bs)]:
    Path(p).write_bytes(b)
if len(sys.argv) > 12:  # filas nuevas o cambiadas, para recursos_fz21.py
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + list(CARTA) + [b'hFrz', b'hCpF', b'hMf3',
                                                                               b'hFrG', b'hCpH']
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| sustituidas', b' '.join(SUSTITUYE).decode(),
      '| nuevas hFrG hCpH')
