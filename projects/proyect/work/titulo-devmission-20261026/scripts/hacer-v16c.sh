#!/bin/bash
# v16c: consola del tutorial en cuadrícula 3 × 4 (v16c.py). Del mapa v16b cambian war3map.j, war3map.w3b y
# war3map.imp (objetos_v16c.py: DS1F..DS1N) y se añade war3mapImported\TutCasilla.blp (tutorial_tex_v16c.py).
# v16c-prueba: con las notas del tutorial en lat\v16c-1.txt (prueba_v16c.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16c-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16b.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16b/war3map.j || { echo "v16b/war3map.j no es el del mapa v16b"; exit 1; }
for f in war3map.w3b war3map.imp; do $W extract $B $f -o $P/obj/$f > /dev/null || { echo "no sale $f de v16b"; exit 1; }; done
mkdir -p v16c v16c-prueba
$PY -I scripts/tutorial_tex_v16c.py > /dev/null || exit 1
python3 -I scripts/objetos_v16c.py $P/obj v16c || exit 1
python3 -I scripts/v16c.py v16b/war3map.j v16c/war3map.j || exit 1
python3 -I scripts/prueba_v16c.py v16c/war3map.j v16c-prueba/war3map.j || exit 1
for f in v16c v16c-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3b=v16c/war3map.w3b" "war3map.imp=v16c/war3map.imp")
imp+=("war3mapImported\\TutCasilla.blp=tutorial-v16c/TutCasilla.blp")
for sal in v16c v16c-prueba; do
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
sha256sum TerrainDev-Titulo-v16c*.w3x
