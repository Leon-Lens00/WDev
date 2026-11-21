#!/bin/bash
# v14zw: el personaje elegido en la intro entra a la partida (v14zw.py restaura la rama de Cairne en Game_Cuerpo).
# Del mapa v14zv cambia sólo war3map.j. v14zw-prueba-dia: prueba_v14zw.py. v14zw-lan: el mismo mapa normal con map.cfg de ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zw-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zv.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zv/war3map.j || { echo "v14zv/war3map.j no es el del mapa v14zv"; exit 1; }
mkdir -p v14zw v14zw-prueba-dia
python3 -I scripts/v14zw.py v14zv/war3map.j v14zw/war3map.j || exit 1
python3 -I scripts/prueba_v14zw.py v14zw/war3map.j v14zw-prueba-dia/war3map.j directa dia || exit 1
for f in v14zw v14zw-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=()
for sal in v14zw v14zw-prueba-dia; do
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
# LAN: el mapa normal tal cual (con intro, sin registros) y su map.cfg para ydhost.
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p v14zw-lan; cp TerrainDev-Titulo-v14zw.w3x TerrainDev-Titulo-v14zw-lan.w3x
[ -d v14zw-lan/x ] && gio trash v14zw-lan/x
$W mpq extract-all TerrainDev-Titulo-v14zw-lan.w3x -o v14zw-lan/x | tail -1 | cut -c1-80
cmp -s v14zw-lan/x/war3map.j v14zw/war3map.j || { echo 'reextracción LAN distinta'; exit 1; }
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v14zw-lan.w3x v14zw-lan/x $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v14zw-lan/map.cfg || exit 1
grep -c . v14zw-lan/map.cfg
sha256sum TerrainDev-Titulo-v14zw*.w3x
