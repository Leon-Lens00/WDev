#!/bin/bash
# v21w (22/11/2026): botón X (Power Up, ATr1) en el controlador de Trunks, con el icono de 2.1a.
# Normal sobre v21v; prueba sobre v21v-prueba. Cambian el j (v21w.py) y el w3a (objetos_v21w.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21w-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p fuentes/v21w-obj
python3 -I scripts/objetos_v21w.py fuentes/v21v-obj/war3map.w3a fuentes/v21w-obj/war3map.w3a > /dev/null || exit 1
for par in "v21v 4884bb389c7fc787d851171962f5218b88a720341ae2808a772db57e29e4abe9 v21w normal" \
           "v21v-prueba 2093f2e3250187c4d00f7ce257141243159ee1a54288b12d3e44c4ade3e4218e v21w-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B war3map.w3a -o $P/base.w3a > /dev/null || exit 1
  cmp -s $P/base.w3a fuentes/v21v-obj/war3map.w3a || { echo "$N: el w3a de la base no es el de v21v"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21w.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp fuentes/v21w-obj/war3map.w3a $N/war3map.w3a
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
