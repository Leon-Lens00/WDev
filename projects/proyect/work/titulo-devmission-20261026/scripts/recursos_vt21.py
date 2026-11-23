#!/usr/bin/env python3
"""v22d (23/11/2026): recursos de Vegito de D.O.N 2.1a que faltan en Dev Mission.

Como recursos_vg21.py (v22b): las rutas que citan las filas nuevas o cambiadas (IDS), el código trasplantado y el
cuerpo de Vegito, y dentro de cada modelo sus texturas y modelos, sacadas de la extracción de 2.1a. Una ruta que ya está
en Dev Mission con el mismo contenido no se importa; con otro, se queda la nuestra y se anota.
NUESTRO: carpetas con los recursos de la base (v22c).
Genera (retrato_vt21.cjs, mvp_frente.cjs, mvp_limpio.cjs):
  war3mapImported\\Vegito21.mdx                 cuerpo y copia ("Vegetto SS_squished.mdx" de 2.1a, ya con cabeza, con
                                                otro nombre para que su retrato sea propio)
  war3mapImported\\Vegito21_portrait.mdx        retrato con la cámara delante de la cabeza
  war3mapImported\\MvpFrenteVegito21.mdx        frente del MVP
  UI\\HealthBarsHorizontal\\HealthIconVt.mdx     HealthIconTauren con BTNGogeta.blp
Uso: recursos_vt21.py INDICE.tsv EXTRAIDO_21A_BASE OBJ_DIR IDS FUNCIONES.j SALIDA_DIR SALIDA.tsv INFORME NUESTRO...
"""
from pathlib import Path
import re, subprocess, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse
from objetos_v12k import parse_w3a

indice, base21, obj_dir, ids, fj, out_dir, tsv, inf_path = sys.argv[1:9]
nuestros = [Path(x) for x in sys.argv[9:]]
base21, obj_dir, out_dir = Path(base21), Path(obj_dir), Path(out_dir)
ESC = Path(__file__).resolve().parent
I21 = {}
for l in open(indice, encoding='latin-1'):
    a, b = l.rstrip('\n').split('\t')
    I21[a.lower()] = (a, base21 / b)
OURS = {}
for d in nuestros:
    for p in d.rglob('*'):
        if p.is_file():
            OURS.setdefault(str(p.relative_to(d)).replace('/', '\\').lower(), p)
RUTA = re.compile(rb'[A-Za-z0-9_\-\\/ .()!&\'#,+]{1,200}?\.(?:mdl|mdx|blp|tga|wav|mp3)', re.I)
rutas = lambda b: {m.group(0).decode('latin-1').replace('\\\\', '\\') for m in RUTA.finditer(b)}
MODELO21 = 'war3mapimported\\vegetto ss_squished.mdx'
assert MODELO21 in I21 and MODELO21 not in OURS

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
pend |= rutas(I21[MODELO21][1].read_bytes())  # texturas del cuerpo de Vegito


def variantes(p):
    p = re.sub(r'\\+', r'\\', p.replace('/', '\\')).strip()
    out = {p}
    if p.lower().endswith('.mdl'):
        out.add(p[:-4] + '.mdx')
    if p.lower().endswith('.tga'):
        out.add(p[:-4] + '.blp')
    return out


importa, iguales, nuestras = {}, [], []
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

out_dir.mkdir(parents=True, exist_ok=True)
filas = []


def pon(nombre, datos):
    assert nombre.lower() not in OURS, nombre
    d = out_dir / nombre.replace('\\', '/')
    d.parent.mkdir(parents=True, exist_ok=True)
    d.write_bytes(datos)
    filas.append((nombre, d))


for k in sorted(importa):
    pon(importa[k][0], importa[k][1].read_bytes())

# --- cuerpo, retrato y frente del MVP ---
W = out_dir / 'war3mapImported'
W.mkdir(parents=True, exist_ok=True)
tmpd = out_dir / '_tmp'
tmpd.mkdir(exist_ok=True)
cuerpo, retrato = W / 'Vegito21.mdx', W / 'Vegito21_portrait.mdx'
cuerpo.write_bytes(I21[MODELO21][1].read_bytes())
subprocess.run(['node', str(ESC / 'retrato_vt21.cjs'), str(cuerpo), str(retrato)], check=True, stdout=subprocess.DEVNULL)
tmp = tmpd / '_mvp_frente.mdx'
subprocess.run(['node', str(ESC / 'mvp_frente.cjs'), str(cuerpo), str(tmp)], check=True, stdout=subprocess.DEVNULL)
fr = W / 'MvpFrenteVegito21.mdx'
subprocess.run(['node', str(ESC / 'mvp_limpio.cjs'), str(tmp), str(fr)], check=True, stdout=subprocess.DEVNULL)
for p in tmpd.iterdir():
    p.unlink()
tmpd.rmdir()
for n, d in [('Vegito21.mdx', cuerpo), ('Vegito21_portrait.mdx', retrato), ('MvpFrenteVegito21.mdx', fr)]:
    assert ('war3mapimported\\' + n.lower()) not in OURS, n
    filas.append(('war3mapImported\\' + n, d))
# --- barra de vida ---
plantilla = OURS['ui\\healthbarshorizontal\\healthicontauren.mdx'].read_bytes()
viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
assert plantilla.count(viejo) == 1
i = plantilla.index(viejo)
icono = plantilla[:i] + b'war3mapImported\\BTNGogeta.blp'.ljust(260, b'\0') + plantilla[i + 260:]
assert len(icono) == len(plantilla)
pon('UI\\HealthBarsHorizontal\\HealthIconVt.mdx', icono)
assert any(n.lower() == 'war3mapimported\\btngogeta.blp' for n, _ in filas), 'falta el icono'
with open(tsv, 'w') as t:
    for n, d in filas:
        t.write(f'{n}\t{d}\n')
with open(inf_path, 'w') as o:
    o.write(f'importados {len(filas)}; iguales {len(iguales)}\n')
    o.write('con otro contenido en 2.1a, se queda la nuestra: ' + ' | '.join(sorted(nuestras)) + '\n')
print('recursos:', len(filas), 'archivos,', round(sum(d.stat().st_size for _, d in filas) / 1e6, 2), 'MB;',
      len(iguales), 'iguales;', len(nuestras), 'se quedan los nuestros:', ' | '.join(sorted(nuestras)))
