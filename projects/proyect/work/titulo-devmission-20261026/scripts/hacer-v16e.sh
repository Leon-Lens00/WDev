#!/bin/bash
# v16e: el Tauren del tutorial es una pareja real con las habilidades de la partida (disparo, movimiento artificial,
# recarga, escopeta y dash), HUD del tutorial y botón de Recarga en la consola (v16e.py; objetos_v16e.py: DS1O).
# Del mapa v16d cambian war3map.j y war3map.w3b. v16e-prueba: notas en lat\v16e-1.txt (prueba_v16e.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16e-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16d.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16d/war3map.j || { echo "v16d/war3map.j no es el del mapa v16d"; exit 1; }
for f in war3map.w3b war3map.imp; do $W extract $B $f -o $P/obj/$f > /dev/null || { echo "no sale $f de v16d"; exit 1; }; done
mkdir -p v16e v16e-prueba
python3 -I scripts/objetos_v16e.py $P/obj v16e || exit 1
python3 -I scripts/v16e.py v16d/war3map.j v16e/war3map.j || exit 1
python3 -I scripts/prueba_v16e.py v16e/war3map.j v16e-prueba/war3map.j || exit 1
for f in v16e v16e-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
for sal in v16e v16e-prueba; do
  lista=("war3map.j=$sal/war3map.j" "war3map.w3b=v16e/war3map.w3b")
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
sha256sum TerrainDev-Titulo-v16e*.w3x
