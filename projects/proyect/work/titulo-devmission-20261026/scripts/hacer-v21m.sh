#!/bin/bash
# v21m (22/11/2026): tiers de Q, W y R de Goku (daño como el cargador de un arma roja), sin maná y con recargas
# largas. Normal sobre v21l; prueba sobre v21l-prueba. Cambian el j (v21m.py) y el w3a (objetos_v21m.py, en fuentes/v21m-obj).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21m-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
OBJ="war3map.w3a"
: > $P/imports.tsv
for par in "v21l 80a935a0725517534efc76cd3c5ef1f73df48547a34410f9409d9ecfe2219a34 v21m normal" \
           "v21l-prueba 8e49586069a28966999a542cf0e6fd8cb0f06eec6060359847f1f8d2c965ad43 v21m-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B war3map.w3a -o $E/war3map.w3a > /dev/null || exit 1
  cmp -s $E/war3map.w3a fuentes/v21i-obj/war3map.w3a || { echo "$N: el w3a de la base no es el de objetos_v21i.py"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21m.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  cp fuentes/v21m-obj/war3map.w3a $N/war3map.w3a
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; [ $k -gt 1 ] && rm -f -- $P/c$((k-1)).w3x; cur=$P/c$k.w3x; }
  for f in war3map.j $OBJ; do add $f $N/$f; done
  while IFS=$'\t' read -r n f; do add "$n" "$f"; done < $P/imports.tsv
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j $OBJ; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "$N: reextracción de $n distinta"; exit 1; }
  done < $P/imports.tsv
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.(j|w3a)|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: $(grep -ci 'only in' $P/$N-diff.txt) líneas 'only in'"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
