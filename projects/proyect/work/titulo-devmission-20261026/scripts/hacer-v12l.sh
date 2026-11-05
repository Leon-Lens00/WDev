#!/bin/bash
# v12l desde v12k, y una copia con puente por personaje (Tauren y Cairne).
set -e
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12l-solo
python3 scripts/controlador_v12l.py v12k/war3map.j v12l/war3map.j
$PJ v12l/war3map.j | tail -1
$W mpq add TerrainDev-Titulo-v12k.w3x war3map.j --file v12l/war3map.j -o TerrainDev-Titulo-v12l.w3x | tail -1
for c in 0 1; do
 python3 scripts/puente_botones_v12k.py v12l/war3map.j v12l-solo/war3map-$c.j $c
 $PJ v12l-solo/war3map-$c.j | tail -1
 $W mpq add TerrainDev-Titulo-v12l.w3x war3map.j --file v12l-solo/war3map-$c.j -o TerrainDev-Titulo-v12l-solo$c.w3x | tail -1
done
$W mpq bytes-diff TerrainDev-Titulo-v12k.w3x TerrainDev-Titulo-v12l.w3x | grep -v -i 'same\|match' | tail -6
sha256sum TerrainDev-Titulo-v12l.w3x
