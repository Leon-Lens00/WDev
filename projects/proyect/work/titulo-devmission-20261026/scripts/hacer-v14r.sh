#!/bin/bash
# v14r: relámpagos y truenos de Storm v1.3.1 (OVOgenez, Hive 356042) durante las oleadas (v14r.py, objetos_v14r.py).
# Parte del mapa v14q. Recursos de fuentes/storm-1.3.1/paquete: Ldummy.mdx, L1..L3.mdx y T1..T3.wav, renombrados en
# war3mapImported (StormDummy, StormL1..3, StormT1..3).
# Variantes: v14r-prueba (directa) y v14r-prueba-intro para Leon, con «-rayo N»; v14r-rayos para la prueba por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14r; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract $B war3map.j -o $P/v14q-base.j > /dev/null && cmp -s $P/v14q-base.j v14q/war3map.j || { echo 'v14q/war3map.j no es el del mapa v14q'; exit 1; }
mkdir -p v14r/obj-in v14r-prueba v14r-prueba-intro v14r-rayos
$W extract $B war3map.w3u -o v14r/obj-in/war3map.w3u > /dev/null || exit 1
python3 -I scripts/objetos_v14r.py fuentes/storm-1.3.1/ej/war3map.w3u v14r/obj-in v14r/obj-out || exit 1
python3 -I scripts/v14r.py v14q/war3map.j v14r/war3map.j || exit 1
python3 -I scripts/prueba_v14r.py v14r/war3map.j v14r-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v14r.py v14r/war3map.j v14r-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v14r.py v14r/war3map.j v14r-rayos/war3map.j rayos || exit 1
for f in v14r v14r-prueba v14r-prueba-intro v14r-rayos; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14r/obj-out/war3map.w3u" "war3mapImported\\StormDummy.mdx=$S/Ldummy.mdx")
for i in 1 2 3; do imp+=("war3mapImported\\StormL$i.mdx=$S/L$i.mdx" "war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14r v14r-prueba v14r-prueba-intro v14r-rayos; do
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
sha256sum TerrainDev-Titulo-v14r.w3x TerrainDev-Titulo-v14r-prueba.w3x TerrainDev-Titulo-v14r-prueba-intro.w3x TerrainDev-Titulo-v14r-rayos.w3x
