#!/bin/bash
# v14zq: el anuncio de rachas en una tarjeta que baja y sube, con el retrato que habla (v14zq.py). Del mapa v14zp
# cambian war3map.j, war3map.w3b y war3map.imp (objetos_v14zq.py: 'DS18') y se añade war3mapImported\RachaCaja.blp
# (tarjeta_v14zq.py). v14zq-prueba-dia: las de prueba_v14zq.py, de día, registro en lat\v14zq-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zq-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zp.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zp/war3map.j || { echo "v14zp/war3map.j no es el del mapa v14zp"; exit 1; }
for f in war3map.w3b war3map.imp; do $W extract $B $f -o $P/obj/$f > /dev/null || { echo "no sale $f de v14zp"; exit 1; }; done
mkdir -p v14zq v14zq-prueba-dia
$PY -I scripts/tarjeta_v14zq.py || exit 1
python3 -I scripts/objetos_v14zq.py $P/obj v14zq || exit 1
python3 -I scripts/v14zq.py v14zp/war3map.j v14zq/war3map.j || exit 1
python3 -I scripts/prueba_v14zq.py v14zq/war3map.j v14zq-prueba-dia/war3map.j directa dia || exit 1
for f in v14zq v14zq-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3b=v14zq/war3map.w3b" "war3map.imp=v14zq/war3map.imp" "war3mapImported\\RachaCaja.blp=racha-v14zq/RachaCaja.blp")
for sal in v14zq v14zq-prueba-dia; do
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
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v14zq*.w3x
