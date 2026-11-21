#!/bin/bash
# v16j: cuadro de diálogo mayor, retrato delante, suelo negro, teclas en la consola, iconos al centro y cadenas al recargar (v16j.py).
# Del mapa v16i sólo cambia war3map.j. v16j-prueba: notas en lat\v16j-1.txt (prueba_v16j.py, hasta 1500).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16j-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16i.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16i/war3map.j || { echo "v16i/war3map.j no es el del mapa v16i"; exit 1; }
mkdir -p v16j v16j-prueba
python3 -I scripts/v16j.py v16i/war3map.j v16j/war3map.j || exit 1
python3 -I scripts/prueba_v16j.py v16j/war3map.j v16j-prueba/war3map.j || exit 1
for f in v16j v16j-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16j v16j-prueba; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal war3map.j"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp; do
    $W extract TerrainDev-Titulo-$sal.w3x $f -o $P/a > /dev/null; $W extract $B $f -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16j*.w3x
