#!/bin/bash
# v13f: v13d con las canciones de DevTest6. Mapa final y copia con registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/v13f.py v13d/war3map.j v13f/war3map.j v13f/temas.txt || exit 1
python3 scripts/v13f.py v13d/war3map-registro.j v13f/war3map-registro.j v13f/temas.txt || exit 1
$PJ v13f/war3map.j | tail -1; $PJ v13f/war3map-registro.j | tail -1
for f in "" -registro; do
 o=TerrainDev-Titulo-v13d$f.w3x
 for i in 1 2 3 4 5 6; do
  n=v13f/tmp$f-$i
  $W mpq add $o 'war3mapImported\OleadaTema'$i.mp3 --file temas-devtest6/OleadaTema$i.mp3 -o $n > /dev/null || exit 2
  [ $i -gt 1 ] && gio trash $o
  o=$n
 done
 $W mpq add $o war3map.j --file v13f/war3map$f.j -o TerrainDev-Titulo-v13f$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13f$f.w3x | tail -1 | cut -c1-90; gio trash $o
done
sha256sum TerrainDev-Titulo-v13f.w3x TerrainDev-Titulo-v13f-registro.w3x
