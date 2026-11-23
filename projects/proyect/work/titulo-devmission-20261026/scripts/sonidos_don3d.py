#!/usr/bin/env python3
"""v21e (22/11/2026): sonidos de los personajes D.O.N como sonidos 3D (Leon: que no se oigan en todo el mapa, como
los disparos de v17d; para todos los personajes D.O.N, no sólo Goku).

Un sonido 3D tiene que ser mono. Lee las rutas war3mapImported de los CreateSound de los JASS dados (Goku 2.1a,
Freezer, Trunks y Naruto) y, para cada una, el archivo que usa el mapa (el nuestro; si no, el importado de 2.1a en
RECURSOS_DIR; si falta el .mp3 se prueba el .wav del mismo nombre):
  - mono: se usa tal cual (misma ruta, sin importar nada nuevo);
  - estéreo: war3mapImported\\M3D_<nombre>.mp3, mono 22050 Hz 64 kb/s (ffmpeg).
Las rutas de los archivos del juego (Sound\\..., Units\\..., Abilities\\...) no se tocan.
Escribe SALIDA.tsv (imports nuevos: ruta del MPQ <tab> archivo) y CAMBIOS.tsv (ruta del código <tab> ruta nueva).
Uso: sonidos_don3d.py RECURSOS_DIR NUESTRO_EXTRAIDO SALIDA_DIR SALIDA.tsv CAMBIOS.tsv JASS...
"""
from pathlib import Path
import json, re, subprocess, sys

rec, nuestro, out_dir, tsv, cambios = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]), sys.argv[4], sys.argv[5]
rutas = set()
for j in sys.argv[6:]:
    t = Path(j).read_bytes().decode('latin-1')
    rutas |= {m.replace('\\\\', '\\') for m in re.findall(r'CreateSound\("(war3mapImported\\\\[^"]+)"', t)}


def busca(r):
    nombre = r.split('\\', 1)[1]
    cands = [nombre]
    if nombre.lower().endswith('.mp3'):
        cands.append(nombre[:-4] + '.wav')
    for c in cands:
        for base in (nuestro, rec):
            p = base / 'war3mapImported' / c
            if p.is_file():
                return 'war3mapImported\\' + c, p
    raise SystemExit('falta el sonido ' + r)


d = out_dir / 'war3mapImported'
d.mkdir(parents=True, exist_ok=True)
nuevos, cambio, mono = [], [], 0
for r in sorted(rutas):
    real, p = busca(r)
    ch = json.loads(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'stream=channels', '-of', 'json', str(p)],
                                   check=True, capture_output=True, text=True).stdout)['streams'][0]['channels']
    if ch == 1:
        mono += 1
        if real != r:
            cambio.append((r, real))
        continue
    n = 'M3D_' + re.sub(r'[^A-Za-z0-9_]', '', Path(real.split('\\', 1)[1]).stem) + '.mp3'
    o = d / n
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(p), '-ac', '1', '-ar', '22050', '-c:a', 'libmp3lame',
                    '-b:a', '64k', '-map_metadata', '-1', str(o)], check=True)
    nuevos.append(('war3mapImported\\' + n, o))
    cambio.append((r, 'war3mapImported\\' + n))
with open(tsv, 'w') as t:
    t.writelines(f'{n}\t{o}\n' for n, o in nuevos)
with open(cambios, 'w') as t:
    t.writelines(f'{a}\t{b}\n' for a, b in cambio)
print('sonidos:', len(rutas), '| mono', mono, '| a mono', len(nuevos), ':', ', '.join(n for n, _ in nuevos), '|',
      round(sum(o.stat().st_size for _, o in nuevos) / 1e6, 2), 'MB nuevos')
