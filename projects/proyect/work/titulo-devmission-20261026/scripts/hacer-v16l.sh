#!/bin/bash
# v16l: igual que v16k salvo war3mapImported\SueloAzur.blp, rehecho con el formato de NegroSolido.blp (suelo_v16l.py).
# v16l-prueba: notas en lat\v16l-1.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16l-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v16l v16l-prueba suelo-v16l
for sal in v16k v16k-prueba; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
$W extract TerrainDev-Titulo-v16j.w3x 'war3mapImported\NegroSolido.blp' -o $P/NegroSolido.blp > /dev/null || exit 1
python3 -I scripts/suelo_v16l.py $P/NegroSolido.blp suelo-v16l/SueloAzur.blp || exit 1
cp v16k/war3map.j v16l/war3map.j
sed 's/lat\\\\v16k-/lat\\\\v16l-/' v16k-prueba/war3map.j > v16l-prueba/war3map.j
/usr/bin/grep -a -c 'lat\\\\v16l-' v16l-prueba/war3map.j | grep -qx 1 || { echo "ruta del registro"; exit 1; }
for f in v16l v16l-prueba; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v16l v16l-prueba; do
  B=TerrainDev-Titulo-${sal/v16l/v16k}.w3x
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal-1.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W mpq add $P/$sal-1.w3x 'war3mapImported\SueloAzur.blp' --file suelo-v16l/SueloAzur.blp -o $P/$sal-2.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal-2.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "war3map.j=$sal/war3map.j" "war3mapImported\\SueloAzur.blp=suelo-v16l/SueloAzur.blp"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  for f in war3map.w3u war3map.w3b war3map.w3a war3map.imp 'war3mapImported\SueloAzur.mdx'; do
    $W extract TerrainDev-Titulo-$sal.w3x "$f" -o $P/a > /dev/null; $W extract $B "$f" -o $P/b > /dev/null; cmp -s $P/a $P/b || { echo "$f cambió en $sal"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16l*.w3x
