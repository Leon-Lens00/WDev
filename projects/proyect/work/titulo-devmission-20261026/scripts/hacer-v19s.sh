#!/bin/bash
# v19s (19/11/2026): textos de los paneles de mejoras, paneles sin burbuja, 75 s de compra e indicadores de la tienda y
# del jefe sin la regla del minimapa y sin cortarse en los bordes (v19s.py, objetos_v19s.py). Normal sobre v19r;
# prueba sobre v19r-prueba. Cambian j, w3u e imp; se quitan CuaBurbujaPan.mdx y CuaBurbujaDet.mdx.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19s-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
FUERA="CuaBurbujaPan.mdx CuaBurbujaDet.mdx"
for par in "v19r 6bd52fbf83b839e1e8597da8e3d1318f0f7d76b83f28a103610a239dd4896f04 v19s normal" \
           "v19r-prueba ecfacfdd0a0f383be8c0d90bbaa85ed3995d8811a45c5fa94e4691cbe8e0bcd4 v19s-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19s.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19s.py $E $N > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  rem() { k=$((k+1)); $W mpq remove $cur "$1" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for t in $FUERA; do rem "war3mapImported\\$t"; done
  for f in war3map.j war3map.w3u war3map.imp; do add $f $N/$f; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $FUERA; do
    $W extract $O "war3mapImported\\$t" -o $P/re > /dev/null 2>&1 && { echo "$N: $t sigue dentro"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3u " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: j, w3u e imp cambiados, burbujas de los paneles fuera; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
