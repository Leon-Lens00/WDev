#!/bin/bash
# v12m: v12l con la oleada minima, y una copia con puente de prueba por personaje.
set -e
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12m-solo
python3 -I scripts/oleada_v12m/insertar.py v12l/war3map.j v12m/wave/compilado.j v12m/war3map.j
$PJ v12m/war3map.j | tail -8
$W mpq add TerrainDev-Titulo-v12l.w3x war3map.j --file v12m/war3map.j -o TerrainDev-Titulo-v12m.w3x | tail -1
if [ -f scripts/oleada_v12m/puente_oleada.py ]; then
 for c in 0 1; do
  python3 scripts/oleada_v12m/puente_oleada.py $PWD/v12m/war3map.j $PWD/v12m-solo/war3map-$c.j $c
  $PJ v12m-solo/war3map-$c.j | tail -1
  $W mpq add TerrainDev-Titulo-v12m.w3x war3map.j --file v12m-solo/war3map-$c.j -o TerrainDev-Titulo-v12m-solo$c.w3x | tail -1
 done
fi
$W mpq bytes-diff TerrainDev-Titulo-v12l.w3x TerrainDev-Titulo-v12m.w3x | grep -v -i 'same\|match' | tail -6
sha256sum TerrainDev-Titulo-v12m.w3x
