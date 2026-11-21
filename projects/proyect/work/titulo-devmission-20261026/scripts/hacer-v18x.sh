#!/bin/bash
# v18x (15/11/2026): sólo cambia war3map.j (v18x.py): efectos de la Mutación Evo.
# Normal sobre v18w; prueba sobre v18w-prueba (con oleadas otra vez, "-mut N", registros lat\v18x-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18x-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v18w 4b9324c100ff37e6e0529e8a6bf1dec0ed0403eb1e9bec08635198a4e0da9a16 v18x normal" \
           "v18w-prueba 97b35bdf PRUEBA v18x-prueba prueba"; do
  set -- $par
  if [ "$3" = PRUEBA ]; then v=$1; HP=$2; N=$4; m=$5; else v=$1; H=$2; N=$3; m=$4; HP=; fi
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  if [ -n "$HP" ]; then sha256sum $B | grep -q "^$HP" || exit 1; else echo "$H  $B" | sha256sum -c --quiet || exit 1; fi
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  [ $m = normal ] && a= || a=prueba
  python3 -I scripts/v18x.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j" ] || { echo "$N: cambió algo más que el j: $D"; exit 1; }
  echo "$N: j reextraído; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
