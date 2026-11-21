#!/bin/bash
# v19u (19/11/2026): fase 2: Zancada sobre GroundMotion, Espinas (carta 13) con tope, sin Caparazón espinoso al azar
# (v19u.py). Normal sobre v19t; prueba sobre v19t-prueba. Sólo cambia war3map.j.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19u-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v19t 04264a4a5dcdc380e0a175fa399daa8b7830c719d29f6b3100435d6d9c92b31f v19u normal" \
           "v19t-prueba efbf156c9ab1a6f1bf0817a8d856c79d2a03df7a57344a998ad969d6db97d3f3 v19u-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19u.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.j " ] || [ "$D" = "(attributes) war3map.j " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: sólo war3map.j cambiado; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
