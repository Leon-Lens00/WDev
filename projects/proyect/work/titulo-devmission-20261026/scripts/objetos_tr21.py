#!/usr/bin/env python3
"""v21s (22/11/2026): objetos de Future Trunks de Battle Stadium D.O.N 2.1a (H037 Sword Warrior) sobre los de v21r.

Mismo método que objetos_fz21.py (v21n):
- Filas que cita el código trasplantado (tr21_trasplante.py, IDS) y su cierre: nuevas, se copian; compartidas o con
  cambios propios (NUESTRAS), se queda la nuestra; A00S y h05X ya entraron con Goku (AG2a, hG2d).
- Técnicas: siguen nuestras filas de A05B Q, A0GV W, A086 E, A03W R y A0H5 (Power Up); A03W con el alcance de 2.1a.
  Sword of Hope (A0I5, T) y las cabezas A07X/A07Y/A07Z pasan a la fila de 2.1a (espada en la mano, buff B05L).
- hTrk, hCpT: modelo TrunkNormal y escala de H037 (0,85). hMf4 (frente del MVP) lo genera recursos_tr21.py.
- Puentes: sin maná y recarga larga como Freezer: Q 20 s, W 30 s, E 30 s, R 90 s, T 80 s.
- Cartas DK0B-DK0G con el icono de cada técnica de 2.1a.
Uso: objetos_tr21.py D21_DIR IDS.txt REMAPEO ENTRADA.w3u ENTRADA.w3a ENTRADA.w3h ENTRADA.w3b SALIDA.w3u SALIDA.w3a
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

# Se quedan las nuestras (compartidas con Goku/Freezer/Naruto o con cambios propios de Dev Mission). Las técnicas
# A03W, A05B, A086, A0GV y A0H5 siguen con nuestra fila (puentes y órdenes del bot comprobados desde v16u).
NUESTRAS = {b'A00Y', b'h01M', b'h03N', b'h0BB', b'h0ES', b'h0CH', b'h0D3', b'h0EN', b'h0GB', b'h03V', b'h052', b'A087',
            b'B004', b'A03W', b'A05B', b'A086', b'A0GV', b'A0H5', b'h06E', b'h0G1'}
# Cabezas del cuerpo TrunkNormal (normal, SSJ, SSJ2) y Sword of Hope (2.1a: espada en la mano con el buff B05L).
SUSTITUYE = [b'A07X', b'A07Y', b'A07Z', b'A0I5']
REALES = {b'A0I5': 4}
NO = {b'BTLF', b'Amrf', b'S000'}
YA = {n for n in RE.values() if n in U or n in A or n in H}  # remapeos que ya trajo Goku (AG2a, hG2d)


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
assert set(SUSTITUYE) <= {i for i, _ in ca}, ca

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
            assert all(x not in m[-2] for m in r[2] for x in (b'H037',)), r[1]

# --- Trunks: modelo, escala, copias, frente del MVP ---
MODELO = S('war3mapImported\\TrunkNormal.mdl')
ESCALA = R(0.85)  # usca de H037


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


cambia_u(b'hTrk', {b'umdl': MODELO, b'usca': ESCALA})
cambia_u(b'hCpT', {b'umdl': MODELO, b'usca': ESCALA})
cambia_u(b'hMf4', {b'umdl': S('war3mapImported\\MvpFrenteTrunks21.mdl')})
cambia_u(b'h06E', {b'usca': R(4.5)})
cambia_u(b'h0G1', {b'usca': R(1.7)})


def cambia_a(i, f):
    base, _, mods = A[i]
    nueva = (base, i, f(mods))
    atab[1][atab[1].index(A[i])] = nueva
    A[i] = nueva


# R: alcance de 2.1a (1000; el nuestro de 1.8c era 125, cuerpo a cuerpo).
cambia_a(b'A03W', lambda ms: [m[:4] + (R(1000.),) + m[5:] if m[0] == b'aran' and m[2] in (1, 2, 3) else
                              m[:4] + (S('Final Hope Slash'),) + m[5:] if m[0] == b'anam' else m for m in ms])
assert sum(m[0] == b'aran' and m[4] == R(1000.) for m in A[b'A03W'][2]) == 3

# --- puentes del controlador: nombre, tecla, icono, objetivo (0 inmediato, 1 unidad, 2 punto), recarga ---
PUENTE = {
    b'ATr4': ('Burning Attack', 'Q', 'war3mapImported\\BTNBurningAttack.blp', 2, 20.,
              'Trunks lanza una bola de energía hacia el punto: daña una vez a cada enemigo que cruza y estalla al '
              'final sobre todos los enemigos de alrededor.'),
    b'ATr2': ('Finish Buster', 'W', 'war3mapImported\\BTNFinishBuster.blp', 2, 30.,
              'Una esfera de energía avanza hacia el punto dañando a los enemigos que toca y explota en área.'),
    b'ATr3': ('Heat Dome Attack', 'E', 'war3mapImported\\BTNHeatDome.blp', 1, 30.,
              'Trunks aparece junto al enemigo, lo lanza al aire y dispara la cúpula de fuego: daño a todos los '
              'enemigos de alrededor.'),
    b'ATr5': ('Final Hope Slash', 'R', 'war3mapImported\\BTNBurningSlash.blp', 1, 90.,
              'Trunks corta al enemigo con la espada y remata con una explosión: daño enorme en área.'),
    b'ATr6': ('Sword of Hope', 'T', 'war3mapImported\\BTNSwordofHope.blp', 0, 80.,
              'La espada de la esperanza estalla alrededor de Trunks y durante 18 s sus armas hacen más daño '
              '(hasta +75 % en T6).'),
}
for bid, (nom, tecla, arte, obj, cd, desc) in PUENTE.items():
    CAMBIO = {b'anam': S('Future Trunks: ' + nom), b'ahky': S(tecla), b'aart': S(arte), b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
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
CARTA = {b'DK0B': 'war3mapImported\\BTNBurningSlash.blp', b'DK0C': 'war3mapImported\\BTNSwordofHope.blp',
         b'DK0D': 'war3mapImported\\BTNHeatDome.blp', b'DK0E': 'war3mapImported\\BTNFinishBuster.blp',
         b'DK0F': 'war3mapImported\\BTNBurningAttack.blp', b'DK0G': 'war3mapImported\\BTNPowerupTrunks.blp'}
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
    tocadas = [n or i for i, n in cu + ca + ch] + list(PUENTE) + list(CARTA) + [b'hTrk', b'hCpT', b'hMf4',
                                                                               b'A03W']
    Path(sys.argv[12]).write_text(b','.join(dict.fromkeys(tocadas)).decode())
print('unidades', len(cu), 'habilidades', len(ca), 'buffs', len(ch), '| remapeadas',
      b' '.join(i + b'>' + n for i, n in cu + ca if n).decode(), '| sustituidas', b' '.join(SUSTITUYE).decode(),
      '')
