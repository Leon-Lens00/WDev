#!/usr/bin/env python3
"""v16u (13/11/2026): objetos de Freezer, Future Trunks y Naruto de D.O.N 1.8c sobre los de v16t-gokum.

Generaliza objetos_goku.py con los datos de don_heroes.py (Leon, 13/11/2026: mismo método que Goku):
- unidad del héroe: fila del Tauren h005 con nombre, modelo, icono y escala de la ficha de D.O.N; Naruto lleva además su
  forma Kyuubi 'hNaK' (fila de h005 con lo visual de H0D9 y sus habilidades A0HX y A0HW);
- icono de vida (fila de hbi0 con HealthIcon<Héroe>.mdx, que hace recursos_v16u.py);
- habilidades reales sin enfriamiento, maná ni marca de héroe; el morfo de Naruto (A00U) apunta a hNar/hNaK;
- botones Canal del controlador (fila de Arp1): 1 de maná, sin enfriamiento, icono de la habilidad real, orden propia;
- dummies, auxiliares y buffs que cita el código trasplantado, con sus ids de D.O.N (los ya presentes se comprueban);
- iconos del título (w3b): copia de D000 con la textura del icono del héroe, también para Goku.
Uso: objetos_v16u.py F2_DIR BASE_DIR IDS_DIR SALIDA_DIR  (BASE_DIR con war3map.w3u/w3a/w3h/w3b de v16t-gokum;
     IDS_DIR con <P>-ids.txt de don_heroe.py)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a
from don_heroes import CASILLAS, HEROES, NIVELES, SOLO_FORMA

f2, base, ids_dir, out = map(Path, sys.argv[1:5])
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')


def leer(p, w3a=False):
    b = p.read_bytes()
    v, t = (parse_w3a if w3a else parse)(b)
    assert (encode_w3a if w3a else encode)(v, t) == b, p
    return v, t


_, f_u = leer(f2 / 'war3map.w3u')
_, f_a = leer(f2 / 'war3map.w3a', True)
_, f_h = leer(f2 / 'war3map.w3h')
FU = {r[1]: r for r in f_u[1]}
FA = {r[1]: r for r in f_a[1]}
FH = {r[1]: r for r in f_h[1]}
uver, utab = leer(base / 'war3map.w3u')
aver, atab = leer(base / 'war3map.w3a', True)
hver, htab = leer(base / 'war3map.w3h')
bver, btab = leer(base / 'war3map.w3b')
U = {r[1]: r for r in utab[1]}
A = {r[1]: r for r in atab[1]}
H = {r[1]: r for r in htab[1]}
B = {r[1]: r for r in btab[1]}
campo = lambda r, k: next((m[2] for m in r[2] if m[0] == k), None)
igual = lambda x, y: x == y
cuenta = {'u': 0, 'a': 0, 'h': 0, 'iguales': 0}


def poner(tab, D, F, i, k):
    """Copia la fila i de D.O.N; si ya está (otro héroe o Goku), tiene que ser la misma."""
    if i in D:
        assert D[i] == F[i], f'{i} ya existe con otro contenido'
        cuenta['iguales'] += 1
        return
    assert all(b'TRIGSTR' not in m[-2] for m in F[i][2]), i
    tab[1].append(F[i]); D[i] = F[i]; cuenta[k] += 1


def fila_visual(nuevo_id, don_id, nombre, extra=()):
    d = {m[0]: m[2] for m in FU[don_id][2]}
    vis = {b'unam': S(nombre), b'umdl': d[b'umdl'], b'uico': d[b'uico'], b'usca': d[b'usca']}
    mods = [(mid, ty, vis.get(mid, v), end) for mid, ty, v, end in U[b'h005'][2]]
    assert {m[0] for m in mods} >= set(vis)
    mods += [(mid, ty, v, mods[0][3]) for mid, ty, v in extra]  # mismo marcador de fin que el resto
    assert nuevo_id not in U, nuevo_id
    utab[1].append((U[b'h005'][0], nuevo_id, mods)); U[nuevo_id] = utab[1][-1]


usados = {m[4] for r in atab[1] for m in r[2] if m[0] == b'Ncl6'}
for h in HEROES:
    # icono del título: copia de D000 con la textura del icono de la ficha de D.O.N (como DT3Q en objetos_v12e.py)
    rid = h['icono_titulo'].encode()
    assert rid not in B, rid
    tex = campo(FU[h['don'].encode()], b'uico')
    t = next(r for r in btab[1] if r[1] == b'D000')
    btab[1].append((b'ATtc', rid, [(m, ty, tex if m == b'btxf' else S('BTN ' + h['P']) if m == b'bnam' else v, rid)
                                   for m, ty, v, _ in t[2]]))
    B[rid] = btab[1][-1]
    if not h['nuevo']:
        continue
    P = h['P']
    ids = [i.encode() for i in (ids_dir / f'{P}-ids.txt').read_text().split()]
    reales = [b[0].encode() for b in h['botones']]
    pasivas = [x.encode() for x in h['pasivas']]
    unidades = [i for i in ids if i in FU and i[:1] == b'h']
    habs = [i for i in ids if i in FA] + reales + pasivas
    if 'forma' in h:
        habs += [x for x in campo(FU[h['forma'][1].encode()], b'uabi').split(b',') if x in FA]
    for u in unidades:  # habilidades propias de los dummies
        habs += [x for x in (campo(FU[u], b'uabi') or b'').split(b',') if x in FA]
    habs = list(dict.fromkeys(habs))
    buffs = []
    for a in habs:
        for m in FA[a][2]:
            if m[0] in (b'abuf', b'aeff'):
                buffs += [x for x in m[4].split(b',') if x in FH]
    buffs = list(dict.fromkeys(buffs + [i for i in ids if i in FH]))
    for u in unidades:
        poner(utab, U, FU, u, 'u')
    for b in buffs:
        poner(htab, H, FH, b, 'h')
    # --- unidades del héroe ---
    fila_visual(h['unidad'].encode(), h['don'].encode(), h['nombre'])
    if 'forma' in h:
        abi = campo(FU[h['forma'][1].encode()], b'uabi')
        fila_visual(h['forma'][0].encode(), h['forma'][1].encode(), h['nombre'] + ' (Kyuubi)', [(b'uabi', 3, abi)])
    vid = h['vida'].encode()
    assert vid not in U
    utab[1].append((U[b'hbi0'][0], vid, [(mid, ty, {b'umdl': S(f'UI\\HealthBarsHorizontal\\HealthIcon{P}.mdx'),
                                                    b'unam': S('Health icon ' + h['nombre'])}.get(mid, v), end)
                                         for mid, ty, v, end in U[b'hbi0'][2]]))
    U[vid] = utab[1][-1]
    # --- habilidades de D.O.N ---
    for a in habs:
        bse, _, mods = FA[a]
        if a in reales:
            alev = [struct.unpack('<i', m[4])[0] for m in mods if m[0] == b'alev']
            n = NIVELES.get(a.decode(), alev[0] if alev else max([m[2] for m in mods] + [1]))
            mods = [m for m in mods if m[0] not in (b'acdn', b'amcs', b'aher', b'alev')]
            mods += [(b'acdn', 2, k, 0, R(0.), Z) for k in range(1, n + 1)]
            mods += [(b'amcs', 0, k, 0, I(0), Z) for k in range(1, n + 1)]
            mods += [(b'aher', 0, 0, 0, I(0), Z), (b'alev', 0, 0, 0, I(n), Z)]
            if a == b'A00U':  # el morfo va entre las filas de Dev Mission
                cambio = {b'Eme1': S(h['unidad']), b'Emeu': S(h['forma'][0])}
                mods = [m if m[0] not in cambio else (m[0], m[1], m[2], m[3], cambio[m[0]], m[5]) for m in mods]
                assert sum(m[0] in cambio for m in mods) >= 2 * n
        if a not in reales:
            poner(atab, A, FA, a, 'a')
        else:
            assert a not in A, a
            atab[1].append((bse, a, mods)); A[a] = atab[1][-1]; cuenta['a'] += 1
    # --- botones puente (fila de Arp1) ---
    for k, (real, _, obj, orden, nom, desc, area) in enumerate(h['botones']):
        x, y, tecla = CASILLAS[k]
        bid = f'A{P}{k + 1}'.encode()
        assert bid not in A and orden.encode() not in usados, (bid, orden)
        usados.add(orden.encode())
        arte = next(m[4] for m in FA[real.encode()][2] if m[0] == b'aart')
        nota = '|n|cffffcc00Sólo en modo Kyuubi.|r' if real in SOLO_FORMA else ''
        CAMBIO = {b'anam': S(f'{h["nombre"]}: {nom}'), b'ahky': S(tecla), b'aart': arte,
                  b'atp1': S(f'{nom} (|cffffcc00{tecla}|r)'),
                  b'aub1': S(desc + nota + '|n|n|cff808080Battle Stadium D.O.N 1.8c. Prueba: sin enfriamiento, 1 de maná.|r'),
                  b'acdn': R(0.), b'amcs': I(1), b'Ncl2': I(obj), b'Ncl6': S(orden), b'abpx': I(x), b'abpy': I(y)}
        mods = [(mid, ty, lvl, data, CAMBIO.get(mid, v), end) for mid, ty, lvl, data, v, end in A[b'Arp1'][2]]
        assert {m[0] for m in mods} >= set(CAMBIO)
        if obj == 1:
            mods.append((b'atar', 3, 1, 0, S('air,ground,enemy,neutral'), Z))
        if area:
            mods = [m if m[0] != b'Ncl3' else (m[0], m[1], m[2], m[3], I(struct.unpack('<i', m[4])[0] | 2), m[5])
                    for m in mods if m[0] != b'aare']
            mods.append((b'aare', 2, 1, 0, R(area), Z))
        atab[1].append((b'ANcl', bid, mods)); A[bid] = atab[1][-1]

out.mkdir(parents=True, exist_ok=True)
for nombre, v, t, enc in [('w3u', uver, utab, encode), ('w3a', aver, atab, encode_w3a), ('w3h', hver, htab, encode),
                          ('w3b', bver, btab, encode)]:
    b = enc(v, t)
    assert enc(*(parse_w3a if enc is encode_w3a else parse)(b)) == b
    (out / f'war3map.{nombre}').write_bytes(b)
print('objetos v16u:', cuenta, '+ 18 botones, 4 iconos del título')
