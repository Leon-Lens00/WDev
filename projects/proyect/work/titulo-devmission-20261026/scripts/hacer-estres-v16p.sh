#!/bin/bash
# Sólo prueba: v16p-estres, el j de v16p con estres_v16p.py (8 tiradores con subfusil, balas ilimitadas). No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/estres-v16p-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16p-estres
$W extract TerrainDev-Titulo-v16p.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base v16p/war3map.j || { echo "v16p/war3map.j no es el del mapa v16p"; exit 1; }
python3 -I scripts/estres_v16p.py v16p/war3map.j v16p-estres/war3map.j ${1:-6} || exit 1
$PJ v16p-estres/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló"; $PJ v16p-estres/war3map.j | tail -8; exit 1; }
$W mpq add TerrainDev-Titulo-v16p.w3x war3map.j --file v16p-estres/war3map.j -o TerrainDev-Titulo-v16p-estres.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
$W extract TerrainDev-Titulo-v16p-estres.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re v16p-estres/war3map.j || { echo "reextracción distinta"; exit 1; }
$W mpq verify TerrainDev-Titulo-v16p-estres.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v16p-estres.w3x
