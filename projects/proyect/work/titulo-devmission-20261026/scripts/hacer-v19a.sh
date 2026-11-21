#!/bin/bash
# v19a (18/11/2026): copia espiritual y Embestida espiritual del Tauren. Cambia war3map.j (v19a.py) y los objetos
# war3map.w3a / war3map.w3u (objetos_v19a.py). Normal sobre v18z; prueba sobre v18z-prueba (registros lat\v19a-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19a-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v18z 186d1e2b3b2408e026d7a9a6bb0ba584b33e9dbe32552a4a026dda1bb9174f78 v19a normal" \
           "v18z-prueba 894a3db47280513a5e5af86abf9fc3db4e33c168a2fc7915d0ea900a1a8c39ab v19a-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3a war3map.w3u; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  python3 -I scripts/objetos_v19a.py $E $N > /dev/null || exit 1
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19a.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3a --file $N/war3map.w3a -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.w3u --file $N/war3map.w3u -o $P/c.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a war3map.w3u; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j war3map.w3a war3map.w3u" ] || { echo "$N: cambió otra cosa: $D"; exit 1; }
  echo "$N: j, w3a y w3u reextraídos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
