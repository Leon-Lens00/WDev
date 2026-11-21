#!/bin/bash
# v14zm: fase 4 de docs/planes/devmission-armas-rachas-v14zj.md (cuchillo nuevo). Del mapa v14zl cambian war3map.j
# (v14zm.py) y war3map.w3u (objetos_v14zm.py: 12 unidades ficticias 'hkA1'..'hkB6'), y se añaden los 12 modelos de
# efectos_v14zm.cjs (Culling Cleave/Slash de Vinz por tier, sin luz). v14zm-prueba-dia: las de prueba_v14zm.py
# («-cuchillo T», «-ataque», registro de golpes), de día, registro en lat\v14zm-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zm-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zl.w3x
for f in war3map.j war3map.w3u; do
  $W extract $B $f -o $P/base > /dev/null && cmp -s $P/base v14zl/$f || { echo "v14zl/$f no es el del mapa v14zl"; exit 1; }
done
node scripts/efectos_v14zm.cjs > /dev/null || exit 1
rm -f cuchillo-v14zm/*.mdl
mkdir -p v14zm v14zm-prueba-dia
python3 -I scripts/objetos_v14zm.py v14zl/war3map.w3u v14zm/war3map.w3u || exit 1
python3 -I scripts/v14zm.py v14zl/war3map.j v14zm/war3map.j || exit 1
python3 -I scripts/prueba_v14zm.py v14zm/war3map.j v14zm-prueba-dia/war3map.j directa dia || exit 1
for f in v14zm v14zm-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14zm/war3map.w3u")
for n in Cleave Slash; do for t in 1 2 3 4 5 6; do imp+=("war3mapImported\\Culling$n$t.mdx=cuchillo-v14zm/Culling$n$t.mdx"); done; done
for sal in v14zm v14zm-prueba-dia; do
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
sha256sum TerrainDev-Titulo-v14zm*.w3x
