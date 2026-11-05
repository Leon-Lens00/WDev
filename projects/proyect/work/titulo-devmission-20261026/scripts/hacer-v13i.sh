#!/bin/bash
# v13i: copia con registro de v13h y registros de rendimiento. El mapa final sigue siendo v13h.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/v13i.py v13h/war3map-registro.j v13i/war3map-registro.j || exit 1
$PJ v13i/war3map-registro.j | tail -1 | grep "Parse successful" || exit 3
$W mpq add TerrainDev-Titulo-v13h-registro.w3x war3map.j --file v13i/war3map-registro.j -o TerrainDev-Titulo-v13i-registro.w3x | tail -1 | grep -v round-trips
$W mpq verify TerrainDev-Titulo-v13i-registro.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v13i-registro.w3x
