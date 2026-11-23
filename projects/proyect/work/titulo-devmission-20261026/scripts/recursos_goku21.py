#!/usr/bin/env python3
"""v21e (22/11/2026): recursos de Goku de D.O.N 2.1a que faltan en Dev Mission.

Busca las rutas que citan las filas nuevas o cambiadas (IDS) y el código trasplantado, y dentro de cada modelo las
texturas y modelos que pide, hasta que no aparecen más. Cada ruta sale de la extracción de 2.1a (índice de nombres
recuperados, INDICE). Una ruta que ya está en Dev Mission:
  - con el mismo contenido no se importa;
  - con otro contenido se queda la nuestra (son nuestras versiones aligeradas: sonidos recomprimidos, texturas
    reducidas) y se anota en el informe; salvo las texturas del modelo de Goku, que se importan con otro nombre.
Genera además:
  - Goku21.mdx: war3mapImported\\Goku_squished.mdx de 2.1a con G21_goku_normal.blp y G21_Goku_SS4f.blp (sus texturas
    de 256 chocan con las nuestras de 1.8c). Sin archivo _portrait: el retrato usa el modelo y su cámara Camera01.
  - HealthIconGoku21.mdx: HealthIconTauren con el icono BTNGokuSSB.
  - MvpFrenteGoku21.mdx: mvp_frente.cjs y mvp_limpio.cjs sobre Goku21.mdx.
Copia todo a SALIDA_DIR (rutas del MPQ con / ) y escribe SALIDA.tsv: ruta del MPQ <tab> archivo.
Uso: recursos_goku21.py INDICE.tsv EXTRAIDO_21A_BASE NUESTRO_EXTRAIDO OBJ_DIR IDS FUNCIONES.j SALIDA_DIR SALIDA.tsv INFORME
"""
from pathlib import Path
import re, shutil, struct, subprocess, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse
from objetos_v12k import parse_w3a

indice, base21, nuestro, obj_dir, ids, fj, out_dir, tsv, inf_path = sys.argv[1:10]
base21, nuestro, obj_dir, out_dir = Path(base21), Path(nuestro), Path(obj_dir), Path(out_dir)
ESC = Path(__file__).resolve().parent
I21 = {}
for l in open(indice, encoding='latin-1'):
    a, b = l.rstrip('\n').split('\t')
    I21[a.lower()] = (a, base21 / b)
OURS = {str(p.relative_to(nuestro)).replace('/', '\\').lower(): p for p in nuestro.rglob('*') if p.is_file()}
RUTA = re.compile(rb'[A-Za-z0-9_\-\\/ .()!&\'#,+]{1,200}?\.(?:mdl|mdx|blp|tga|wav|mp3)', re.I)
rutas = lambda b: {m.group(0).decode('latin-1').replace('\\\\', '\\') for m in RUTA.finditer(b)}

ids = set(x.encode() for x in ids.split(','))
pend = set()
for ext, lector in [('w3u', parse), ('w3a', parse_w3a), ('w3h', parse), ('w3b', parse)]:
    _, tab = lector((obj_dir / f'war3map.{ext}').read_bytes())
    for r in tab[1]:
        if r[1] in ids:
            for m in r[2]:
                if isinstance(m[-2], bytes):
                    pend |= rutas(m[-2])
pend |= rutas(Path(fj).read_bytes())


def variantes(p):
    p = re.sub(r'\\+', r'\\', p.replace('/', '\\')).strip()
    out = {p}
    if p.lower().endswith('.mdl'):
        out.add(p[:-4] + '.mdx')
    if p.lower().endswith('.tga'):
        out.add(p[:-4] + '.blp')
    return out


# --- Goku21.mdx con sus dos texturas renombradas ---
TEXS = {b'Textures\\goku_normal.blp': b'war3mapImported\\G21_goku_normal.blp',
        b'Goku_SS4f.blp': b'war3mapImported\\G21_Goku_SS4f.blp'}
gk = I21['war3mapimported\\goku_squished.mdx'][1].read_bytes()
for viejo, nuevo in TEXS.items():
    i = gk.find(viejo + b'\0')
    assert i > 0 and gk.count(viejo + b'\0') == 1, viejo
    gk = gk[:i] + nuevo.ljust(260, b'\0') + gk[i + 260:]
assert len(gk) == I21['war3mapimported\\goku_squished.mdx'][1].stat().st_size
importa, iguales, nuestras = {}, [], []
gen = {'war3mapImported\\Goku21.mdx': gk}
for viejo, nuevo in TEXS.items():
    gen[nuevo.decode()] = I21[viejo.decode().lower()][1].read_bytes()
pend |= rutas(gk) - {t.decode() for t in TEXS.values()}

vistos = set()
while pend:
    p = pend.pop()
    for v in variantes(p):
        k = v.lower()
        if k in vistos or k not in I21:
            continue
        vistos.add(k)
        b = I21[k][1].read_bytes()
        if k in OURS:
            (iguales if OURS[k].read_bytes() == b else nuestras).append(I21[k][0])
            continue
        importa[k] = I21[k]
        if k.endswith('.mdx'):
            pend |= rutas(b)
assert not {t.decode().lower() for t in TEXS.values()} & set(OURS)

# --- icono de vida: el de Tauren con el icono de Goku de 2.1a ---
base = OURS['ui\\healthbarshorizontal\\healthicontauren.mdx'].read_bytes()
viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
assert base.count(viejo) == 1 and 'war3mapimported\\btngokussb.blp' in importa
i = base.index(viejo)
gen['UI\\HealthBarsHorizontal\\HealthIconGoku21.mdx'] = base[:i] + b'war3mapImported\\BTNGokuSSB.blp'.ljust(260, b'\0') + base[i + 260:]

out_dir.mkdir(parents=True, exist_ok=True)
filas = []


def pon(nombre, datos):
    d = out_dir / nombre.replace('\\', '/')
    d.parent.mkdir(parents=True, exist_ok=True)
    d.write_bytes(datos)
    filas.append((nombre, d))


for k in sorted(importa):
    pon(importa[k][0], importa[k][1].read_bytes())
for n in sorted(gen):
    pon(n, gen[n])

# --- frente del MVP ---
tmp = out_dir / '_mvp_frente.mdx'
subprocess.run(['node', str(ESC / 'mvp_frente.cjs'), str(out_dir / 'war3mapImported/Goku21.mdx'), str(tmp)], check=True,
               stdout=subprocess.DEVNULL)
fr = out_dir / 'war3mapImported/MvpFrenteGoku21.mdx'
subprocess.run(['node', str(ESC / 'mvp_limpio.cjs'), str(tmp), str(fr)], check=True, stdout=subprocess.DEVNULL)
tmp.unlink()
filas.append(('war3mapImported\\MvpFrenteGoku21.mdx', fr))

with open(tsv, 'w') as t:
    for n, d in filas:
        t.write(f'{n}\t{d}\n')
with open(inf_path, 'w') as o:
    o.write(f'importados {len(filas)}; iguales {len(iguales)}\n')
    o.write('con otro contenido en 2.1a, se queda la nuestra: ' + ' | '.join(sorted(nuestras)) + '\n')
print('recursos:', len(filas), 'archivos,', round(sum(d.stat().st_size for _, d in filas) / 1e6, 2), 'MB;',
      len(iguales), 'iguales;', len(nuestras), 'se quedan los nuestros')
