#!/bin/bash
# v19v (19/11/2026): cartas de Mutación Evo con la ventana de la tienda y cuadro de descripción (v19v.py,
# objetos_v19v.py, texturas_v19v.py). Normal sobre v19u; prueba sobre v19u-prueba. Cambian j, w3b e imp; se añaden
# CuaMutCarta.blp y CuaMutDes.blp.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19v-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=texturas-v19v
$PYP -I scripts/texturas_v19v.py ../tienda-prototipo-20261101/texturas $X > /dev/null || exit 1
NUEVOS="CuaMutCarta.blp CuaMutDes.blp"
for par in "v19u 1254b9f960c68dccb2d954b54de3532f878304e967e92ba3e32f65025befddce v19v normal" \
           "v19u-prueba ad7246554050cb663303121ee8af55ee811969ee5bbf5a11ae8f088929da2b35 v19v-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3b war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19v.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19v.py $E $N > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3b war3map.imp; do add $f $N/$f; done
  for t in $NUEVOS; do add "war3mapImported\\$t" $X/$t; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $NUEVOS; do
    $W extract $O "war3mapImported\\$t" -o $P/re > /dev/null && cmp -s $P/re $X/$t || { echo "$N: reextracción de $t distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3b " ] || [ "$D" = "(attributes) war3map.imp war3map.j war3map.w3b " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  echo "$N: j, w3b e imp cambiados y 2 imports nuevos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
