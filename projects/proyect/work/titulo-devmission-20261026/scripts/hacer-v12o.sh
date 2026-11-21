#!/bin/bash
# v12o: v12n con vidas por el evento undefend, y copias de prueba con 3 vidas.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12o v12o-solo
python3 scripts/vidas_v12o.py v12n/war3map.j v12o/war3map.j || exit 1
$PJ v12o/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
$W mpq add TerrainDev-Titulo-v12n.w3x war3map.j --file v12o/war3map.j -o TerrainDev-Titulo-v12o.w3x | tail -1
for c in 0 1; do
 python3 scripts/puente_vidas_v12o.py $PWD/v12o/war3map.j $PWD/v12o-solo/war3map-$c.j $c | tail -1
 $PJ v12o-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
 $W mpq add TerrainDev-Titulo-v12o.w3x war3map.j --file v12o-solo/war3map-$c.j -o TerrainDev-Titulo-v12o-solo$c.w3x | tail -1
done
$W mpq bytes-diff TerrainDev-Titulo-v12n.w3x TerrainDev-Titulo-v12o.w3x | grep -v -i 'same\|match' | tail -5
sha256sum TerrainDev-Titulo-v12o.w3x
