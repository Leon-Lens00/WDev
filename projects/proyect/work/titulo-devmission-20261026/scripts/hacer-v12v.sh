#!/bin/bash
# v12v: v12u con colisiones solo por paso, sin emblema y oleadas aliadas entre sí.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12v
python3 scripts/v12v.py $PWD/v12u/war3map.j $PWD/v12v/war3map.j || exit 1
$PJ v12v/war3map.j | tail -1
B=TerrainDev-Titulo-v12v.w3x
$W mpq add TerrainDev-Titulo-v12u.w3x war3map.j --file v12v/war3map.j -o $B | tail -1 | grep -v round-trips
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12u.w3x $B | grep -i 'differs\|changed' | tail -3
sha256sum $B
