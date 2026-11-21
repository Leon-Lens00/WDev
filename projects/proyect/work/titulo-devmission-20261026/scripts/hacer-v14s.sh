#!/bin/bash
# v14s: luz fija de Storm (StormLuz.mdx, encendida por animación) y niebla negra en la partida (v14s.py, objetos_v14s.py,
# storm_luz.cjs). Parte del mapa v14q con el j y el w3u de v14r. Ya no importa StormDummy ni StormL1..3.
# Variantes: v14s-prueba (directa) y v14s-prueba-intro para Leon, con «-rayo N»; v14s-rayos para la prueba por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14s; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract $B war3map.j -o $P/v14q-base.j > /dev/null && cmp -s $P/v14q-base.j v14q/war3map.j || { echo 'v14q/war3map.j no es el del mapa v14q'; exit 1; }
$W extract TerrainDev-Titulo-v14r.w3x war3map.j -o $P/v14r-base.j > /dev/null && cmp -s $P/v14r-base.j v14r/war3map.j || { echo 'v14r/war3map.j no es el del mapa v14r'; exit 1; }
$W extract TerrainDev-Titulo-v14r.w3x war3map.w3u -o $P/v14r-base.w3u > /dev/null && cmp -s $P/v14r-base.w3u v14r/obj-out/war3map.w3u || { echo 'w3u de v14r distinto'; exit 1; }
mkdir -p v14s v14s-prueba v14s-prueba-intro v14s-rayos storm-luz
node scripts/storm_luz.cjs $S/Ldummy.mdx $S/L1.mdx storm-luz/StormLuz.mdx > /dev/null || exit 1
python3 -I scripts/objetos_v14s.py v14r/obj-out v14s/obj-out || exit 1
python3 -I scripts/v14s.py v14r/war3map.j v14s/war3map.j || exit 1
python3 -I scripts/prueba_v14s.py v14s/war3map.j v14s-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v14s.py v14s/war3map.j v14s-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v14s.py v14s/war3map.j v14s-rayos/war3map.j rayos || exit 1
for f in v14s v14s-prueba v14s-prueba-intro v14s-rayos; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14s/obj-out/war3map.w3u" "war3mapImported\\StormLuz.mdx=storm-luz/StormLuz.mdx")
for i in 1 2 3; do imp+=("war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14s v14s-prueba v14s-prueba-intro v14s-rayos; do
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
sha256sum TerrainDev-Titulo-v14s.w3x TerrainDev-Titulo-v14s-prueba.w3x TerrainDev-Titulo-v14s-prueba-intro.w3x TerrainDev-Titulo-v14s-rayos.w3x
