#!/bin/bash
# v14j: v14i con el terreno ensanchado por el usuario (scripts/terreno_v14j.py); y los límites de cámara de main (scripts/v14j.py).
# También v14j-vista (tienda, scripts/vista3_v14j.py) y v14j-intro (intro y título, scripts/vista3t_v14j.py) para
# fotografiar el minimapa, y v14j-prueba (entrada directa) y v14j-prueba-intro (scripts/prueba_v14j.py) para que Leon juegue; la primera prueba (v14i-vista, scripts/vista_v14j.py) quedó en evidencia/.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14j; mkdir -p $P/vi $P/an
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v14i.w3x war3map.j -o $P/v14i-base.j > /dev/null && cmp -s $P/v14i-base.j v14i/war3map.j || { echo 'v14i/war3map.j no es el del mapa v14i'; exit 1; }
$W extract TerrainDev-Titulo-v14i.w3x war3map.doo -o $P/vi/war3map.doo > /dev/null || exit 1
for f in w3e wpm shd w3i; do
  $W extract TerrainDev-Titulo-v14i.w3x war3map.$f -o $P/vi/war3map.$f > /dev/null || exit 1
  $W extract puntos/Swamped-Puntos-v14g.w3x war3map.$f -o $P/an/war3map.$f > /dev/null || exit 1
done
mkdir -p v14j v14j-vista v14j-intro v14j-prueba v14j-prueba-intro
python3 scripts/terreno_v14j.py $P/vi $P/an v14j || exit 1
python3 scripts/v14j.py v14i/war3map.j v14j/war3map.j || exit 1
python3 scripts/vista3_v14j.py v14j/war3map.j v14j-vista/war3map.j || exit 1
python3 scripts/vista3t_v14j.py v14j/war3map.j v14j-intro/war3map.j || exit 1
python3 scripts/prueba_v14j.py v14j/war3map.j v14j-prueba/war3map.j directa || exit 1
python3 scripts/prueba_v14j.py v14j/war3map.j v14j-prueba-intro/war3map.j intro || exit 1
for f in v14j v14j-vista v14j-intro v14j-prueba v14j-prueba-intro; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14j v14j-vista v14j-intro v14j-prueba v14j-prueba-intro; do
  cur=TerrainDev-Titulo-v14i.w3x; n=0
  add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$sal-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$sal-$n.w3x"; }
  add war3map.j $sal/war3map.j
  for f in w3e wpm shd w3i doo; do add war3map.$f v14j/war3map.$f; done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for f in war3map.j war3map.w3e war3map.wpm war3map.shd war3map.w3i war3map.doo; do
    src=$sal/$f; [ $f = war3map.j ] || src=v14j/$f;
    $W extract TerrainDev-Titulo-$sal.w3x $f -o $P/re > /dev/null && cmp -s $P/re $src || { echo "reextracción distinta: $sal $f"; exit 1; }
  done
done
$W mpq verify TerrainDev-Titulo-v14j.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14j.w3x TerrainDev-Titulo-v14j-vista.w3x TerrainDev-Titulo-v14j-intro.w3x TerrainDev-Titulo-v14j-prueba.w3x TerrainDev-Titulo-v14j-prueba-intro.w3x
