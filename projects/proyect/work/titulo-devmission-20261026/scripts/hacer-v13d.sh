#!/bin/bash
# v13d: v13c con las seis rondas del pantano y sus objetos. Mapa final y copia con registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/objetos_v13d.py v13b/war3map.w3u v13d/war3map.w3u || exit 1
python3 scripts/v13d.py v13c/war3map.j v13d/war3map.j v13d/colisiones.txt || exit 1
python3 scripts/v13d.py v13c/war3map-registro.j v13d/war3map-registro.j v13d/colisiones.txt || exit 1
$PJ v13d/war3map.j | tail -1; $PJ v13d/war3map-registro.j | tail -1
for f in "" -registro; do
 o=v13d/tmp$f
 $W mpq add TerrainDev-Titulo-v13c$f.w3x war3map.w3u --file v13d/war3map.w3u -o $o > /dev/null || exit 2
 $W mpq add $o war3map.j --file v13d/war3map$f.j -o TerrainDev-Titulo-v13d$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13d$f.w3x | tail -1 | cut -c1-90; gio trash $o
done
sha256sum TerrainDev-Titulo-v13d.w3x TerrainDev-Titulo-v13d-registro.w3x
