#!/bin/bash
# Mapas de prueba de los límites altos (scripts/vista2_v14j.py) sobre v14j-vista: vA ancho y alto, vB sólo alto.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14j
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p vista2-A vista2-B
python3 scripts/vista2_v14j.py v14j-vista/war3map.j vista2-A/war3map.j -13440.0 12032.0 9728.0 || exit 1
python3 scripts/vista2_v14j.py v14j-vista/war3map.j vista2-B/war3map.j -7296.0 5888.0 9728.0 || exit 1
for v in A B; do
  $PJ vista2-$v/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $v"; exit 1; }
  $W mpq add TerrainDev-Titulo-v14j-vista.w3x war3map.j --file vista2-$v/war3map.j -o TerrainDev-Titulo-vista2-$v.w3x | tail -1 | grep -v round-trips
  $W extract TerrainDev-Titulo-vista2-$v.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re vista2-$v/war3map.j || { echo "reextracción distinta $v"; exit 1; }
done
echo hecho
