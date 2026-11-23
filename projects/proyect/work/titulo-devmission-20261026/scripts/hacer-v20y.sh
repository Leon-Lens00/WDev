#!/bin/bash
# v20y (21/11/2026): botones de compra de pulls centrados y héroe fijo por color (sin selección).
# Normal sobre v20x; prueba sobre v20x-prueba. Sólo cambia el j (v20y.py). La LAN usa el normal (map.cfg aparte).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20y-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v20x 415183c4bc8a328cd3d60a8732b4a80e6df3dde3d45bc452b7d0035913c365d9 v20y normal" \
           "v20x-prueba 45d4ebf15de23fda44d50c3568b3a5a138c09866d50d2441271c43fe514d0910 v20y-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v20y.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j; do add $f $N/$f; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  grep -qxE '\(attributes\)( \(listfile\))? war3map.j' <<< "${D% }" || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# LAN rojo y amarillo: el mapa normal tal cual (sin registros), y map.cfg para ydhost con azul, verde azulado y morado cerrados.
N=v20y-lan; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
cp TerrainDev-Titulo-v20y.w3x $O; cmp -s TerrainDev-Titulo-v20y.w3x $O || exit 1
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
