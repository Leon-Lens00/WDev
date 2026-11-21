#!/bin/bash
# v16t-gokum (13/11/2026): v16t-goku con el movimiento de las habilidades de Goku en Missile (goku_misil.py), a petición de Leon.
# Goku es una unidad normal de la pareja de Dev Mission (fila del Tauren h005) y la elige la celda 0 del título; sus
# habilidades reales van en el cuerpo y el controlador lleva 5 botones puente (1 de maná, sin enfriamiento). Código de
# D.O.N trasplantado (goku_trasplante.py) e integrado (goku_v16t.py); objetos (objetos_goku.py); recursos del mapa f2
# (recursos_goku.py). Plan: Proyect/docs/planes/devmission-goku-v16t.md. No sustituye a v16t-ivan.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-gokum-hacer; mkdir -p $P
F=/home/snz/Documentos/ChatGPT/Proyect/work/devmission-don18c-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-ivan.w3x; O=TerrainDev-Titulo-v16t-gokum.w3x; F2=$F/DevMission-DON18c-f2.w3x
sha256sum -c --quiet <<EOF || exit 1
7fb3f034c25bc18d92607522ea90b762f63dc1c82d343706842ef8da462aca85  $F/BattlestadiumDON-1.8c-original.w3x
8da58de918012ef9597a08b4cecbe18281e99d8a142b51ed2e79acbed5928b0b  $F2
EOF
# temporales del build en el scratchpad (gio trash no cruza de /tmp a la papelera)
case $P in /tmp/claude-1000/*) for d in f2 iv re; do [ -d "$P/$d" ] && rm -rf -- "$P/$d"; done;; *) exit 1;; esac
$W mpq extract-all $B -o $P/iv > /dev/null || exit 1
$W mpq extract-all $F2 -o $P/f2 > /dev/null || exit 1
cmp -s $P/iv/war3map.j v16t-ivan/war3map.j || { echo "v16t-ivan/war3map.j no es el del mapa v16t-ivan"; exit 1; }
$W extract $F/BattlestadiumDON-1.8c-original.w3x war3map.j -o $P/don.j > /dev/null || exit 1
mkdir -p v16t-gokum
python3 -I scripts/goku_trasplante.py $P/don.j $P/glob.j $P/func.j $P/ids.txt || exit 1
python3 -I scripts/goku_misil.py $P/glob.j $P/func.j || exit 1
python3 -I scripts/goku_v16t.py v16t-ivan/war3map.j $P/glob.j $P/func.j v16t-gokum/war3map.j || exit 1
$PJ v16t-gokum/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-gokum/war3map.j | tail -8; exit 1; }
python3 -I scripts/objetos_goku.py $P/f2/war3map.w3u $P/f2/war3map.w3a $P/f2/war3map.w3h $P/ids.txt \
  $P/iv/war3map.w3u $P/iv/war3map.w3a $P/iv/war3map.w3h v16t-gokum/war3map.w3u v16t-gokum/war3map.w3a v16t-gokum/war3map.w3h || exit 1
python3 -I scripts/recursos_goku.py $P/f2 $P/iv v16t-gokum/war3map.w3u v16t-gokum/war3map.w3a v16t-gokum/war3map.w3h $P/func.j v16t-gokum $P/recursos.tsv || exit 1
cp $P/recursos.tsv v16t-gokum/recursos.tsv
# tabla del mapa: todo v16t-ivan (sin listfile ni attributes), con j y objetos nuevos, más los recursos de Goku
python3 -I - $P/iv $P/recursos.tsv $P/tabla.tsv "$PWD/v16t-gokum" <<'PY' || exit 1
import sys
from pathlib import Path
iv, rec, out, g = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
NUEVO = {'war3map.j', 'war3map.w3u', 'war3map.w3a', 'war3map.w3h'}
filas = []
for p in sorted(iv.rglob('*')):
    n = str(p.relative_to(iv)).replace('/', '\\')
    if p.is_file() and n.lower() not in ('(listfile)', '(attributes)'):
        filas.append((n, f'{g}/{n}' if n in NUEVO else str(p)))
assert {n for n, _ in filas} >= NUEVO
vistos = {n.lower() for n, _ in filas}
for l in open(rec, encoding='latin-1'):
    n, f = l.rstrip('\n').split('\t')
    assert n.lower() not in vistos, n
    vistos.add(n.lower()); filas.append((n, f))
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
