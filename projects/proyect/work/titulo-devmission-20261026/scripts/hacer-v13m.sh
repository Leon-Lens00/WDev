#!/bin/bash
# v13m: v13l con el dash nuevo y altura de misiles 70.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v13m
python3 scripts/v13m.py v13l/war3map.j v13m/war3map.j || exit 1
$PJ v13m/war3map.j | tail -1 | tee /dev/stderr | grep -q 'Parse successful' || { echo 'pJASS falló'; exit 1; }
$W mpq add TerrainDev-Titulo-v13l.w3x war3map.j --file v13m/war3map.j -o TerrainDev-Titulo-v13m.w3x | tail -1 | grep -v round-trips
$W mpq verify TerrainDev-Titulo-v13m.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v13m.w3x
