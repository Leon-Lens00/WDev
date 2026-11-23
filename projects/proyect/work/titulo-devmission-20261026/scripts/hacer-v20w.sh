#!/bin/bash
# v20w (20/11/2026): libro de armas (V, F, G), recarga automática, dash 3 cargas, pulls comprados y economía fija.
# Normal sobre v20v; prueba sobre v20v-prueba. Cambian el j (v20w.py) y el w3a (objetos_v20w.py sobre el de v20s).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20w-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
# El w3a de v20v es el de v20s (v20t-v20v sólo cambiaron el j).
python3 -I scripts/objetos_v20w.py v20s $P/obj > /dev/null || exit 1
for par in "v20v 011e6feac65613b8cb5f74095326cf3b04f2d53ebfee8847262a71a0ff385219 v20w normal" \
           "v20v-prueba cefaae848ce961ede97d6346c57920770332c052782954e88176bb66e8982606 v20w-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B war3map.w3a -o $P/base.w3a > /dev/null || exit 1
  cmp -s $P/base.w3a v20s/war3map.w3a || { echo "el w3a de $v no es el de v20s"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v20w.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  cp $P/obj/war3map.w3a $N/war3map.w3a
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3a; do add $f $N/$f; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  grep -qxE '\(attributes\)( \(listfile\))? war3map.j war3map.w3a' <<< "${D% }" || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
