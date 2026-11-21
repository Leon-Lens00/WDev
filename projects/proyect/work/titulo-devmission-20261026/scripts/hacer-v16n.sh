#!/bin/bash
# v16n: el j de v16m con las rachas a tiros (v16n.py); imports como v16m.
# v16n-prueba: notas en lat\v16n-1.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16n-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16n v16n-prueba
for sal in v16m v16m-prueba; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
python3 -I scripts/v16n.py v16m/war3map.j v16n/war3map.j || exit 1
python3 -I scripts/v16n.py v16m-prueba/war3map.j $P/p.j || exit 1
sed 's/lat\\\\v16m-/lat\\\\v16n-/' $P/p.j > v16n-prueba/war3map.j
for f in v16n v16n-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16n v16n-prueba; do
  B=TerrainDev-Titulo-${sal/v16n/v16m}.w3x
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.w3a war3map.imp 'war3mapImported\SueloAzur.mdx' 'war3mapImported\SueloAzur.blp'; do
    $W extract TerrainDev-Titulo-$sal.w3x "$f" -o $P/a > /dev/null; $W extract $B "$f" -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16n*.w3x
