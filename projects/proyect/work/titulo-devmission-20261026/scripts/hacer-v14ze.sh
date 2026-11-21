#!/bin/bash
# v14ze: doodads del juego reemplazados con su misma ruta (doodads_v14ze.cjs): juncos RiverRushes sombreados y
# antorchas/faroles/Firepot sin luz ni halo. v14ze (normal) = j de v14zb con LightWhite1500; v14ze-prueba-tarde/-noche =
# las de v14zd («-luz N», Luz1..10 con Death).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14ze; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract TerrainDev-Titulo-v14zb.w3x war3map.j -o $P/v14zb-base.j > /dev/null && cmp -s $P/v14zb-base.j v14zb/war3map.j || { echo 'v14zb/war3map.j no es el del mapa v14zb'; exit 1; }
$W extract TerrainDev-Titulo-v14s.w3x 'war3mapImported\StormLuz.mdx' -o $P/luz.mdx > /dev/null && cmp -s $P/luz.mdx storm-luz/StormLuz.mdx || { echo 'StormLuz de v14s distinto'; exit 1; }
node scripts/doodads_v14ze.cjs fuentes/doodads-juego/orig doodads-v14ze > /dev/null || exit 1
node scripts/luz_variantes_muerte.cjs "fuentes/light-lights/x/Light White 700/LightWhite700.mdx" luz-prueba-d > /dev/null || exit 1
mkdir -p v14ze v14ze-prueba-tarde v14ze-prueba-noche
cp v14zb/war3map.j v14ze/war3map.j
for var in tarde noche; do
  python3 -I scripts/prueba_v14zd.py v14zb/war3map.j v14ze-prueba-$var/war3map.j directa $var || exit 1
  sed -i "s/lat\\\\\\\\v14zd-/lat\\\\\\\\v14ze-/" v14ze-prueba-$var/war3map.j
done
for f in v14ze v14ze-prueba-tarde v14ze-prueba-noche; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14y/obj-out/war3map.w3u" "war3mapImported\\StormLuz.mdx=storm-luz/StormLuz.mdx")
while read -r r; do imp+=("${r//\//\\}=doodads-v14ze/$r"); done < <(cd doodads-v14ze && find Doodads -name '*.mdx' | sort)
luces=(); for i in $(seq 1 10); do luces+=("war3mapImported\\Luz$i.mdx=luz-prueba-d/Luz$i.mdx"); done
D="fuentes/dark-nights/x/Dark Nights Day-night-cycle"
for t in Terrain Unit; do imp+=("war3mapImported\\DNCDarkNightsLordaeron$t.mdx=$D/DNCDarkNightsLordaeron$t.mdx"); done
for i in 1 2 3; do imp+=("war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14ze v14ze-prueba-tarde v14ze-prueba-noche; do
  cur=$B; n=0
  if [ $sal = v14ze ]; then extra=("war3mapImported\\LightWhite1500.mdx=luz-1500/LightWhite1500.mdx"); else extra=("${luces[@]}"); fi
  lista=("war3map.j=$sal/war3map.j" "${imp[@]}" "${extra[@]}")
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
sha256sum TerrainDev-Titulo-v14ze*.w3x
