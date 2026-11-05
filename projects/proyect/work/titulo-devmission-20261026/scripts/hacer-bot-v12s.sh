#!/bin/bash
# Copia de prueba del bot: combate real y registro. Uso: hacer-bot-v12s.sh CELDA VIDAS
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; mkdir -p v12s-solo; c=${1:-0}
python3 scripts/puente_bot_v12s.py $PWD/v12s/war3map.j $PWD/v12s-solo/war3map-$c.j $c ${2:-9} | tail -1 || exit 1
$PJ v12s-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
$W mpq add TerrainDev-Titulo-v12s.w3x war3map.j --file v12s-solo/war3map-$c.j -o TerrainDev-Titulo-v12s-solo$c.w3x | tail -1 | grep -v round-trips
