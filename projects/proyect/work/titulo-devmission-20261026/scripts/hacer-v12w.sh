#!/bin/bash
# v12w: v12v con dash a un punto y 3 rondas. Mapa final y copia con registro ligero para jugar.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12w
python3 scripts/dash_v12w.py $PWD/v12v/war3map.j $PWD/v12w/war3map.j || exit 1
python3 scripts/objetos_v12w.py v12s/war3map.w3a v12w/war3map.w3a || exit 1
python3 scripts/puente_ligero_v12w.py $PWD/v12w/war3map.j $PWD/v12w/war3map-registro.j || exit 1
python3 scripts/puente_ligero_v12w.py $PWD/v12w/war3map.j $PWD/v12w/war3map-directo.j directo || exit 1
$PJ v12w/war3map.j | tail -1; $PJ v12w/war3map-registro.j | tail -1; $PJ v12w/war3map-directo.j | tail -1
B=TerrainDev-Titulo-v12w.w3x; cp TerrainDev-Titulo-v12v.w3x $B
add(){ $W mpq add $B "$1" --file "$2" -o $B.tmp | tail -1 | grep -v 'round-trips'; mv $B.tmp $B; }
add war3map.j v12w/war3map.j; add war3map.w3a v12w/war3map.w3a
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12v.w3x $B | grep -i 'differs\|changed' | tail -2
$W mpq add $B war3map.j --file v12w/war3map-registro.j -o TerrainDev-Titulo-v12w-registro.w3x | tail -1 | grep -v 'round-trips'
$W mpq add $B war3map.j --file v12w/war3map-directo.j -o TerrainDev-Titulo-v12w-directo.w3x | tail -1 | grep -v 'round-trips'
sha256sum $B TerrainDev-Titulo-v12w-registro.w3x TerrainDev-Titulo-v12w-directo.w3x
