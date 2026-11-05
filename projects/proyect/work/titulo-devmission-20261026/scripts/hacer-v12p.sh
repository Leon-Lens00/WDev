#!/bin/bash
# v12p: v12o con derrota general; solo0 con segundo jugador simulado, solo1 sin él.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12p v12p-solo
python3 scripts/derrota_v12p.py v12o/war3map.j v12p/war3map.j || exit 1
$PJ v12p/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
$W mpq add TerrainDev-Titulo-v12o.w3x war3map.j --file v12p/war3map.j -o TerrainDev-Titulo-v12p.w3x | tail -1
for c in 0 1; do
 python3 scripts/puente_derrota_v12p.py $PWD/v12p/war3map.j $PWD/v12p-solo/war3map-$c.j $c $((1-c)) | tail -1
 $PJ v12p-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
 $W mpq add TerrainDev-Titulo-v12p.w3x war3map.j --file v12p-solo/war3map-$c.j -o TerrainDev-Titulo-v12p-solo$c.w3x | tail -1
done
$W mpq bytes-diff TerrainDev-Titulo-v12o.w3x TerrainDev-Titulo-v12p.w3x | grep -v -i 'same\|match' | tail -5
sha256sum TerrainDev-Titulo-v12p.w3x
