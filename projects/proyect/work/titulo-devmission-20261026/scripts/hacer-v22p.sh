#!/bin/bash
# v22p (23/11/2026): la Estampida crece con el tier (más filas y kodos más rápidos); bases de Guardianes 750 y
# Estampida 3000. Normal sobre v22o; prueba sobre v22o-prueba. Cambian el j (v22p.py) y el w3a (objetos_v22p.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v22p-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v22o f23afaf49b7d59757225ff76c8e03ac9a688ece0a484437755104bda96fca492 v22p normal" \
           "v22o-prueba b21b0b7acce245218307290af198cdccad9c4435e45375a6b2682c1f92abde5f v22p-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v22p.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  $W extract $B war3map.w3a -o $P/in.w3a > /dev/null || exit 1
  [ "$(sha256sum $P/in.w3a | cut -c1-16)" = df07d2a2f77bd79b ] || { echo "$N: w3a de la base distinto"; exit 1; }
  python3 -I scripts/objetos_v22p.py $P/in.w3a $N/war3map.w3a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c1.w3x > /dev/null || exit 1
  $W mpq add $P/c1.w3x war3map.w3a --file $N/war3map.w3a -o $P/c2.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c2.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.(j|w3a)|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# copias en WOE (Maps/Test), comprobadas byte a byte
WOE=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII/Maps/Test
for N in v22p v22p-prueba; do
  cp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && cmp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && echo "WOE $N: copiado"
done
