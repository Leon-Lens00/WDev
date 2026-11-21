#!/bin/bash
# Sólo prueba (13/11/2026): repetición de la prueba de oleadas con los relojes arrancados de nuevo en cada tramo
# (oleadas2_v16t.py sobre v16t-shots-oleadas). No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/oleadas2-v16t-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-shots-oleadas.w3x; sal=v16t-shots-oleadas2; O=TerrainDev-Titulo-$sal.w3x
echo "6fd6706c040922ac2bda53a885481eb739e342e8642c821883086712c8372b52  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16t-shots-oleadas/war3map.j || { echo "v16t-shots-oleadas/war3map.j no es el del mapa"; exit 1; }
mkdir -p $sal
python3 -I scripts/oleadas2_v16t.py v16t-shots-oleadas/war3map.j $sal/war3map.j || exit 1
$PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file $sal/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
