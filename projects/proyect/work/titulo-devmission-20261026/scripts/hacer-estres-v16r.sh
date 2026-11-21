#!/bin/bash
# Sólo prueba: el j de v16r con estres_v16r.py. No se entrega.
#   v16r-estres       8 tiradores con MP5 (subfusil tier 6), como v16p-estres
#   v16r-estres-spas  8 tiradores con SPAS-12 (escopeta tier 6, 8 perdigones)
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/estres-v16r-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v16r.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base v16r/war3map.j || { echo "v16r/war3map.j no es el del mapa v16r"; exit 1; }
for par in "v16r-estres 6 1" "v16r-estres-spas 6 4"; do
  set -- $par; sal=$1
  mkdir -p $sal
  python3 -I scripts/estres_v16r.py v16r/war3map.j $sal/war3map.j $2 $3 || exit 1
  $PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $sal"; $PJ $sal/war3map.j | tail -8; exit 1; }
  $W mpq add TerrainDev-Titulo-v16r.w3x war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16r-estres*.w3x
