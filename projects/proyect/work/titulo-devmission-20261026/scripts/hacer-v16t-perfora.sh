#!/bin/bash
# v16t-perfora (13/11/2026): v16t-rapidas con misil a 1000, ráfagas más precisas, escopeta de 3 perdigones grandes
# (modelo x5/3 con partículas y estelas, radio 50) y perforación (escopeta tier-1, fusil de asalto 1, francotirador
# 2..7). j: scripts/perfora_v16t.py; modelos: scripts/escalar_mdx.cjs en FirebrandShots\Grande\ (nuevos; los de
# siempre siguen para Rapid Fire). Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16t-rapidas.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-perfora-hacer; mkdir -p $P
F=/home/snz/Documentos/ChatGPT/Proyect/work/devmission-don18c-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-rapidas.w3x; O=TerrainDev-Titulo-v16t-perfora.w3x; G="$PWD/v16t-perfora"
echo "bbefceb200afb32111371e1e9b37e0aa2864e22c27f4cbce2c318f947f75334f  $B" | sha256sum -c --quiet || exit 1
case $P in /tmp/claude-1000/*) for d in base re; do [ -d "$P/$d" ] && rm -rf -- "$P/$d"; done;; *) exit 1;; esac
$W mpq extract-all $B -o $P/base > /dev/null || exit 1
cmp -s $P/base/war3map.j v16t-rapidas/war3map.j || { echo "la base no coincide con v16t-rapidas/war3map.j"; exit 1; }
mkdir -p "$G/FirebrandShots/Grande"
: > $P/nuevos.txt
for c in Blue Green Orange Pink Purple Red Silver Teal Yellow; do
  n="FirebrandShots/Grande/Firebrand Shot $c.mdx"
  node scripts/escalar_mdx.cjs "$P/base/FirebrandShots/Firebrand Shot $c.mdx" "$G/$n" 1.6666667 > /dev/null || exit 1
  echo "$n" >> $P/nuevos.txt
done
python3 -I scripts/perfora_v16t.py v16t-rapidas/war3map.j "$G/war3map.j" > $P/tabla-armas.txt || exit 1
$PJ "$G/war3map.j" | tail -1 | grep -q '^Parse successful' || { $PJ "$G/war3map.j" | tail -8; exit 1; }
python3 -I - $P/base $P/tabla.tsv "$G" $P/nuevos.txt <<'PY' || exit 1
import sys
from pathlib import Path
b, out, g, nuevos = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
filas = []
for p in sorted(b.rglob('*')):
    n = str(p.relative_to(b)).replace('/', '\\')
    if p.is_file() and n.lower() not in ('(listfile)', '(attributes)'):
        filas.append((n, f"{g}/war3map.j" if n == 'war3map.j' else str(p)))
for l in open(nuevos, encoding='latin-1'):
    n = l.strip().replace('/', '\\')
    assert n not in {x for x, _ in filas}, n
    filas.append((n, f"{g}/{l.strip()}"))
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
$W mpq bytes-diff $B $O > $P/dif.txt; grep -m3 'only in\|DIFFERS\|identical' $P/dif.txt | cut -c1-120
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
