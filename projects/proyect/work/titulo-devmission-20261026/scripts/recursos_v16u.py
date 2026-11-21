#!/usr/bin/env python3
"""v16u (13/11/2026): recursos de Freezer, Future Trunks y Naruto de D.O.N 1.8c que faltan en v16t-gokum.

Como recursos_goku.py: rutas citadas por los objetos nuevos y el código trasplantado y, dentro de cada modelo, las que
pide (recursivo). Se toman del mapa f2; una ruta ya presente en v16t-gokum con el mismo contenido no se importa, con
otro contenido es un error. Escribe HealthIcon<P>.mdx (HealthIconTauren con la textura del icono de cada héroe).
Uso: recursos_v16u.py F2_EXTRAIDO BASE_EXTRAIDO OBJ_DIR SALIDA_DIR SALIDA.tsv FUNCIONES.j...
"""
from pathlib import Path
import re, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from don_heroes import HEROES

f2, base, obj, out_dir, tsv = map(Path, sys.argv[1:6])
fjs = sys.argv[6:]
indice = lambda d: {str(p.relative_to(d)).replace('/', '\\').lower(): p for p in d.rglob('*') if p.is_file()}
F2, BA = indice(f2), indice(base)
RUTA = re.compile(rb'[A-Za-z0-9_\-\\/ .()!&\'#,+]{1,200}?\.(?:mdl|mdx|blp|tga|wav|mp3)', re.I)
rutas = lambda b: {m.group(0).decode('latin-1').replace('\\\\', '\\') for m in RUTA.finditer(b)}


def variantes(p):
    p = re.sub(r'\\+', r'\\', p.replace('/', '\\')).strip()
    out = {p}
    if p.lower().endswith('.mdl'):
        out.add(p[:-4] + '.mdx')
    if p.lower().endswith(('.mdl', '.mdx')):
        out.add(p[:-4] + '_portrait.mdx')
    if p.lower().endswith('.tga'):
        out.add(p[:-4] + '.blp')
    return out


pend = set()
for f in [obj / f'war3map.{x}' for x in ('w3u', 'w3a', 'w3h', 'w3b')] + [Path(x) for x in fjs]:
    pend |= rutas(f.read_bytes())
vistos, importa, iguales = set(), {}, []
while pend:
    p = pend.pop()
    for v in variantes(p):
        k = v.lower()
        if k in vistos:
            continue
        vistos.add(k)
        if k not in F2:
            continue
        b = F2[k].read_bytes()
        if k in BA:
            assert BA[k].read_bytes() == b, f'{v} ya está en v16t-gokum con otro contenido'
            iguales.append(v)
            continue
        importa[k] = F2[k]
        if k.endswith('.mdx'):
            pend |= rutas(b)

out_dir.mkdir(parents=True, exist_ok=True)
plantilla = BA['ui\\healthbarshorizontal\\healthicontauren.mdx'].read_bytes()
viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
assert plantilla.count(viejo) == 1
i = plantilla.index(viejo)
extra = []
TEX = {'Fz': 'war3mapImported\\BTNFreeza.blp', 'Tr': 'war3mapImported\\BTNtrunks.blp', 'Na': 'BTNNaruto.blp'}
for h in HEROES:
    if not h['nuevo']:
        continue
    t = TEX[h['P']]
    assert t.lower() in importa or t.lower() in BA, t
    icono = plantilla[:i] + t.encode().ljust(260, b'\0') + plantilla[i + 260:]
    assert len(icono) == len(plantilla)
    nombre = f'UI\\HealthBarsHorizontal\\HealthIcon{h["P"]}.mdx'
    (out_dir / f'HealthIcon{h["P"]}.mdx').write_bytes(icono)
    extra.append((nombre, out_dir / f'HealthIcon{h["P"]}.mdx'))

nombre = {k: str(p.relative_to(f2)).replace('/', '\\') for k, p in importa.items()}
with open(tsv, 'w', encoding='latin-1') as t:
    for k in sorted(importa):
        t.write(f'{nombre[k]}\t{importa[k]}\n')
    for n, p in extra:
        t.write(f'{n}\t{p}\n')
print('recursos:', len(importa), 'nuevos +', len(extra), 'iconos de vida;', len(iguales), 'ya estaban iguales;',
      round(sum(p.stat().st_size for p in importa.values()) / 1e6, 1), 'MB')
