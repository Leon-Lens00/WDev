#!/usr/bin/env python3
"""v21e (22/11/2026): objetos de Goku de Battle Stadium D.O.N 2.1a (H0LF, formas dios) sobre los de v21d.

- Filas que cita el código trasplantado (goku21_trasplante.py, IDS) y su cierre (habilidades de los dummies, buffs):
  * nuevas en Dev Mission: se copian con el mismo id;
  * iguales o con diferencias menores (muerte, sombra, icono, nombre DON_): se queda la nuestra;
  * con otro contenido y el mismo id: se copian con id nuevo (REMAPEO), también dentro de las filas copiadas.
- A069 (cabeza base), A0IA (Warp Kamehameha) y A0BZ (Ultimate) sólo los usa Goku: se toma la fila de 2.1a.
- Habilidades reales (A0O6, A0IA, A0BZ): sin enfriamiento, maná ni marca de héroe; el coste está en los puentes.
- Puentes AGk1 Q Kamehameha, AGk2 W Warp, AGk3 R Ultimate (según la forma), AGk5 E Instant Transmission (a una
  unidad, por script en el héroe). Cartas DK00-DK04, icono DT4G y hGok con el icono de 2.1a; hGok y hCpG con el
  modelo nuevo; hMf2 y hbi3 con su frente y su icono de vida propios (recursos_goku21.py).
Los textos TRIGSTR de 2.1a se resuelven con su wts.
Uso: objetos_goku21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
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

# filas que se quedan como están en Dev Mission (comprobado con g2_comp: diferencias menores o compartidas)
NUESTRAS = {b'A00Y', b'h00E', b'h00F', b'h00G', b'h00J', b'h00M', b'h01J', b'h01M', b'h03N', b'h04N', b'h052',
            b'h064', b'h06E', b'h09T', b'h0BB', b'h0CH', b'h0D3', b'h0EN'}
SUSTITUYE = [b'A069', b'A0IA', b'A0BZ']
REALES = {b'A0O6': 4, b'A0IA': 4, b'A0BZ': 3}
NO = {b'A0O5', b'YTfb', b'YTfc', b'BTLF', b'BPSE'}  # Power Up va por muertes; destructibles sólo en llamadas quitadas


def mismo(a, b, es_a):
    """Igual a la nuestra salvo TRIGSTR (sin remapear: la nuestra cita nuestros ids)."""
    k = 4 if es_a else 2
    ma = [m[:k] + (valor(m[k], False) if m[1] == 3 else m[k],) + m[k + 1:] for m in a[2]]
    return a[0] == b[0] and sorted(ma) == sorted(b[2])


INV = {n: i for i, n in RE.items()}  # IDS puede venir ya remapeado
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
    if i in RE:
        sale.append((i, RE[i]))
    elif i in SUSTITUYE:
        sale.append((i, None))
    elif i not in mios:
        sale.append((i, None))
    elif i in NUESTRAS:
        continue
    else:
        r = tab[i]
        assert (mismo(r, mios[i], tab is FA)), f'{i} distinta y sin decisión'
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
    assert n not in U and n not in A and n not in H, n

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
    atab[1].append((base, nid, mods))
for tab in (utab[1], atab[1], htab[1]):
    for r in tab:
        if r[1] in nuevas_u | nuevas_a | {i for i, _ in ch}:
            assert all(b'TRIGSTR' not in m[-2] for m in r[2]), r[1]

# --- Goku: modelo, icono, copia, frente del MVP e icono de vida ---
MODELO = S('war3mapImported\\Goku21.mdl')
ICONO = S('war3mapImported\\BTNGokuSSB.blp')


def cambia_u(i, cambios):
    base, _, mods = U[i]
    assert {m[0] for m in mods} >= set(cambios), (i, set(cambios) - {m[0] for m in mods})
    nueva = (base, i, [(mid, ty, cambios.get(mid, v), end) for mid, ty, v, end in mods])
    utab[1][utab[1].index(U[i])] = nueva
    U[i] = nueva


cambia_u(b'hGok', {b'umdl': MODELO, b'uico': ICONO})
cambia_u(b'hCpG', {b'umdl': MODELO})
cambia_u(b'hMf2', {b'umdl': S('war3mapImported\\MvpFrenteGoku21.mdl')})
cambia_u(b'hbi3', {b'umdl': S('UI\\HealthBarsHorizontal\\HealthIconGoku21.mdx')})

# --- puentes del controlador: nombre, icono, objetivo, maná y enfriamiento (recomendación del 22/11) ---
PUENTE = {  # id: nombre, tecla, icono, objetivo (1 unidad, 2 punto), maná, recarga, descripción
    b'AGk1': ('Kamehameha', 'Q', 'war3mapImported\\BTNKamehamehaGoku.blp', 2, 25, 6.,
              'Goku carga y lanza el Kamehameha hacia el punto: una onda que daña a todo lo que cruza y estalla al '
              'final. En Super Saiyan 3 sale amarillo; en Super Saiyan Dios y con Kaioken, rojo.'),
    b'AGk2': ('Warp Kamehameha', 'W', 'war3mapImported\\BTNWarpKamehameha.blp', 1, 40, 10.,
              'Goku se teletransporta junto al enemigo y le lanza un Kamehameha a quemarropa: daño y aturdimiento.'),
    b'AGk3': ('Ultimate', 'R', 'war3mapImported\\BTNUltimateGoku.blp', 2, 90, 30.,
              'Cambia con la forma:|nBase: Genki Dama.|nSuper Saiyan: Super Kamehameha.|nSuper Saiyan 3: Dragon '
              'Fist.|nSuper Saiyan Dios: Big Bang en ráfaga.|nSuper Saiyan Blue: Kaioken (más ataque).|nUltra '
              'Instinto: golpe definitivo.'),
    b'AGk5': ('Instant Transmission', 'E', 'war3mapImported\\BTNInstantTransmission.blp', 1, 50, 20.,
              'Goku aparece al instante junto a la unidad elegida, aliada o enemiga. Sólo a unidades: no sirve para '
              'subir a zonas a las que no se llega andando.'),
}
for bid, (nom, tecla, arte, obj, mana, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Goku: ' + nom), b'ahky': S(tecla), b'aart': S(arte), b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
              b'aub1': S(desc + f'|n|n|cff808080Battle Stadium D.O.N 2.1a. Recarga {cd:g} s, {mana} de maná.|r'),
              b'acdn': R(cd), b'amcs': I(mana), b'Ncl2': I(obj)}
    base, _, mods = A[bid]
    mods = [m for m in mods if m[0] not in (b'aare', b'atar')]
    mods = [(mid, ty, lvl, dat, CAMBIO.get(mid, v), end) for mid, ty, lvl, dat, v, end in mods]
    mods = [m if m[0] != b'Ncl3' else (m[0], m[1], m[2], m[3], I(struct.unpack('<i', m[4])[0] & ~2), m[5]) for m in mods]
    if obj == 1:
        mods.append((b'atar', 3, 1, 0, S('air,ground,enemy,friend,neutral,nonsapper' if bid == b'AGk5'
                                         else 'air,ground,enemy,neutral'), Z))
    assert {m[0] for m in mods} >= set(CAMBIO) - {b'ahky'}, bid
    if b'ahky' not in {m[0] for m in mods}:
        mods.append((b'ahky', 3, 0, 0, S(tecla), Z))
    nueva = (base, bid, mods)
    atab[1][atab[1].index(A[bid])] = nueva
    A[bid] = nueva

# --- cartas del libro e icono del personaje (btxf) ---
CARTA = {b'DK00': 'war3mapImported\\BTNUltimateGoku.blp', b'DK01': 'war3mapImported\\BTNInstantTransmission.blp',
         b'DK02': 'war3mapImported\\BTNWarpKamehameha.blp', b'DK03': 'war3mapImported\\BTNKamehamehaGoku.blp',
         b'DK04': 'war3mapImported\\BTNPowerUPGokuGOd.blp', b'DT4G': 'war3mapImported\\BTNGokuSSB.blp'}
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
if len(sys.argv) > 12:  # filas nuevas o cambiadas, para recursos_goku21.py
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + list(CARTA) + [b'hGok', b'hCpG', b'hMf2', b'hbi3']
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| sustituidas', b' '.join(SUSTITUYE).decode())
