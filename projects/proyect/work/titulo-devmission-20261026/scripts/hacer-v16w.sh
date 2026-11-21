#!/bin/bash
# v16w (13/11/2026): v16v con -pj N corregido (pj_v16w.py): no dependía de la entrada directa. Sólo cambia el j.
# Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16v.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16w-hacer; mkdir -p $P
F=/home/snz/Documentos/ChatGPT/Proyect/work/devmission-don18c-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16v.w3x; O=TerrainDev-Titulo-v16w.w3x
echo "f5a942481024eda58e445d15b96098d0af0f55494059ead1fdb3b9bff2b51d60  $B" | sha256sum -c --quiet || exit 1
case $P in /tmp/claude-1000/*) for d in base re; do [ -d "$P/$d" ] && rm -rf -- "$P/$d"; done;; *) exit 1;; esac
$W mpq extract-all $B -o $P/base > /dev/null || exit 1
cmp -s $P/base/war3map.j v16v/war3map.j || { echo "v16v/war3map.j no es el del mapa v16v"; exit 1; }
mkdir -p v16w
python3 -I scripts/pj_v16w.py v16v/war3map.j v16w/war3map.j || exit 1
$PJ v16w/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16w/war3map.j | tail -8; exit 1; }
python3 -I - $P/base $P/tabla.tsv "$PWD/v16w" <<'PY' || exit 1
import sys
from pathlib import Path
b, out, g = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
filas = []
for p in sorted(b.rglob('*')):
    n = str(p.relative_to(b)).replace('/', '\\')
    if p.is_file() and n.lower() not in ('(listfile)', '(attributes)'):
        filas.append((n, f'{g}/{n}' if n == 'war3map.j' else str(p)))
assert 'war3map.j' in {n for n, _ in filas}
open(out, 'w', encoding='latin-1').write(''.join(f'{n}\t{f}\n' for n, f in filas))
print('entradas', len(filas))
PY
python3 -I $F/scripts/mpq_escribir.py $P/tabla.tsv $B $O || exit 1
$W mpq extract-all $O -o $P/re > /dev/null || exit 1
python3 -I - $P/tabla.tsv $P/re <<'PY' || exit 1
import sys, hashlib
from pathlib import Path
tsv, re_d = sys.argv[1], Path(sys.argv[2])
n = mal = 0
for l in open(tsv, encoding='latin-1'):
    nombre, src = l.rstrip('\n').split('\t')
    f = re_d / nombre.replace('\\', '/')
    if not f.is_file() or hashlib.sha256(f.read_bytes()).digest() != hashlib.sha256(open(src, 'rb').read()).digest():
        mal += 1; print('distinto:', nombre)
    n += 1
print('reextraídos', n, 'distintos', mal)
sys.exit(1 if mal else 0)
PY
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
