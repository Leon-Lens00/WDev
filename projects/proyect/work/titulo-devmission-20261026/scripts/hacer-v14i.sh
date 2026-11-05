#!/bin/bash
# v14i: v14h con el sistema nuevo de generación de oleadas (scripts/v14i.py). Sólo cambia war3map.j: parte del mapa
# v14h y comprueba que su script sea v14h/war3map.j. Uso: hacer-v14i.sh [RONDA] [RJ] (de la prueba).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v14h.w3x war3map.j -o $P/v14h-base.j > /dev/null || exit 1
cmp -s $P/v14h-base.j v14h/war3map.j || { echo 'v14h/war3map.j no es el del mapa v14h'; exit 1; }
mkdir -p v14i v14i-prueba
python3 scripts/v14i.py v14h/war3map.j v14i/war3map.j || exit 1
python3 scripts/prueba_v14i.py v14i/war3map.j v14i-prueba/war3map.j ${1:-5} ${2:-6} || exit 1
for f in v14i v14i-prueba; do
  $PJ $f/war3map.j | tail -1 | grep -q 'Parse successful' || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }
done
for sal in v14i v14i-prueba; do
  $W mpq add TerrainDev-Titulo-v14h.w3x war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v round-trips
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/v14i-re > /dev/null && cmp -s $P/v14i-re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
done
$W extract TerrainDev-Titulo-v14i.w3x war3map.w3u -o $P/v14i-re > /dev/null && $W extract TerrainDev-Titulo-v14h.w3x war3map.w3u -o $P/v14h-re > /dev/null && cmp -s $P/v14i-re $P/v14h-re || { echo 'w3u distinto'; exit 1; }
$W mpq verify TerrainDev-Titulo-v14i.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14i.w3x TerrainDev-Titulo-v14i-prueba.w3x
