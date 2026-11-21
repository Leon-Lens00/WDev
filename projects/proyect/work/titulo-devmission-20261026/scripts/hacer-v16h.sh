#!/bin/bash
# v16h: tienda (réplica para todos con la cámara del tutorial), caja verde y despedida nueva del tutorial (v16h.py).
# Del mapa v16g sólo cambia war3map.j. v16h-prueba: notas en lat\v16h-1.txt (prueba_v16h.py, hasta 1500).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16h-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16g.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16g/war3map.j || { echo "v16g/war3map.j no es el del mapa v16g"; exit 1; }
mkdir -p v16h v16h-prueba
python3 -I scripts/v16h.py v16g/war3map.j v16h/war3map.j || exit 1
python3 -I scripts/prueba_v16h.py v16h/war3map.j v16h-prueba/war3map.j || exit 1
for f in v16h v16h-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16h v16h-prueba; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal war3map.j"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp; do
    $W extract TerrainDev-Titulo-$sal.w3x $f -o $P/a > /dev/null; $W extract $B $f -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16h*.w3x
