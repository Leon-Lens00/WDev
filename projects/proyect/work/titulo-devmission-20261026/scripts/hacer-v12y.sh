#!/bin/bash
# v12y: v12x sin intro y siempre con Tauren. Mapa final y copia con registro ligero.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
S=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/w
mkdir -p v12y
python3 scripts/v12y.py $S/war3map.j v12y/war3map.j || exit 1
python3 scripts/puente_ligero_v12w.py $S/war3map.j v12y/base-registro.j || exit 1
python3 scripts/v12y.py v12y/base-registro.j v12y/war3map-registro.j || exit 1
$PJ v12y/war3map.j | tail -1; $PJ v12y/war3map-registro.j | tail -1
$W mpq add TerrainDev-Titulo-v12x.w3x war3map.j --file v12y/war3map.j -o TerrainDev-Titulo-v12y.w3x | tail -1 | grep -v round-trips
$W mpq add TerrainDev-Titulo-v12x.w3x war3map.j --file v12y/war3map-registro.j -o TerrainDev-Titulo-v12y-registro.w3x | tail -1 | grep -v round-trips
for m in TerrainDev-Titulo-v12y.w3x TerrainDev-Titulo-v12y-registro.w3x; do $W mpq verify $m | tail -1 | cut -c1-90; done
sha256sum TerrainDev-Titulo-v12y.w3x TerrainDev-Titulo-v12y-registro.w3x
