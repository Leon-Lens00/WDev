#!/bin/bash
# v16m: el j de v16k con Tut_Guion partido en dos (v16m.py); imports como v16l (SueloAzur.blp con formato probado).
# v16m-prueba: notas en lat\v16m-1.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16m-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16m v16m-prueba
for sal in v16l v16l-prueba; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
python3 -I scripts/v16m.py v16l/war3map.j v16m/war3map.j || exit 1
python3 -I scripts/v16m.py v16l-prueba/war3map.j $P/p.j || exit 1
sed 's/lat\\\\v16l-/lat\\\\v16m-/' $P/p.j > v16m-prueba/war3map.j
for f in v16m v16m-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16m v16m-prueba; do
  B=TerrainDev-Titulo-${sal/v16m/v16l}.w3x
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.w3a war3map.imp 'war3mapImported\SueloAzur.mdx' 'war3mapImported\SueloAzur.blp'; do
    $W extract TerrainDev-Titulo-$sal.w3x "$f" -o $P/a > /dev/null; $W extract $B "$f" -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16m*.w3x
