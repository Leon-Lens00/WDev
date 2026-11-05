#!/bin/bash
# v13g: v13e sin reciclar dummies de misil. Mapa final y copia con registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/v13g.py v13e/war3map.j v13g/war3map.j || exit 1
python3 scripts/v13g.py v13e/war3map-registro.j v13g/war3map-registro.j || exit 1
$PJ v13g/war3map.j | tail -1; $PJ v13g/war3map-registro.j | tail -1
for f in "" -registro; do
 $W mpq add TerrainDev-Titulo-v13e$f.w3x war3map.j --file v13g/war3map$f.j -o TerrainDev-Titulo-v13g$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13g$f.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v13g.w3x TerrainDev-Titulo-v13g-registro.w3x
