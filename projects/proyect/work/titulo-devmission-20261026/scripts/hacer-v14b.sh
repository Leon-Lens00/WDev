#!/bin/bash
# v14b: v14a con más tiempo de compra. Sólo cambia war3map.j.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14b
python3 scripts/v14b.py v14a/war3map.j v14b/war3map.j || exit 1
$PJ v14b/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14b/war3map.j' || { echo 'pJASS falló'; exit 1; }
$W mpq add TerrainDev-Titulo-v14a.w3x war3map.j --file v14b/war3map.j -o TerrainDev-Titulo-v14b.w3x | tail -1
$W mpq verify TerrainDev-Titulo-v14b.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14b.w3x
