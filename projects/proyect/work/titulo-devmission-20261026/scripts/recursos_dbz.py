"""v16t-dbz (12/11/2026). Resuelve las rutas de los recursos DBZ de DON contra sus bloques sin nombre. Uso: recursos.py DON.w3x EXTRAIDO SALIDA.tsv [rutas extra...]"""
import sys, struct, re
from pathlib import Path
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts')
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse
from objetos_v12k import parse_w3a
from mpqhash import Mpq
don, ext, out = sys.argv[1], Path(sys.argv[2]), sys.argv[3]
m = Mpq(don)
U = ext / 'todo' / '_unnamed'
HER = 'H00C H0LF H00P H062 H04Z H037 H02X H0H5 H036 H02T H00B H0IM H07O H0AK H0CV H0GX H0LH H0J2 H0J3 H0MA'.split()
_, u = parse((ext/'war3map.w3u').read_bytes()); _, a = parse_w3a((ext/'war3map.w3a').read_bytes())
rows = {r[1].decode(): r for r in u[1]}; ab = {r[1].decode(): r for r in a[1]}
EXT = re.compile(rb'\.(mdl|mdx|blp|tga|wav|mp3)$', re.I)
paths = set(); abis = set()
for hh in HER:
    for x in rows[hh][2]:
        v = x[2].rstrip(b'\0')
        for p in v.split(b','):
            if EXT.search(p): paths.add(p.decode('latin-1'))
        if x[0] in (b'uabi', b'uhab'):
            abis |= {s.decode() for s in v.split(b',') if s}
k = list(abis)
while k:
    i = k.pop()
    if i in ab:
        for x in ab[i][2]:
            if x[0] == b'spb1':
                for q in x[4].rstrip(b'\0').split(b','):
                    if q and q.decode() not in abis: abis.add(q.decode()); k.append(q.decode())
for i in abis:
    if i not in ab: continue
    for x in ab[i][2]:
        for p in x[4].rstrip(b'\0').split(b','):
            if EXT.search(p): paths.add(p.decode('latin-1'))
paths |= set(sys.argv[4:])
res = {}
def blk(i):
    for e in ('mdx', 'blp', 'mp3', 'wav', 'bin'):
        f = U / f'block_{i}.{e}'
        if f.exists(): return f
def resolve(p):
    cands = [p]
    if p.lower().endswith('.mdl'): cands = [p[:-4] + '.mdx', p]
    if p.lower().endswith('.blp'):
        n = p.split('\\')[-1]
        cands += ['ReplaceableTextures\\CommandButtonsDisabled\\DIS' + n] if n.upper().startswith('BTN') or n.upper().startswith('PAS') else []
    for c in cands:
        i = m.find(c)
        if i is not None: return c, i
    return None, None
pend = sorted(paths); seen = set()
while pend:
    p = pend.pop()
    if p.lower() in seen: continue
    seen.add(p.lower())
    c, i = resolve(p)
    if c is None: continue
    f = blk(i); res[c] = (i, f)
    # disabled icon
    n = c.split('\\')[-1]
    if n.upper().startswith(('BTN', 'PAS')):
        for d in ('ReplaceableTextures\\CommandButtonsDisabled\\DIS' + n, 'war3mapImported\\DIS' + n, 'ReplaceableTextures\\CommandButtonsDisabled\\DIS' + n.replace('BTN', 'BTN', 1)):
            j = m.find(d)
            if j is not None and d not in res: res[d] = (j, blk(j))
    if f and f.suffix == '.mdx':
        b = f.read_bytes(); o = 4
        while o + 8 <= len(b):
            tag, sz = b[o:o+4], struct.unpack_from('<I', b, o+4)[0]
            if tag == b'TEXS':
                for k in range(sz // 268):
                    t = b[o+8+k*268+4:o+8+k*268+264].split(b'\0')[0].decode('latin-1')
                    if t: pend.append(t)
            o += 8 + sz
with open(out, 'w') as fo:
    for c, (i, f) in sorted(res.items()):
        fo.write(f'{c}\t{i}\t{f}\n')
miss = sorted(p for p in paths if resolve(p)[0] is None and not p.lower().startswith(('abilities\\', 'units\\', 'replaceabletextures\\commandbuttons\\', 'replaceabletextures\\passivebuttons\\', 'sharedmodels', 'objects\\', 'doodads\\', 'buildings\\', 'environment\\', 'textures\\')))
print('resueltos', len(res), 'bytes', sum(f.stat().st_size for _, f in res.values() if f), 'faltan', miss)
