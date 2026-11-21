#!/bin/bash
# v14zl: fase 3 de docs/planes/devmission-armas-rachas-v14zj.md (élites). Del mapa v14zk cambian sólo war3map.j
# (v14zl.py) y war3map.w3u (objetos_v14zl.py). v14zl-prueba-dia: las de prueba_v14zl.py (registro de élites y
# llamadas, «-llamar»), de día, registro en lat\v14zl-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zl-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zk.w3x
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v14zk/war3map.j || { echo 'v14zk/war3map.j no es el del mapa v14zk'; exit 1; }
mkdir -p v14zl v14zl-prueba-dia
$W extract $B war3map.w3u -o v14zl/base.w3u > /dev/null || exit 1
python3 -I scripts/objetos_v14zl.py v14zl/base.w3u v14zl/war3map.w3u || exit 1
python3 -I scripts/v14zl.py v14zk/war3map.j v14zl/war3map.j || exit 1
python3 -I scripts/prueba_v14zl.py v14zl/war3map.j v14zl-prueba-dia/war3map.j directa dia || exit 1
for f in v14zl v14zl-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14zl v14zl-prueba-dia; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal-1.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W mpq add $P/$sal-1.w3x war3map.w3u --file v14zl/war3map.w3u -o TerrainDev-Titulo-$sal.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  rm -f "${P:?}/$sal-1.w3x"
  for e in war3map.j=$sal/war3map.j war3map.w3u=v14zl/war3map.w3u; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v14zl*.w3x
