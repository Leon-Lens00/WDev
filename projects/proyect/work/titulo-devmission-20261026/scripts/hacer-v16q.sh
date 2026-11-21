#!/bin/bash
# v16q: el j de v16p con v16q.py (balas de RapidBolt baratas y en tandas, ver el informe de estrés); el resto igual que v16p.
# v16q-prueba: notas en lat\v16q-1.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16q-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16q v16q-prueba
for sal in v16p v16p-prueba; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
python3 -I scripts/v16q.py v16p/war3map.j v16q/war3map.j || exit 1
python3 -I scripts/v16q.py v16p-prueba/war3map.j $P/p.j > /dev/null || exit 1
sed 's/lat\\\\v16p-/lat\\\\v16q-/' $P/p.j > v16q-prueba/war3map.j
for f in v16q v16q-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
for sal in v16q v16q-prueba; do
  B=TerrainDev-Titulo-${sal/v16q/v16p}.w3x
  $W mpq add $B war3map.j --file $sal/war3map.j -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq bytes-diff $B TerrainDev-Titulo-$sal.w3x > $P/dif.txt
  grep -A9 'payloads that differ' $P/dif.txt | grep '^  ' | awk '{print $1}' | sort | tr '\n' ' ' | grep -qx '(attributes) (listfile) war3map.j ' || grep -A9 'payloads that differ' $P/dif.txt | grep '^  ' | awk '{print $1}' | sort | tr '\n' ' ' | grep -qx '(attributes) war3map.j ' || { echo "cambian otros archivos en $sal"; cat $P/dif.txt; exit 1; }
  grep -q ', 0 only in A, 0 only in B' $P/dif.txt || { echo "entradas añadidas o quitadas en $sal"; exit 1; }
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16q*.w3x
