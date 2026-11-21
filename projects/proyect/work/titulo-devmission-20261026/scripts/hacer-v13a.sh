#!/bin/bash
# v13a: Dev Mission sobre el terreno de IziPizi, arena central. Mapa final y copia con registro ligero.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
python3 scripts/v13a.py v12y/war3map.j v13a/war3map.j v13a/puntos.txt || exit 1
python3 scripts/v13a.py v12y/war3map-registro.j v13a/war3map-registro.j v13a/puntos.txt || exit 1
$PJ v13a/war3map.j | tail -1; $PJ v13a/war3map-registro.j | tail -1
for f in "" -registro; do
 a=TerrainDev-Titulo-v12z$f.w3x; o=$(mktemp --tmpdir=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad XXXX.w3x)
 for n in war3map.w3e war3map.wpm war3map.shd war3map.doo war3map.w3b war3map.w3i war3map.mmp war3mapMap.blp; do
  $W mpq add $a $n --file v13a/$n -o $o.n > /dev/null || exit 2; mv $o.n $o; a=$o
 done
 $W mpq add $a war3map.j --file v13a/war3map$f.j -o TerrainDev-Titulo-v13a$f.w3x | tail -1 | grep -v round-trips
 $W mpq verify TerrainDev-Titulo-v13a$f.w3x | tail -1 | cut -c1-90; gio trash $o
done
$W mpq bytes-diff TerrainDev-Titulo-v12z.w3x TerrainDev-Titulo-v13a.w3x | tail -14 | cut -c1-70
sha256sum TerrainDev-Titulo-v13a.w3x TerrainDev-Titulo-v13a-registro.w3x
