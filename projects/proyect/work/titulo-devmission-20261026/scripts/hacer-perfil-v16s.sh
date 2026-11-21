#!/bin/bash
# Sólo prueba: v16s-perfil, medición por modos (perfil_v16s.py sobre el j de v16s-estres). No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/perfil-v16s-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v16s-estres.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base v16s-estres/war3map.j || { echo "v16s-estres/war3map.j no es el del mapa"; exit 1; }
mkdir -p v16s-perfil
python3 -I scripts/perfil_v16s.py v16s-estres/war3map.j v16s-perfil/war3map.j || exit 1
$PJ v16s-perfil/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló"; $PJ v16s-perfil/war3map.j | tail -8; exit 1; }
$W mpq add TerrainDev-Titulo-v16s.w3x war3map.j --file v16s-perfil/war3map.j -o TerrainDev-Titulo-v16s-perfil.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
$W extract TerrainDev-Titulo-v16s-perfil.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re v16s-perfil/war3map.j || { echo "reextracción distinta"; exit 1; }
$W mpq verify TerrainDev-Titulo-v16s-perfil.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v16s-perfil.w3x
