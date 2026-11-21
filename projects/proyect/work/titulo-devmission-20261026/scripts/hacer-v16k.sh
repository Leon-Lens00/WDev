#!/bin/bash
# v16k: retrato dentro del marco, suelo azul pastel y escenas de tiers, rachas, vidas, luz y cuchillo (v16k.py).
# Del mapa v16j cambian war3map.j y war3map.imp y se añaden SueloAzur.mdx y SueloAzur.blp (suelo_v16k.py).
# v16k-prueba: notas en lat\v16k-1.txt (prueba_v16k.py, hasta 2500).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16k-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16j.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16j/war3map.j || { echo "v16j/war3map.j no es el del mapa v16j"; exit 1; }
$W extract $B war3map.imp -o $P/obj/war3map.imp > /dev/null || { echo "no sale war3map.imp"; exit 1; }
$W extract $B 'war3mapImported\TitlePlano.mdx' -o $P/obj/TitlePlano.mdx > /dev/null || { echo "no sale TitlePlano.mdx"; exit 1; }
mkdir -p v16k v16k-prueba suelo-v16k
python3 -I scripts/suelo_v16k.py $P/obj/TitlePlano.mdx $P/obj/war3map.imp suelo-v16k v16k || exit 1
python3 -I scripts/v16k.py v16j/war3map.j v16k/war3map.j || exit 1
python3 -I scripts/prueba_v16k.py v16k/war3map.j v16k-prueba/war3map.j || exit 1
for f in v16k v16k-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }; done
imp=("war3map.imp=v16k/war3map.imp" "war3mapImported\\SueloAzur.mdx=suelo-v16k/SueloAzur.mdx" "war3mapImported\\SueloAzur.blp=suelo-v16k/SueloAzur.blp")
for sal in v16k v16k-prueba; do
  lista=("war3map.j=$sal/war3map.j" "${imp[@]}")
  cur=$B; n=0
  for e in "${lista[@]}"; do
    n=$((n+1)); $W mpq add "$cur" "${e%%=*}" --file "${e#*=}" -o "$P/$sal-$n.w3x" | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
    [ $n -gt 1 ] && rm -f "$cur"; cur="$P/$sal-$n.w3x"
  done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  for f in war3map.w3u war3map.w3b war3map.w3a; do
    $W extract TerrainDev-Titulo-$sal.w3x $f -o $P/a > /dev/null; $W extract $B $f -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16k*.w3x
