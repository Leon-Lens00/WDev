#!/bin/bash
# v21k (22/11/2026): la Q (Kamehameha) se queda en el árbol o pendiente donde choca; antes saltaba al otro lado a
# los pocos ticks. Sólo cambia el j (v21k.py). Normal sobre v21j; prueba sobre v21j-prueba.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21k-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
OBJ=""
: > $P/imports.tsv
for par in "v21j 444a0f1c84ce93824580529401a59248f3440cd8b684002dcb0212e8a0087719 v21k normal" \
           "v21j-prueba 292e3bc106e83d62dad5adb3c9ab1d069a5653921e5e6906a1e0687d796e87b8 v21k-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B war3map.w3a -o $E/war3map.w3a > /dev/null || exit 1
  cmp -s $E/war3map.w3a fuentes/v21i-obj/war3map.w3a || { echo "$N: el w3a de la base no es el de objetos_v21i.py"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21k.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; [ $k -gt 1 ] && rm -f -- $P/c$((k-1)).w3x; cur=$P/c$k.w3x; }
  add war3map.j $N/war3map.j
  while IFS=$'\t' read -r n f; do add "$n" "$f"; done < $P/imports.tsv
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "$N: reextracción de $n distinta"; exit 1; }
  done < $P/imports.tsv
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: $(grep -ci 'only in' $P/$N-diff.txt) líneas 'only in'"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
