#!/bin/bash
# v14t: niebla negra más cerrada (v14t.py) y «-niebla INICIO FIN» en las de prueba. Parte del mapa v14q con el j de v14s
# (objetos y StormLuz.mdx iguales a v14s). Variantes: v14t-prueba y v14t-prueba-intro para Leon; v14t-rayos (registro
# por tormenta) y v14t-muda (sin registros durante las tormentas) para medir tirones.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14t; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract TerrainDev-Titulo-v14s.w3x war3map.j -o $P/v14s-base.j > /dev/null && cmp -s $P/v14s-base.j v14s/war3map.j || { echo 'v14s/war3map.j no es el del mapa v14s'; exit 1; }
$W extract TerrainDev-Titulo-v14s.w3x war3map.w3u -o $P/v14s-base.w3u > /dev/null && cmp -s $P/v14s-base.w3u v14s/obj-out/war3map.w3u || { echo 'w3u de v14s distinto'; exit 1; }
$W extract TerrainDev-Titulo-v14s.w3x 'war3mapImported\StormLuz.mdx' -o $P/luz.mdx > /dev/null && cmp -s $P/luz.mdx storm-luz/StormLuz.mdx || { echo 'StormLuz de v14s distinto'; exit 1; }
mkdir -p v14t v14t-prueba v14t-prueba-intro v14t-rayos v14t-muda
python3 -I scripts/v14t.py v14s/war3map.j v14t/war3map.j || exit 1
for m in prueba:directa prueba-intro:intro rayos:rayos muda:muda; do
  python3 -I scripts/prueba_v14t.py v14t/war3map.j v14t-${m%%:*}/war3map.j ${m#*:} || exit 1
done
for f in v14t v14t-prueba v14t-prueba-intro v14t-rayos v14t-muda; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14s/obj-out/war3map.w3u" "war3mapImported\\StormLuz.mdx=storm-luz/StormLuz.mdx")
for i in 1 2 3; do imp+=("war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14t v14t-prueba v14t-prueba-intro v14t-rayos v14t-muda; do
  cur=$B; n=0
  lista=("war3map.j=$sal/war3map.j" "${imp[@]}")
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
sha256sum TerrainDev-Titulo-v14t*.w3x
