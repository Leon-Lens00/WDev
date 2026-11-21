#!/bin/bash
# v14zv: marco del retrato a 390, delante del retrato, con las medidas de v14zt (v14zv.py). Del mapa v14zu cambian
# war3map.j y vuelven RachaCaja.blp y RachaMarco.blp de racha-v14zt (tarjeta_v14zt.py). v14zv-prueba-dia: prueba_v14zv.py.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zv-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zu.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zu/war3map.j || { echo "v14zu/war3map.j no es el del mapa v14zu"; exit 1; }
mkdir -p v14zv v14zv-prueba-dia
python3 -I scripts/v14zv.py v14zu/war3map.j v14zv/war3map.j || exit 1
python3 -I scripts/prueba_v14zv.py v14zv/war3map.j v14zv-prueba-dia/war3map.j directa dia || exit 1
for f in v14zv v14zv-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3mapImported\\RachaCaja.blp=racha-v14zt/RachaCaja.blp" "war3mapImported\\RachaMarco.blp=racha-v14zt/RachaMarco.blp")
for sal in v14zv v14zv-prueba-dia; do
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
sha256sum TerrainDev-Titulo-v14zv*.w3x
