#!/bin/bash
# v16d: Tauren que camina por guion (sin que la IA neutral se lo lleve) y precarga de sonidos (v16d.py). Del mapa
# v16c sólo cambia war3map.j. v16d-prueba: notas en lat\v16d-1.txt (prueba_v16d.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16d-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16c.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16c/war3map.j || { echo "v16c/war3map.j no es el del mapa v16c"; exit 1; }
mkdir -p v16d v16d-prueba
python3 -I scripts/v16d.py v16c/war3map.j v16d/war3map.j || exit 1
python3 -I scripts/prueba_v16d.py v16d/war3map.j v16d-prueba/war3map.j || exit 1
for f in v16d v16d-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
for sal in v16d v16d-prueba; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal.w3x TerrainDev-Titulo-$sal.w3x; rm -f $P/$sal.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16d*.w3x
