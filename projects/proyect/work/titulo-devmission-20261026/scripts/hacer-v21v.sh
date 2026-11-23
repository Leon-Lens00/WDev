#!/bin/bash
# v21v (22/11/2026): formas de Goku y Trunks por tiempo (50 s), X de Trunks (Power Up), cadencia +25 % y daño de técnicas
# +20 % por forma; retrato de Trunks con cabeza. Normal sobre v21u; prueba sobre v21u-prueba. Cambian el j (v21v.py),
# el w3a (objetos_v21v.py: ATr1 10 s sin maná), el imp y un recurso (retrato_tr21.cjs, fuentes/v21v.tsv).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21v-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
node scripts/retrato_tr21.cjs fuentes/tr21/war3mapImported/TrunkNormal.mdx fuentes/tr21/war3mapImported/TrunkHead.mdx $P/ret.mdx > /dev/null || exit 1
cmp -s $P/ret.mdx fuentes/v21v/war3mapImported/TrunkNormal_portrait.mdx || { echo "el retrato no es el de retrato_tr21.cjs"; exit 1; }
cp fuentes/v21v.tsv $P/imports.tsv
mkdir -p fuentes/v21v-obj
python3 -I scripts/objetos_v21v.py v21t/war3map.w3a fuentes/v21v-obj/war3map.w3a > /dev/null || exit 1
for par in "v21u 149f79babe376ff58d7992eed20a9bdb9b9ca85f820c0456d19d88f620fd7621 v21v normal" \
           "v21u-prueba 641af6eff2a476950ccb794a6b02ee21bcea3afceda36a38fed41dbc97a516a3 v21v-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3a war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  cmp -s $E/war3map.w3a v21t/war3map.w3a || { echo "$N: el w3a de la base no es el de v21t"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21v.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp fuentes/v21v-obj/war3map.w3a $N/war3map.w3a
  python3 -I scripts/imp_v21e.py $E/war3map.imp $N/war3map.imp $P/imports.tsv > /dev/null || exit 1
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; [ $k -gt 1 ] && rm -f -- $P/c$((k-1)).w3x; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3a war3map.imp; do add $f $N/$f; done
  while IFS=$'\t' read -r n f; do add "$n" "$f"; done < $P/imports.tsv
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "$N: reextracción de $n distinta"; exit 1; }
  done < $P/imports.tsv
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.(j|w3a|imp)|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' -A3 $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
