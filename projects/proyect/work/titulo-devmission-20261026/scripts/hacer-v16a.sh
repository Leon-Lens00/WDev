#!/bin/bash
# v16a: esqueleto del tutorial (v16a.py), directo al empezar y luego a la partida. Del mapa v14zy cambian war3map.j,
# war3map.w3e y war3map.wpm (terreno_v16a.py: recinto llano en X 6000..10000, Y 7500..9500), war3map.w3b y
# war3map.imp (objetos_v16a.py: DS1A..DS1E) y se añaden TutFoco, TutPanel, TutMano y TutMira (tutorial_tex_v16a.py).
# v16a-prueba: con las notas del tutorial en lat\v16a-1.txt (prueba_v16a.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16a-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zy.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zy/war3map.j || { echo "v14zy/war3map.j no es el del mapa v14zy"; exit 1; }
for f in war3map.w3e war3map.wpm war3map.w3b war3map.imp; do $W extract $B $f -o $P/obj/$f > /dev/null || { echo "no sale $f de v14zy"; exit 1; }; done
mkdir -p v16a v16a-prueba
$PY -I scripts/tutorial_tex_v16a.py > /dev/null || exit 1
python3 -I scripts/terreno_v16a.py $P/obj v16a || exit 1
python3 -I scripts/objetos_v16a.py $P/obj v16a || exit 1
python3 -I scripts/v16a.py v14zy/war3map.j v16a/war3map.j || exit 1
python3 -I scripts/prueba_v16a.py v16a/war3map.j v16a-prueba/war3map.j || exit 1
for f in v16a v16a-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3e=v16a/war3map.w3e" "war3map.wpm=v16a/war3map.wpm" "war3map.w3b=v16a/war3map.w3b" "war3map.imp=v16a/war3map.imp")
for n in TutFoco TutPanel TutMano TutMira; do imp+=("war3mapImported\\$n.blp=tutorial-v16a/$n.blp"); done
for sal in v16a v16a-prueba; do
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
sha256sum TerrainDev-Titulo-v16a*.w3x
