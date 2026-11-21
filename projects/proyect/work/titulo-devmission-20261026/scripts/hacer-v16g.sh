#!/bin/bash
# v16g: oleada del tutorial más cerca del Tauren, plazo de remate de 5 s sin contar la recarga y notas de cada
# objetivo (v16g.py); nmcf y nj02 sin huir (objetos_v16g.py, ufle 0). Del mapa v16f cambian war3map.j y war3map.w3u. v16g-prueba: notas en lat\v16g-1.txt (prueba_v16g.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16g-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16f.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16f/war3map.j || { echo "v16f/war3map.j no es el del mapa v16f"; exit 1; }
mkdir -p v16g v16g-prueba
$W extract $B war3map.w3u -o $P/w3u-base > /dev/null || exit 1
python3 -I scripts/objetos_v16g.py $P/w3u-base v16g/war3map.w3u || exit 1
python3 -I scripts/v16g.py v16f/war3map.j v16g/war3map.j || exit 1
python3 -I scripts/prueba_v16g.py v16g/war3map.j v16g-prueba/war3map.j || exit 1
for f in v16g v16g-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
for sal in v16g v16g-prueba; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal-1.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W mpq add $P/$sal-1.w3x war3map.w3u --file v16g/war3map.w3u -o $P/$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal.w3x "${P:?}"/$sal-1.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal war3map.j"; exit 1; }
  $W extract TerrainDev-Titulo-$sal.w3x war3map.w3u -o $P/re > /dev/null && cmp -s $P/re v16g/war3map.w3u || { echo "reextracción distinta: $sal war3map.w3u"; exit 1; }
  for f in war3map.w3b war3map.imp; do
    $W extract TerrainDev-Titulo-$sal.w3x $f -o $P/a > /dev/null; $W extract $B $f -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16g*.w3x
