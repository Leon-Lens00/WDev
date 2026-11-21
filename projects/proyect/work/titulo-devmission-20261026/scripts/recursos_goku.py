#!/usr/bin/env python3
"""v16t-goku (13/11/2026): recursos de Goku de D.O.N 1.8c que faltan en v16t-ivan.

Busca las rutas citadas por los objetos nuevos y por el código trasplantado (modelos, iconos, sonidos), y dentro de
cada modelo las texturas y modelos que pide, hasta que no aparecen más. Cada ruta se toma del mapa f2 (D.O.N 1.8c con
los nombres recuperados y las rutas DON_ que chocaban con Dev Mission). Una ruta que ya está en v16t-ivan con el mismo
contenido no se importa; con otro contenido es un error. Escribe también HealthIconGoku.mdx: HealthIconTauren de
v16t-ivan con la textura del icono de Goku.
Uso: recursos_goku.py F2_EXTRAIDO IVAN_EXTRAIDO OBJ.w3u OBJ.w3a OBJ.w3h FUNCIONES.j SALIDA_DIR SALIDA.tsv
"""
from pathlib import Path
import re, sys

f2, iv, ou, oa, oh, fj, out_dir, tsv = sys.argv[1:9]
f2, iv, out_dir = Path(f2), Path(iv), Path(out_dir)
indice = lambda d: {str(p.relative_to(d)).replace('/', '\\').lower(): p for p in d.rglob('*') if p.is_file()}
F2, IV = indice(f2), indice(iv)
RUTA = re.compile(rb'[A-Za-z0-9_\-\\/ .()!&\'#,+]{1,200}?\.(?:mdl|mdx|blp|tga|wav|mp3)', re.I)


def rutas(b):
    return {m.group(0).decode('latin-1').replace('\\\\', '\\') for m in RUTA.finditer(b)}


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
for f in (ou, oa, oh, fj):
    pend |= rutas(Path(f).read_bytes())
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
        if k in IV:
            assert IV[k].read_bytes() == b, f'{v} ya está en v16t-ivan con otro contenido'
            iguales.append(v)
            continue
        importa[k] = F2[k]
        if k.endswith('.mdx'):
            pend |= rutas(b)

# icono de vida de Goku: el de Tauren con la textura de Goku (bloque TEXS de 268 bytes por textura)
base = IV['ui\\healthbarshorizontal\\healthicontauren.mdx'].read_bytes()
viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
nuevo = b'war3mapImported\\BTNSaiyanForm.blp'
assert base.count(viejo) == 1 and 'war3mapimported\\btnsaiyanform.blp' in importa
i = base.index(viejo)
icono = base[:i] + nuevo.ljust(260, b'\0') + base[i + 260:]
assert len(icono) == len(base)
out_dir.mkdir(parents=True, exist_ok=True)
(out_dir / 'HealthIconGoku.mdx').write_bytes(icono)

nombre = {str(p.relative_to(f2)).replace('/', '\\').lower(): str(p.relative_to(f2)).replace('/', '\\') for p in importa.values()}
with open(tsv, 'w') as t:
    for k in sorted(importa):
        t.write(f'{nombre[k]}\t{importa[k]}\n')
    t.write(f'UI\\HealthBarsHorizontal\\HealthIconGoku.mdx\t{out_dir / "HealthIconGoku.mdx"}\n')
print('recursos:', len(importa), 'nuevos +1 icono;', len(iguales), 'ya estaban iguales;',
      round(sum(p.stat().st_size for p in importa.values()) / 1e6, 1), 'MB')
