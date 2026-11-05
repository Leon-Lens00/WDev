#!/bin/bash
# Copias de un jugador de v12r para las teclas E y D: solo0 Tauren, solo1 Cairne.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; mkdir -p v12r-solo
for c in 0 1; do
 python3 scripts/puente_dash_solo_v12r.py $PWD/v12r/war3map.j $PWD/v12r-solo/war3map-$c.j $c | tail -1 || exit 1
 $PJ v12r-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
 $W mpq add TerrainDev-Titulo-v12r.w3x war3map.j --file v12r-solo/war3map-$c.j -o TerrainDev-Titulo-v12r-solo$c.w3x | tail -1 | grep -v round-trips
done
