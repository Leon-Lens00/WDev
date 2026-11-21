#!/usr/bin/env python3
"""Personajes DBZ de Battle Stadium D.O.N 2.1a (Valkemiere) para probarlos en Dev Mission (v16t-dbz).

Prueba privada de Leon (12/11/2026). Copia de DON las filas de los 20 tipos DBZ (16 elegibles y 4 formas) y de todas
sus habilidades (incluidas las de libros y las formas a las que transforman), con rawcodes nuevos para no chocar con
los del mapa: unidades 'HDz?' y habilidades 'Az??'. Las habilidades quedan en un solo nivel, sin aprendizaje de héroe
y en la barra normal; se descartan los buffs propios de DON (se usan los de la habilidad base). Los textos TRIGSTR se
resuelven con el war3map.wts de DON.
Uso: objetos_dbz.py DON.w3u DON.w3a DON.wts ENTRADA.w3u ENTRADA.w3a SALIDA.w3u SALIDA.w3a SALIDA-IDS.txt
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a

du, da, dw, u_in, a_in, u_out, a_out, ids_out = sys.argv[1:9]
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
S = lambda v: v.encode('utf-8')

# Orden de la selección: los 16 elegibles y después las 4 formas.
HER = ['H00C', 'H00P', 'H062', 'H04Z', 'H037', 'H0H5', 'H036', 'H02T', 'H00B', 'H0IM', 'H07O', 'H0AK', 'H0CV', 'H0GX',
       'H0J2', 'H0MA', 'H0LF', 'H02X', 'H0LH', 'H0J3']
B36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
UMAP = {h: 'HDz' + B36[i] for i, h in enumerate(HER)}
STD = {'AInv', 'ANth', 'Aamk'}  # habilidades del juego: se conservan (Aamk se quita, es de héroe)

# --- textos TRIGSTR de DON ---
wts = {}
for m in re.finditer(rb'STRING (\d+)\s*(?://[^\n]*\n\s*)?\{\r?\n(.*?)\r?\n\}', Path(dw).read_bytes(), re.S):
    wts[int(m.group(1))] = m.group(2)
def texto(v):
    m = re.fullmatch(rb'TRIGSTR_(\d+)\0?', v)
    if m:
        return wts.get(int(m.group(1)), b'') + b'\0'
    assert b'TRIGSTR' not in v, v
    return v

_, don_u = parse(Path(du).read_bytes())
_, don_a = parse_w3a(Path(da).read_bytes())
urows = {r[1].decode(): r for r in don_u[1]}
arows = {r[1].decode(): r for r in don_a[1]}

# Cierre de habilidades: las de las unidades y las que nombran los libros (spb1) de esas habilidades.
def lista(v):
    return [s.decode() for s in v.rstrip(b'\0').split(b',') if s.strip()]
abis = []
for h in HER:
    for x in urows[h][2]:
        if x[0] in (b'uabi', b'uhab'):
            abis += [a for a in lista(x[2]) if a not in abis]
k = 0
while k < len(abis):
    a = abis[k]; k += 1
    if a in arows:
        for x in arows[a][2]:
            if x[0] == b'spb1':
                abis += [s for s in lista(x[4]) if s not in abis]
cust = [a for a in abis if a in arows]
fuera = [a for a in abis if a not in arows and a not in STD]
assert not fuera, fuera
AMAP = {a: 'Az' + B36[i // 36] + B36[i % 36] for i, a in enumerate(cust)}
MAP = {**UMAP, **AMAP}

def remap(v):
    s = v.rstrip(b'\0')
    if not re.fullmatch(rb'[A-Za-z0-9]{4}(,[A-Za-z0-9]{4})*', s):
        return v
    partes = [MAP.get(p.decode(), p.decode()) for p in s.split(b',')]
    return ','.join(partes).encode() + (b'\0' if v.endswith(b'\0') else b'')

uver, utab = parse(Path(u_in).read_bytes())
aver, atab = parse_w3a(Path(a_in).read_bytes())
assert encode(uver, utab) == Path(u_in).read_bytes()
assert encode_w3a(aver, atab) == Path(a_in).read_bytes()
usados = {r[1].decode() for r in utab[1]} | {r[0].decode() for r in utab[0]}
ausados = {r[1].decode() for r in atab[1]} | {r[0].decode() for r in atab[0]}
assert not usados & set(UMAP.values()), usados & set(UMAP.values())
assert not ausados & set(AMAP.values()), ausados & set(AMAP.values())

# --- unidades ---
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
        # Goku Black: DON 2.1a no importó war3mapImported\Zamas.mdl; se usa el cuerpo de Goku oscurecido.
        nm = [m for m in nm if m[0] not in (b'umdl', b'uclr', b'uclg', b'uclb')]
        nm += [(b'umdl', 3, S('war3mapImported\\Goku_squished.mdl'), Z),
               (b'uclr', 0, I(90), Z), (b'uclg', 0, I(70), Z), (b'uclb', 0, I(110), Z)]
    nm.append((b'uabi', 3, ','.join(hab).encode(), Z))
    nm.append((b'uhab', 3, b'', Z))
    utab[1].append((base, UMAP[h].encode(), nm))

# --- habilidades ---
QUITAR = {b'aret', b'arut', b'arhk', b'arpx', b'arpy', b'alsk', b'arlv', b'areq', b'arqa'}
for a in cust:
    base, _, mods = arows[a]
    nm, vistos = [], set()
    for mid, ty, lvl, data, v, end in mods:
        if lvl > 1 or mid in QUITAR:
            continue
        if mid == b'abuf' and not re.fullmatch(rb'[A-Za-z0-9]{4}(,[A-Za-z0-9]{4})*\0?', v):
            continue
        if mid == b'abuf' and any(p.startswith(b'B0') for p in v.rstrip(b'\0').split(b',')):
            continue  # buff propio de DON: queda el de la habilidad base
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

us = encode(uver, utab); As = encode_w3a(aver, atab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As
Path(u_out).write_bytes(us); Path(a_out).write_bytes(As)
with open(ids_out, 'w') as f:
    for k2, v2 in MAP.items():
        f.write(f'{k2} {v2}\n')
print('unidades', len(UMAP), 'habilidades', len(AMAP))
