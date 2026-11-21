#!/bin/bash
# v14zo: fase 6 de docs/planes/devmission-armas-rachas-v14zj.md (rachas, multimuertes, voces y marcador). Del mapa v14zn
# cambian war3map.j (v14zo.py) y war3map.imp (objetos_v14zo.py), y se añaden los 14 sonidos de racha-v14zo/ (WaveSys).
# v14zo-prueba-dia: las de prueba_v14zo.py («-sumar N», «-matar N», «-caer», «-rachas»), de día, registro en lat\v14zo-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zo-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zn.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zn/war3map.j || { echo "v14zn/war3map.j no es el del mapa v14zn"; exit 1; }
$W extract $B war3map.imp -o $P/obj/war3map.imp > /dev/null || { echo "no sale war3map.imp de v14zn"; exit 1; }
mkdir -p v14zo v14zo-prueba-dia
python3 -I scripts/objetos_v14zo.py $P/obj/war3map.imp v14zo/war3map.imp || exit 1
python3 -I scripts/v14zo.py v14zn/war3map.j v14zo/war3map.j || exit 1
python3 -I scripts/prueba_v14zo.py v14zo/war3map.j v14zo-prueba-dia/war3map.j directa dia || exit 1
for f in v14zo v14zo-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.imp=v14zo/war3map.imp")
for f in $(python3 -I -c "import sys;sys.path.insert(0,'scripts');from v14zo_datos import SONIDOS;print(' '.join(SONIDOS))"); do
  imp+=("war3mapImported\\$f=racha-v14zo/$f")
done
[ ${#imp[@]} = 15 ] || { echo "faltan sonidos: ${#imp[@]}"; exit 1; }
for sal in v14zo v14zo-prueba-dia; do
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
sha256sum TerrainDev-Titulo-v14zo*.w3x
