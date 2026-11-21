#!/bin/bash
# v18o (15/11/2026): sobre v18n, sólo cambia war3map.j (v18o.py): sonidos del recuento calentados a volumen 0 y fase 8
# (votación de Mutación Evo, recuento y muestra de 8 s). Salidas: TerrainDev-Titulo-v18o.w3x, -prueba (lat\v18o-*.txt) y
# -lan (de la de prueba, lat\j<id>-v18o-*.txt) con su map.cfg para ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18o-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18o v18o-prueba v18o-lan
for v in v18n v18n-prueba v18n-lan; do
  case $v in v18n) H=df69177c956feb55d8c26ce9b34b2cc1f1c4ed7071fc40a948c510fb18c4d57e; M=;; *) H=d000aac4e1f11098287880a7628e03de6711c46e98b357c4ef8153d7567136d3; M=prueba;; esac
  [ $v = v18n-lan ] && { H=d000aac4e1f11098287880a7628e03de6711c46e98b357c4ef8153d7567136d3; M=lan; }
  B=TerrainDev-Titulo-${v/-lan/-prueba}.w3x; N=${v/v18n/v18o}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j ${v/-lan/-prueba}/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18o.py ${v/-lan/-prueba}/war3map.j $N/war3map.j $M > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j" ] || { echo "$N: cambió algo más que el j: $D"; exit 1; }
  $W mpq bytes-diff $B $O | grep -q 'DIFFERS. [23] changed, 0 only in A, 0 only in B' || { echo "$N: entradas añadidas o quitadas"; exit 1; }
  echo "$N: j reextraído; cabecera igual a ${v/-lan/-prueba}"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# map.cfg de la LAN para ydhost (como hacer-lan-v14zo.sh).
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all TerrainDev-Titulo-v18o-lan.w3x -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v18o-lan.w3x $P/lanx $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v18o-lan/map.cfg || exit 1
echo "map.cfg: $(grep -c . v18o-lan/map.cfg) líneas"
