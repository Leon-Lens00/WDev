#!/bin/bash
# Sólo prueba (14/11/2026): apuntado fijo y enemigos en pausa (fijo_v16t.py) sobre v16t-relojes. No se entrega.
# 120 y 240 enemigos fijos; 0 u 8 tiradores MP5 con apuntado normal o fijo, enemigos quietos o no.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/fijo-v16t-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for par in "v16t-relojes 06995f1e081fed4d8a2a04951a062e1613c2ad239a70926829628ef0beb063a3"; do
  set -- $par; v=$1; B=TerrainDev-Titulo-$v.w3x; sal=$v-fijo; O=TerrainDev-Titulo-$sal.w3x
  echo "$2  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base $v/war3map.j || { echo "$v/war3map.j no es el del mapa"; exit 1; }
  mkdir -p $sal
  python3 -I scripts/estres_v16t.py $v/war3map.j $P/estres.j 6 > /dev/null || exit 1
  python3 -I scripts/fijo_v16t.py $P/estres.j $sal/war3map.j || exit 1
  $PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $sal/war3map.j -o $O | tail -1
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
