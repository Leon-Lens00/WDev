#!/bin/bash
# v20a (19/11/2026): resultado de la oleada para 8 jugadores con puntuación y MVP (fase 8, primera parte).
# Normal sobre v19z; prueba sobre v19z-prueba. Cambian j, w3b e imp; se añaden war3mapImported\PuntTabla.blp y
# war3mapImported\PuntLado.blp (puntos_v20a.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20a-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$PYP -I scripts/puntos_v20a.py $FUENTE puntos-v20a > /dev/null || exit 1
IMP="PuntTabla PuntLado"
for par in "v19z e7b05df1dfa660c04f2e2200c498ff3267c1ee798e76b19128a3be9f0ff0e62c v20a normal" \
           "v19z-prueba 6f04c4b80bafc0728b68afa06a7bed34ac8fa6653ae7be8cfb2e8a4afd8519b6 v20a-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E $P/$N-obj
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3b war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v20a.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v18f.py $E $P/$N-obj puntos-v20a > /dev/null || exit 1
  cp $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3b war3map.imp; do add $f $N/$f; done
  for i in $IMP; do add "war3mapImported\\$i.blp" puntos-v20a/$i.blp; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for i in $IMP; do
    $W extract $O "war3mapImported\\$i.blp" -o $P/re > /dev/null && cmp -s $P/re puntos-v20a/$i.blp || { echo "$N: reextracción de $i.blp distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3b " ] || [ "$D" = "(attributes) war3map.imp war3map.j war3map.w3b " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  echo "$N: j, w3b e imp cambiados, 2 blp nuevos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
