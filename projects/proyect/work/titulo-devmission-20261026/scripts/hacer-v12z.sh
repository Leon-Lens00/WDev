#!/bin/bash
# v12z: v12y con solo árboles entre los destructibles colocados. Mapa final y copia con registro ligero.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
S=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/w
mkdir -p v12z; python3 -I scripts/objetos_v12z.py $S/war3map.doo v12z/war3map.doo || exit 1
for f in "" -registro; do
 $W mpq add TerrainDev-Titulo-v12y$f.w3x war3map.doo --file v12z/war3map.doo -o TerrainDev-Titulo-v12z$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v12z$f.w3x | tail -1 | cut -c1-90
 $W mpq bytes-diff TerrainDev-Titulo-v12y$f.w3x TerrainDev-Titulo-v12z$f.w3x | grep -i 'differs\|changed' | tail -2
done
sha256sum TerrainDev-Titulo-v12z.w3x TerrainDev-Titulo-v12z-registro.w3x
