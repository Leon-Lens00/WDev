#!/bin/bash
# v14zp: la música de cada oleada a la mitad (v14zp.py). Del mapa v14zo sólo cambia war3map.j.
# v14zp-prueba-dia: las de prueba_v14zo.py («-sumar N», «-matar N», «-caer», «-rachas»), de día, registro en lat\v14zp-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zp-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zo.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zo/war3map.j || { echo "v14zo/war3map.j no es el del mapa v14zo"; exit 1; }
mkdir -p v14zp v14zp-prueba-dia
python3 -I scripts/v14zp.py v14zo/war3map.j v14zp/war3map.j || exit 1
python3 -I scripts/prueba_v14zp.py v14zp/war3map.j v14zp-prueba-dia/war3map.j directa dia || exit 1
for sal in v14zp v14zp-prueba-dia; do
  $PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $sal"; $PJ $sal/war3map.j | tail -5; exit 1; }
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v14zp*.w3x
