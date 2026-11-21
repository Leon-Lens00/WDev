#!/usr/bin/env python3
"""Objetos DBZ completos de Battle Stadium D.O.N 2.1a (Valkemiere) para el trasplante fiel (v16t-don).

Prueba privada de Leon (12/11/2026). Amplía objetos_dbz.py (fase 1) con todo lo que necesitan los triggers DBZ de DON:
- los 20 tipos de héroe (HDz0..HDzJ) y sus 110 habilidades con los MISMOS ids Az00.. que la fase 1, a un nivel, sin
  aprendizaje de héroe;
- sus buffs propios, ahora con id nuevo (Bz??) en lugar de descartarse;
- las habilidades que el código de DON nombra o que llevan los dummies (Az.. siguientes, todos sus niveles);
- los tipos de unidad dummy y auxiliares que nombra el código (letra original + 'D' + 2 cifras base 36).
Los textos TRIGSTR se resuelven con el war3map.wts de DON. Escribe además la tabla de ids (DON nuevo) que usa
don_trasplante.py.
Uso: objetos_don.py EXTRAIDO_DON rawcodes-fase1.txt BASE.w3u BASE.w3a BASE.w3h SALIDA.w3u SALIDA.w3a SALIDA.w3h IDS.txt
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a
import don_familia

E, fase1, u_in, a_in, h_in, u_out, a_out, h_out, ids_out = sys.argv[1:10]
E = Path(E)
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
S = lambda v: v.encode('utf-8')
B36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'

HER = ['H00C', 'H00P', 'H062', 'H04Z', 'H037', 'H0H5', 'H036', 'H02T', 'H00B', 'H0IM', 'H07O', 'H0AK', 'H0CV', 'H0GX',
       'H0J2', 'H0MA', 'H0LF', 'H02X', 'H0LH', 'H0J3']
UMAP = {h: 'HDz' + B36[i] for i, h in enumerate(HER)}
STD_A = {'AInv', 'ANth', 'Aamk', 'AChx', 'Amrf', 'Aloc', 'Avul', 'Aeth', 'AId1', 'Asp5'}

wts = {}
for m in re.finditer(rb'STRING (\d+)\s*(?://[^\n]*\n\s*)?\{\r?\n(.*?)\r?\n\}', (E / 'war3map.wts').read_bytes(), re.S):
    wts[int(m.group(1))] = m.group(2)
def texto(v):
    m = re.fullmatch(rb'TRIGSTR_(\d+)\0?', v)
    if m:
        return wts.get(int(m.group(1)), b'') + b'\0'
    assert b'TRIGSTR' not in v, v
    return v

_, don_u = parse((E / 'war3map.w3u').read_bytes())
_, don_a = parse_w3a((E / 'war3map.w3a').read_bytes())
_, don_h = parse((E / 'war3map.w3h').read_bytes())
urows = {r[1].decode(): r for r in don_u[1]}
arows = {r[1].decode(): r for r in don_a[1]}
hrows = {r[1].decode(): r for r in don_h[1]}

def lista(v):
    return [s.decode() for s in v.rstrip(b'\0').split(b',') if s.strip()]

# --- las 110 de la fase 1, en el mismo orden (mismos ids) ---
fase1_map = dict(l.split() for l in open(fase1))
hero_abis = [k for k, v in fase1_map.items() if v.startswith('Az')]
hero_abis.sort(key=lambda a: fase1_map[a])
AMAP = {a: fase1_map[a] for a in hero_abis}
for a in hero_abis:
    assert a in arows, a

# --- lo que nombra el código de DON ---
fam = don_familia.cargar(str(E / 'j.j'), fase1)
nombrados = don_familia.rawcodes(don_familia.cuerpo(fam))
units = sorted(x for x in nombrados if x in urows and x not in UMAP)
extra_a = [x for x in sorted(nombrados) if x in arows and x not in AMAP]
buffs = {x for x in nombrados if x in hrows}

# cierre: habilidades de los dummies, libros (spb1) y buffs de las habilidades
k = 0
pend = list(units)
while pend:
    uu = pend.pop()
    for x in urows[uu][2]:
        if x[0] in (b'uabi', b'uhab'):
            for a in lista(x[2]):
                if a in arows and a not in AMAP and a not in extra_a:
                    extra_a.append(a)
todas = hero_abis + extra_a
while k < len(todas):
    a = todas[k]; k += 1
    for x in arows[a][2]:
        if x[0] == b'spb1':
            for s in lista(x[4]):
                if s in arows and s not in todas:
                    todas.append(s); extra_a.append(s)
        if x[0] == b'abuf':
            buffs |= {s for s in lista(x[4]) if s in hrows}
for i, a in enumerate(extra_a):
    AMAP[a] = 'Az' + B36[(110 + i) // 36] + B36[(110 + i) % 36]
cuenta = {}
NMAP = {}
for uu in units:
    c = cuenta.get(uu[0], 0); cuenta[uu[0]] = c + 1
    NMAP[uu] = uu[0] + 'D' + B36[c // 36] + B36[c % 36]
BMAP = {b: 'Bz' + B36[i // 36] + B36[i % 36] for i, b in enumerate(sorted(buffs))}
MAP = {**UMAP, **NMAP, **AMAP, **BMAP}

def remap(v):
    s = v.rstrip(b'\0')
    if not re.fullmatch(rb'[A-Za-z0-9]{4}(,[A-Za-z0-9]{4})*', s):
        return v
    partes = [MAP.get(p.decode(), p.decode()) for p in s.split(b',')]
    return ','.join(partes).encode() + (b'\0' if v.endswith(b'\0') else b'')

uver, utab = parse(Path(u_in).read_bytes())
aver, atab = parse_w3a(Path(a_in).read_bytes())
hver, htab = parse(Path(h_in).read_bytes())
assert encode(uver, utab) == Path(u_in).read_bytes()
assert encode_w3a(aver, atab) == Path(a_in).read_bytes()
assert encode(hver, htab) == Path(h_in).read_bytes()
usados = {r[1].decode() for r in utab[1]} | {r[0].decode() for r in utab[0]}
ausados = {r[1].decode() for r in atab[1]} | {r[0].decode() for r in atab[0]}
husados = {r[1].decode() for r in htab[1]} | {r[0].decode() for r in htab[0]}
assert not usados & (set(UMAP.values()) | set(NMAP.values())), usados & set(NMAP.values())
assert not ausados & set(AMAP.values())
assert not husados & set(BMAP.values())

# --- héroes (como la fase 1) ---
for h in HER:
    base, _, mods = urows[h]
    nm, hab = [], []
    for mid, ty, v, end in mods:
        if mid in (b'uabi', b'uhab'):
            hab += [MAP.get(a, a) for a in lista(v) if a != 'Aamk' and MAP.get(a, a) not in hab]
            continue
        v = texto(v) if ty == 3 else v
        if mid == b'udaa':
            v = remap(v)
        nm.append((mid, ty, v, Z))
    if h == 'H0MA':
        nm = [m for m in nm if m[0] not in (b'umdl', b'uclr', b'uclg', b'uclb')]
        nm += [(b'umdl', 3, S('war3mapImported\\Goku_squished.mdl'), Z),
               (b'uclr', 0, I(90), Z), (b'uclg', 0, I(70), Z), (b'uclb', 0, I(110), Z)]
    nm.append((b'uabi', 3, ','.join(hab).encode(), Z))
    nm.append((b'uhab', 3, b'', Z))
    utab[1].append((base, UMAP[h].encode(), nm))

# --- dummies y auxiliares: tal cual, con ids y textos resueltos ---
for uu in units:
    base, _, mods = urows[uu]
    nm = [(mid, ty, don_familia.ruta_don(remap(texto(v)).decode('latin-1')).encode('latin-1') if ty == 3 else v, Z)
          for mid, ty, v, end in mods]
    utab[1].append((base, NMAP[uu].encode(), nm))

# --- habilidades ---
QUITAR = {b'aret', b'arut', b'arhk', b'arpx', b'arpy', b'alsk', b'arlv', b'areq', b'arqa'}
for a in hero_abis:
    base, _, mods = arows[a]
    nm, vistos = [], set()
    for mid, ty, lvl, data, v, end in mods:
        if lvl > 1 or mid in QUITAR:
            continue
        if mid == b'alev':
            v = I(1)
        elif mid == b'aher':
            v = I(0)
        elif ty == 3:
            v = remap(texto(v))
        nm.append((mid, ty, lvl, data, v, Z)); vistos.add(mid)
    if b'aher' not in vistos:
        nm.append((b'aher', 0, 0, 0, I(0), Z))
    if b'alev' not in vistos:
        nm.append((b'alev', 0, 0, 0, I(1), Z))
    atab[1].append((base, AMAP[a].encode(), nm))
for a in extra_a:
    base, _, mods = arows[a]
    nm = [(mid, ty, lvl, data, don_familia.ruta_don(remap(texto(v)).decode('latin-1')).encode('latin-1') if ty == 3 else v, Z)
          for mid, ty, lvl, data, v, end in mods]
    atab[1].append((base, AMAP[a].encode(), nm))

# --- buffs ---
for b in sorted(buffs):
    base, _, mods = hrows[b]
    nm = [(mid, ty, remap(texto(v)) if ty == 3 else v, Z) for mid, ty, v, end in mods]
    htab[1].append((base, BMAP[b].encode(), nm))

us, As, hs = encode(uver, utab), encode_w3a(aver, atab), encode(hver, htab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As and encode(*parse(hs)) == hs
Path(u_out).write_bytes(us); Path(a_out).write_bytes(As); Path(h_out).write_bytes(hs)
with open(ids_out, 'w') as f:
    for k2, v2 in MAP.items():
        f.write(f'{k2} {v2}\n')
print('héroes', len(UMAP), 'unidades', len(NMAP), 'habilidades', len(hero_abis), '+', len(extra_a), 'buffs', len(BMAP))
