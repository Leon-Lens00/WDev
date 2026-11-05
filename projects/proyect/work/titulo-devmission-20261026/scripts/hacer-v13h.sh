#!/bin/bash
# v13h: v13f (canciones de DevTest6) sin reciclar dummies de misil. Mapa final y copia con registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/v13g.py v13f/war3map.j v13h/war3map.j || exit 1
python3 scripts/v13g.py v13f/war3map-registro.j v13h/war3map-registro.j || exit 1
$PJ v13h/war3map.j | tail -1; $PJ v13h/war3map-registro.j | tail -1
for f in "" -registro; do
 $W mpq add TerrainDev-Titulo-v13f$f.w3x war3map.j --file v13h/war3map$f.j -o TerrainDev-Titulo-v13h$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13h$f.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v13h.w3x TerrainDev-Titulo-v13h-registro.w3x
