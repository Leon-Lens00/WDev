#!/bin/bash
# v12x: v12w con 25 % de vida en las oleadas. Mapa final y copia con intro completa y registro ligero.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
S=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/w
mkdir -p v12x; python3 scripts/objetos_v12x.py $S/war3map.w3u v12x/war3map.w3u || exit 1
B=TerrainDev-Titulo-v12x.w3x
$W mpq add TerrainDev-Titulo-v12w.w3x war3map.w3u --file v12x/war3map.w3u -o $B | tail -1 | grep -v round-trips
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12w.w3x $B | grep -i 'differs\|changed' | tail -2
$W mpq add $B war3map.j --file v12w/war3map-registro.j -o TerrainDev-Titulo-v12x-registro.w3x | tail -1 | grep -v round-trips
$W mpq verify TerrainDev-Titulo-v12x-registro.w3x | tail -1 | cut -c1-90
sha256sum $B TerrainDev-Titulo-v12x-registro.w3x
