#!/bin/bash
# v14z: tarde más oscura y noche azul oscuro (v14z.py). Parte del mapa v14q con el j de v14y y su w3u (visión 1100).
# La normal y v14z-prueba-intro entran de Tarde; v14z-prueba-dia/-tarde/-noche entran directas con esa variante.
# Todas las de prueba tienen «-variante X».
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14z; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract TerrainDev-Titulo-v14y.w3x war3map.j -o $P/v14y-base.j > /dev/null && cmp -s $P/v14y-base.j v14y/war3map.j || { echo 'v14y/war3map.j no es el del mapa v14y'; exit 1; }
$W extract TerrainDev-Titulo-v14s.w3x war3map.w3u -o $P/v14s-base.w3u > /dev/null && cmp -s $P/v14s-base.w3u v14s/obj-out/war3map.w3u || { echo 'w3u de v14s distinto'; exit 1; }
$W extract TerrainDev-Titulo-v14s.w3x 'war3mapImported\StormLuz.mdx' -o $P/luz.mdx > /dev/null && cmp -s $P/luz.mdx storm-luz/StormLuz.mdx || { echo 'StormLuz de v14s distinto'; exit 1; }
mkdir -p v14z v14z-prueba-dia v14z-prueba-tarde v14z-prueba-noche v14z-prueba-intro
python3 -I scripts/v14z.py v14y/war3map.j v14z/war3map.j || exit 1
for m in prueba-dia:directa:dia prueba-tarde:directa:tarde prueba-noche:directa:noche prueba-intro:intro:tarde; do
  IFS=: read sal modo var <<< "$m"
  python3 -I scripts/prueba_v14z.py v14z/war3map.j v14z-$sal/war3map.j $modo $var || exit 1
done
for f in v14z v14z-prueba-dia v14z-prueba-tarde v14z-prueba-noche v14z-prueba-intro; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14y/obj-out/war3map.w3u" "war3mapImported\\StormLuz.mdx=storm-luz/StormLuz.mdx")
D="fuentes/dark-nights/x/Dark Nights Day-night-cycle"
for t in Terrain Unit; do imp+=("war3mapImported\\DNCDarkNightsLordaeron$t.mdx=$D/DNCDarkNightsLordaeron$t.mdx"); done
for i in 1 2 3; do imp+=("war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14z v14z-prueba-dia v14z-prueba-tarde v14z-prueba-noche v14z-prueba-intro; do
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
sha256sum TerrainDev-Titulo-v14z*.w3x
