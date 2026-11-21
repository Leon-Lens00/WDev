#!/bin/bash
# v16u (13/11/2026): Freezer, Future Trunks y Naruto de Battle Stadium D.O.N 1.8c sobre v16t-gokum, a petición de Leon
# ("traemos a freezer, thunks del futuro y naruto", con el método de Goku). Celdas propias del título: Goku 2, Freezer 3,
# Trunks 4, Naruto 5; la celda 0 vuelve a ser el Tauren. Código: don_heroe.py (trasplante genérico) -> don_misil.py
# (movimiento con Missile y GroundCollision) -> don_v16u.py (integración); objetos_v16u.py; recursos_v16u.py; datos de
# los héroes en don_heroes.py. Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16t-gokum.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16u-hacer; mkdir -p $P
F=/home/snz/Documentos/ChatGPT/Proyect/work/devmission-don18c-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-gokum.w3x; O=TerrainDev-Titulo-v16u.w3x; F2=$F/DevMission-DON18c-f2.w3x
sha256sum -c --quiet <<EOF || exit 1
7fb3f034c25bc18d92607522ea90b762f63dc1c82d343706842ef8da462aca85  $F/BattlestadiumDON-1.8c-original.w3x
8da58de918012ef9597a08b4cecbe18281e99d8a142b51ed2e79acbed5928b0b  $F2
8a280ec4e1a3845d81d5612f7db11e8b10184b60f5a607d34aaddb9e93d3d574  $B
EOF
# temporales del build en el scratchpad (gio trash no cruza de /tmp a la papelera)
case $P in /tmp/claude-1000/*) for d in f2 gm re don; do [ -d "$P/$d" ] && rm -rf -- "$P/$d"; done;; *) exit 1;; esac
mkdir -p $P/don
$W mpq extract-all $B -o $P/gm > /dev/null || exit 1
$W mpq extract-all $F2 -o $P/f2 > /dev/null || exit 1
cmp -s $P/gm/war3map.j v16t-gokum/war3map.j || { echo "v16t-gokum/war3map.j no es el del mapa v16t-gokum"; exit 1; }
$W extract $F/BattlestadiumDON-1.8c-original.w3x war3map.j -o $P/don.j > /dev/null || exit 1
for h in "Fz:Ct Ty At Bt ct:" "Tr:dt Lu bB aB SA:" "Na:Au Ja Cy yu Uv jB:H01A=hNar,H0D9=hNaK"; do
  p=${h%%:*}; r=${h#*:}; t=${r%%:*}; m=${r#*:}
  python3 -I scripts/don_heroe.py $P/don.j $p "$t" $P/don/$p-glob.j $P/don/$p-func.j $P/don/$p-ids.txt $P/don/$p-inf.txt "$m" || exit 1
  python3 -I scripts/don_misil.py $p $P/don/$p-func.j $P/don/$p-inf.txt || exit 1
done
mkdir -p v16u
python3 -I scripts/objetos_v16u.py $P/f2 $P/gm $P/don v16u || exit 1
python3 -I scripts/don_v16u.py v16t-gokum/war3map.j $P/don v16u v16u/war3map.j || exit 1
$PJ v16u/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16u/war3map.j | tail -8; exit 1; }
python3 -I scripts/recursos_v16u.py $P/f2 $P/gm v16u v16u $P/recursos.tsv $P/don/Fz-func.j $P/don/Tr-func.j $P/don/Na-func.j || exit 1
cp $P/recursos.tsv v16u/recursos.tsv; cat $P/don/*-inf.txt > v16u/trasplante.txt
# tabla del mapa: todo v16t-gokum (sin listfile ni attributes), con j y objetos nuevos, más los recursos nuevos
python3 -I - $P/gm $P/recursos.tsv $P/tabla.tsv "$PWD/v16u" <<'PY' || exit 1
import sys
from pathlib import Path
gm, rec, out, g = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
NUEVO = {'war3map.j', 'war3map.w3u', 'war3map.w3a', 'war3map.w3h', 'war3map.w3b'}
filas = []
for p in sorted(gm.rglob('*')):
    n = str(p.relative_to(gm)).replace('/', '\\')
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
