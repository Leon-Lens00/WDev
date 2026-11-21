#!/bin/bash
# v14m: v14l con las habilidades del Prawn (scripts/v14m.py; sólo cambia war3map.j).
# Variantes: v14m-prueba (directa) y v14m-prueba-intro, con registro de habilidades (lat\v14m-hab-N.txt), y v14m-habil
# (sin oleadas: crea Prawns alrededor del personaje y mide; prueba_habil_v14m.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14m; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14l.w3x
$W extract $B war3map.j -o $P/v14l-base.j > /dev/null && cmp -s $P/v14l-base.j v14l/war3map.j || { echo 'v14l/war3map.j no es el del mapa v14l'; exit 1; }
mkdir -p v14m v14m-reg v14m-prueba v14m-prueba-intro v14m-habil
python3 scripts/v14m.py v14l/war3map.j v14m/war3map.j || exit 1
python3 scripts/v14m.py v14l/war3map.j v14m-reg/war3map.j registro || exit 1
grep -q 'Hab_Log\|Preload' v14m/war3map.j && grep -c 'Hab_Log' v14m/war3map.j | grep -qv '^0$' && { echo 'la entrega lleva Hab_Log'; exit 1; }
python3 scripts/prueba_v14m.py v14m-reg/war3map.j v14m-prueba/war3map.j directa || exit 1
python3 scripts/prueba_v14m.py v14m-reg/war3map.j v14m-prueba-intro/war3map.j intro || exit 1
python3 scripts/prueba_habil_v14m.py v14m-reg/war3map.j v14m-habil/war3map.j || exit 1
for f in v14m v14m-prueba v14m-prueba-intro v14m-habil; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
for sal in v14m v14m-prueba v14m-prueba-intro v14m-habil; do
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal.w3x | tail -1 | grep -v round-trips
  cp $P/$sal.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta: $sal"; exit 1; }
  $W mpq bytes-diff $B TerrainDev-Titulo-$sal.w3x | grep -iv "same\|match" | grep -v "war3map.j" | head -5
done
$W mpq verify TerrainDev-Titulo-v14m.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14m.w3x TerrainDev-Titulo-v14m-prueba.w3x TerrainDev-Titulo-v14m-prueba-intro.w3x TerrainDev-Titulo-v14m-habil.w3x
