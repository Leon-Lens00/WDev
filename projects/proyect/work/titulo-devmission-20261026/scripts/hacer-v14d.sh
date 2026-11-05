#!/bin/bash
# v14d: v14c con disparo rápido nativo, más enemigos, cámara alta, diez canciones y vida en la tienda.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14d-pack
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14d v14d/base "$P"
python3 scripts/v14d.py v14c/war3map.j v14d/war3map.j || exit 1
$PJ v14d/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14d/war3map.j' || { echo 'pJASS falló'; exit 1; }
if [ ! -f v14d/base/war3map.w3u ]; then
    $W mpq extract-all TerrainDev-Titulo-v14c.w3x -o "$P/ext" >/dev/null || exit 1
    cp "$P/ext/war3map.w3u" "$P/ext/war3map.w3a" v14d/base/
fi
python3 scripts/objetos_v14d.py v14d/base v14d || exit 1
cur=TerrainDev-Titulo-v14c.w3x; n=0
add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$n.w3x"; }
add war3map.j v14d/war3map.j
add war3map.w3a v14d/war3map.w3a
add war3map.w3u v14d/war3map.w3u
for i in 7 8 9 10; do add "war3mapImported\\OleadaTema$i.mp3" temas-devtest6/OleadaTema$i.mp3; done
cp "$cur" TerrainDev-Titulo-v14d.w3x
rm -f "${P:?}"/*.w3x
$W mpq verify TerrainDev-Titulo-v14d.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14d.w3x
ls -la TerrainDev-Titulo-v14d.w3x | cut -c24-
