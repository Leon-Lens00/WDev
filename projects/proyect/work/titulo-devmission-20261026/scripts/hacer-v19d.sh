#!/bin/bash
# v19d (19/11/2026): copias de D.O.N rápidas y a tiro, estado SSJ, eco a unidades cercanas, Rasen Shuriken y rocas grandes. Cambia
# war3map.j (v19d.py) y war3map.w3u (objetos_v19d.py). Normal sobre v19c; prueba sobre v19c-prueba (registros lat\v19d-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19d-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v19c 2f4314c4cdf90472026f3d653f8dc8f2dd302920d42ddd07e60a3b47ac9f93bf v19d normal" \
           "v19c-prueba b49eef44e35eae66a3d081e66924512beaca61323d624695f9fc4e2d179cfae7 v19d-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  python3 -I scripts/objetos_v19d.py $E $N > /dev/null || exit 1
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19d.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3u --file $N/war3map.w3u -o $P/c.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j war3map.w3u" ] || { echo "$N: cambió otra cosa: $D"; exit 1; }
  echo "$N: j y w3u reextraídos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
