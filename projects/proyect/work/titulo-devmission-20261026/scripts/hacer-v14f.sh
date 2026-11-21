#!/bin/bash
# v14f: v14e con barras de vida sobre las unidades y textos de la tienda sólo mientras está abierta.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14f v14f-prueba
python3 scripts/v14f.py v14e/war3map.j v14f/war3map.j || exit 1
python3 scripts/prueba_v14e.py v14f/war3map.j v14f-prueba/war3map.j || exit 1
for f in v14f v14f-prueba; do
  $T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j $f/war3map.j | tail -1 | grep -q 'Parse successful' || { echo "pJASS falló en $f"; $T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j $f/war3map.j | tail -8; exit 1; }
done
$W mpq add TerrainDev-Titulo-v14e.w3x war3map.j --file v14f/war3map.j -o TerrainDev-Titulo-v14f.w3x | tail -1
$W mpq add TerrainDev-Titulo-v14e.w3x war3map.j --file v14f-prueba/war3map.j -o TerrainDev-Titulo-v14f-prueba.w3x | tail -1
$W mpq verify TerrainDev-Titulo-v14f.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14f.w3x TerrainDev-Titulo-v14f-prueba.w3x
