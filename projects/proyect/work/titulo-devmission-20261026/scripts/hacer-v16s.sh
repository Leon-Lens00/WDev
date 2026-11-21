#!/bin/bash
# v16s: el j de v16r con v16s.py (búsqueda de unidades ajustada, lista de grandes, tandas de 4); el resto igual que v16r.
# v16s-prueba: notas en lat\v16s-1.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16s-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16s v16s-prueba
for sal in v16r v16r-prueba; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
python3 -I scripts/v16s.py v16r/war3map.j v16s/war3map.j || exit 1
python3 -I scripts/v16s.py v16r-prueba/war3map.j $P/p.j > /dev/null || exit 1
sed 's/lat\\\\v16r-/lat\\\\v16s-/' $P/p.j > v16s-prueba/war3map.j
for f in v16s v16s-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16s v16s-prueba; do
  B=TerrainDev-Titulo-${sal/v16s/v16r}.w3x
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq bytes-diff $B TerrainDev-Titulo-$sal.w3x > $P/dif.txt
  grep -A9 'payloads that differ' $P/dif.txt | grep '^  ' | awk '{print $1}' | sort | tr '\n' ' ' | grep -qx '(attributes) (listfile) war3map.j ' || grep -A9 'payloads that differ' $P/dif.txt | grep '^  ' | awk '{print $1}' | sort | tr '\n' ' ' | grep -qx '(attributes) war3map.j ' || { echo "cambian otros archivos en $sal"; cat $P/dif.txt; exit 1; }
  grep -q ', 0 only in A, 0 only in B' $P/dif.txt || { echo "entradas añadidas o quitadas en $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16s*.w3x
