#!/bin/bash
# v14zr: textos de la tarjeta de rachas más abajo (v14zr.py). Del mapa v14zq sólo cambia war3map.j.
# v14zr-prueba-dia: las de prueba_v14zq.py («-ajuste», «-alto», «-cara», «-sumar»…), de día, registro en lat\v14zr-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zr-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zq.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zq/war3map.j || { echo "v14zq/war3map.j no es el del mapa v14zq"; exit 1; }
mkdir -p v14zr v14zr-prueba-dia
python3 -I scripts/v14zr.py v14zq/war3map.j v14zr/war3map.j || exit 1
python3 -I scripts/prueba_v14zr.py v14zr/war3map.j v14zr-prueba-dia/war3map.j directa dia || exit 1
for sal in v14zr v14zr-prueba-dia; do
  $PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $sal"; $PJ $sal/war3map.j | tail -5; exit 1; }
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v14zr*.w3x
