#!/bin/bash
# v18z (15/11/2026): sólo cambia war3map.j (v18z.py): fase 10, curaciones al morir la élite.
# Normal sobre v18y; prueba sobre v18y-prueba (registros lat\v18z-*.txt); lan sobre v18s-lan con v18v..v18y en modo
# normal y v18z en modo lan (registros lat\j<id>-v18z-*.txt), más su map.cfg para ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18z-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v18y 679b61e1681d3f3968c440b379244610f5eaf807f91624d952df9bf6272ca266 v18z normal" \
           "v18y-prueba bbb0f8dec8fa1f2371a0b82029a560426a4f3c4cea0945564a89fa5a46567715 v18z-prueba prueba" \
           "v18s-lan 367a6b86e4df191d85a4bbe526a148827d19e0db86313aa49689198b70ff4d6b v18z-lan lan"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  if [ $m = lan ]; then
    prev=$v/war3map.j
    for s in v18v v18w v18x v18y; do python3 -I scripts/$s.py $prev $P/$s.j > /dev/null || exit 1; prev=$P/$s.j; done
    python3 -I scripts/v18z.py $prev $N/war3map.j lan > /dev/null || exit 1
  else
    [ $m = normal ] && a= || a=$m
    python3 -I scripts/v18z.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  fi
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
# map.cfg de la LAN para ydhost (como hacer-v18s.sh).
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all TerrainDev-Titulo-v18z-lan.w3x -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v18z-lan.w3x $P/lanx $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v18z-lan/map.cfg || exit 1
echo "map.cfg: $(grep -c . v18z-lan/map.cfg) líneas"
