#!/bin/bash
# v13c: v13b con los marcadores y los doodads guardados en puntos/Swamped-Puntos.w3x. Mapa final y copia con registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
G=puntos/guardado-2331
python3 scripts/v13c.py v13b/war3map.j v13c/war3map.j $G/war3mapUnits.doo || exit 1
python3 scripts/v13c.py v13b/war3map-registro.j v13c/war3map-registro.j $G/war3mapUnits.doo || exit 1
$PJ v13c/war3map.j | tail -1; $PJ v13c/war3map-registro.j | tail -1
for f in "" -registro; do
 o=puntos/tmp$f
 $W mpq add TerrainDev-Titulo-v13b$f.w3x war3map.doo --file $G/war3map.doo -o $o > /dev/null || exit 2
 $W mpq add $o war3map.j --file v13c/war3map$f.j -o TerrainDev-Titulo-v13c$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13c$f.w3x | tail -1 | cut -c1-90; gio trash $o
done
sha256sum TerrainDev-Titulo-v13c.w3x TerrainDev-Titulo-v13c-registro.w3x
