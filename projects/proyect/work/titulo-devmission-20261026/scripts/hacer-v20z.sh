#!/bin/bash
# v20z (21/11/2026): pulls comprados para Armas y Habilidades (cola), páginas de iconos del héroe, rachas con icono y
# sin voz, piezas del cuadro MVP como las de retrato y modelos MVP sin partículas ni eventos.
# Normal sobre v20y; prueba sobre v20y-prueba. Cambian el j (v20z.py), el w3u (objetos_v20z.py) y los 7 MvpFrente*.mdx
# (mvp_limpio.cjs sobre mvp-frente/). La LAN usa el normal (map.cfg aparte).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20z-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
NOMS="Tauren Cairne Goku Freezer Trunks Naruto Kyuubi"
mkdir -p mvp-frente/limpio
for g in $NOMS; do node scripts/mvp_limpio.cjs mvp-frente/MvpFrente$g.mdx mvp-frente/limpio/MvpFrente$g.mdx > /dev/null || exit 1; done
for par in "v20y 71012d2437a84e38dcdc7b216cdfdc4174b21ab9f3100ca9646ff432355c8875 v20z normal" \
           "v20y-prueba e36ca6c21be5bec816bf120d4458a0c5d824553c9d710a3bb3ac575aa6197d17 v20z-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v20z.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W extract $B war3map.w3u -o $P/base.w3u > /dev/null || exit 1
  python3 -I scripts/objetos_v20z.py $P/base.w3u $N/war3map.w3u > /dev/null || exit 1
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  add war3map.j $N/war3map.j
  add war3map.w3u $N/war3map.w3u
  for g in $NOMS; do add "war3mapImported\\MvpFrente$g.mdx" mvp-frente/limpio/MvpFrente$g.mdx; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for g in $NOMS; do
    $W extract $O "war3mapImported\\MvpFrente$g.mdx" -o $P/re > /dev/null && cmp -s $P/re mvp-frente/limpio/MvpFrente$g.mdx || { echo "$N: reextracción de MvpFrente$g distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  E=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|war3map\.w3u|war3mapImported\\MvpFrente(Tauren|Cairne|Goku|Freezer|Trunks|Naruto|Kyuubi)\.mdx|' )
  [ -z "$E" ] || { echo "$N: cambió algo más: $E"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# LAN rojo y amarillo: el mapa normal tal cual (sin registros), y map.cfg para ydhost con azul, verde azulado y morado cerrados.
N=v20z-lan; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
cp TerrainDev-Titulo-v20z.w3x $O; cmp -s TerrainDev-Titulo-v20z.w3x $O || exit 1
Y=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all $O -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $O $P/lanx $Y/compiler/jass/24/common.j $Y/compiler/jass/24/blizzard.j > $P/map.cfg || exit 1
python3 -I - $P/map.cfg $N/map.cfg <<'PY'
import sys, re
t = open(sys.argv[1]).read().splitlines()
out = []
for l in t:
    m = re.match(r'map_slot(\d+) = (.*)', l)
    if m:
        f = m.group(2).split()
        if f[5] in ('1', '2', '3'):
            f[2] = '1'
        l = f'map_slot{m.group(1)} = ' + ' '.join(f)
    out.append(l)
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
PY
grep '^map_slot' $N/map.cfg
sha256sum $O $N/map.cfg
