#!/bin/bash
# Sólo prueba (13/11/2026): coste del sistema de oleadas por partes (oleadas_v16t.py) sobre el estrés de v16t-shots:
# 240 enemigos fijos, 14 tramos de 15 s que apagan interfaz, IA, movimiento o dibujo. No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/oleadas-v16t-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-shots.w3x; sal=v16t-shots-oleadas; O=TerrainDev-Titulo-$sal.w3x
echo "688e6bbebf0ff6c1046c29dceb655061346db3dc920c97e5d35ab8dc53f5021b  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16t-shots/war3map.j || { echo "v16t-shots/war3map.j no es el del mapa"; exit 1; }
mkdir -p $sal
python3 -I scripts/estres_v16t.py v16t-shots/war3map.j $P/estres.j 6 2,1,4,3,0,6 > /dev/null || exit 1
cmp -s $P/estres.j v16t-shots-estres/war3map.j || { echo "estrés distinto del de v16t-shots-estres"; exit 1; }
python3 -I scripts/oleadas_v16t.py $P/estres.j $sal/war3map.j || exit 1
$PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file $sal/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
