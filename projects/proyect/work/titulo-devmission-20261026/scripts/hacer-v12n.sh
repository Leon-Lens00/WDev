#!/bin/bash
# v12n: v12m con reaparicion, y una copia con puente por personaje.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12n v12n-solo
python3 scripts/revivir_v12n.py v12m/war3map.j v12n/war3map.j v12k/obj/war3map.w3a v12n/war3map.w3a || exit 1
$PJ v12n/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
$W mpq add TerrainDev-Titulo-v12m.w3x war3map.j --file v12n/war3map.j -o v12n/paso.w3x | tail -1
$W mpq add v12n/paso.w3x war3map.w3a --file v12n/war3map.w3a -o TerrainDev-Titulo-v12n.w3x | tail -1
for c in 0 1; do
 python3 scripts/puente_revivir_v12n.py $PWD/v12n/war3map.j $PWD/v12n-solo/war3map-$c.j $c
 $PJ v12n-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
 $W mpq add TerrainDev-Titulo-v12n.w3x war3map.j --file v12n-solo/war3map-$c.j -o TerrainDev-Titulo-v12n-solo$c.w3x | tail -1
done
gio trash v12n/paso.w3x
$W mpq bytes-diff TerrainDev-Titulo-v12m.w3x TerrainDev-Titulo-v12n.w3x | grep -v -i 'same\|match' | tail -6
sha256sum TerrainDev-Titulo-v12n.w3x
