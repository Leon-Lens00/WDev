#!/usr/bin/env python3
"""Recursos del trasplante DBZ de Battle Stadium D.O.N 2.1a (v16t-don): rutas que nombran el código trasplantado y los
objetos nuevos (modelos de dummies, arte de habilidades y buffs), más las texturas que piden esos modelos (TEXS).
DON no trae listfile: cada ruta se busca por hash MPQ (mpqhash.py) y se toma su bloque de extraido/todo/_unnamed.
Se omiten las rutas que ya importó la fase 1 (recursos_dbz.tsv) y las que el mapa base ya tiene (listfile). Las que
el mapa ya tiene con OTRO contenido se informan como CHOCA para decidir a mano.
Uso: recursos_don.py DON.w3x EXTRAIDO FUNCIONES.j OBJETOS.w3u OBJETOS.w3a OBJETOS.w3h IDS.txt fase1.tsv listfile-base.txt SALIDA.tsv
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from mpqhash import Mpq
from w3b_titulo import parse
from objetos_v12k import parse_w3a
import don_familia

don, ext, func, ou, oa, oh, ids, fase1, lst, out = sys.argv[1:11]
m = Mpq(don)
U = Path(ext) / 'todo' / '_unnamed'
EXT = re.compile(r'\.(mdl|mdx|blp|tga|wav|mp3)$', re.I)
nuevos = {l.split()[1] for l in open(ids)}

rutas = set()
for s in re.findall(r'"((?:[^"\\]|\\.)*)"', Path(func).read_text(encoding='latin-1')):
    s = s.replace('\\\\', '\\')
    if EXT.search(s):
        rutas.add(s)
def campos(tabla, nivel):
    for base, nid, mods in tabla[1]:
        if nid.decode() not in nuevos:
            continue
        for x in mods:
            v = x[4] if nivel else x[2]
            for p in v.rstrip(b'\0').split(b','):
                p = p.decode('latin-1')
                if EXT.search(p):
                    rutas.add(p)
campos(parse(Path(ou).read_bytes())[1], False)
campos(parse_w3a(Path(oa).read_bytes())[1], True)
campos(parse(Path(oh).read_bytes())[1], False)

ya = {l.split('\t')[0].lower() for l in open(fase1)}
base = {l.strip().lower() for l in open(lst)}

def bloque(i):
    for e in ('mdx', 'blp', 'mp3', 'wav', 'tga', 'bin'):
        f = U / f'block_{i}.{e}'
        if f.exists():
            return f
def resolver(p):
    p = re.sub(r'(?i)(war3mapImported\\)DON_', r'\1', p)  # los renombrados se buscan por su nombre en DON
    c = [p[:-4] + '.mdx', p] if p.lower().endswith('.mdl') else [p]
    for x in c:
        i = m.find(x)
        if i is not None:
            return x, i
    return None, None

res, falta, pend, vistos = {}, [], sorted(rutas), set()
while pend:
    p = pend.pop()
    if p.lower() in vistos:
        continue
    vistos.add(p.lower())
    c, i = resolver(p)
    if c is None:
        if not p.lower().startswith(('abilities\\', 'units\\', 'replaceabletextures\\', 'sharedmodels', 'objects\\',
                                     'doodads\\', 'buildings\\', 'environment\\', 'textures\\', 'ui\\', 'sound\\')):
            falta.append(p)
        continue
    f = bloque(i)
    if f is None:
        falta.append(p + ' (sin bloque)')
        continue
    if any(k.lower() == c.lower() for k in res):
        continue  # mismo archivo nombrado con otras mayúsculas (el MPQ no distingue)
    res[c] = f
    if f.suffix == '.mdx':
        b = f.read_bytes(); o = 4
        while o + 8 <= len(b):
            tag, sz = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
            if tag == b'TEXS':
                for k in range(sz // 268):
                    t = b[o + 8 + k * 268 + 4:o + 8 + k * 268 + 264].split(b'\0')[0].decode('latin-1')
                    if t:
                        pend.append(t)
            o += 8 + sz

n = choca = 0
with open(out, 'w') as fo:
    for c, f in sorted(res.items()):
        if c.lower() in ya:
            continue
        nombre = don_familia.ruta_don(c)
        if nombre.lower() in base:
            sys.exit('choca con el mapa base: ' + c)
        if nombre != c:
            choca += 1
        fo.write(f'{nombre}\t{f.name}\n'); n += 1
print('rutas', len(rutas), 'resueltas', len(res), 'nuevas', n, 'renombradas DON_', choca,
      'bytes', sum(f.stat().st_size for c, f in res.items() if c.lower() not in ya and c.lower() not in base))
print('faltan en DON:', falta)
