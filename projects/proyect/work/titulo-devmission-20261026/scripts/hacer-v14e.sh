#!/bin/bash
# v14e: v14d con intro, mapa ampliado, menús y tienda en la franja norte y máscara negra desde el arranque.
OJO=${1:-}
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14e
python3 scripts/v14e.py v14d/war3map.j v14e/war3map.j $OJO || exit 1
$PJ v14e/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14e/war3map.j' || { echo 'pJASS falló'; exit 1; }
python3 scripts/terreno_v14e.py "$P/v14d-ext" "$P/amp-ext" v14e || exit 1
[ -f v14e/war3mapMap.blp ] || { echo 'falta minimapa'; exit 1; }
python3 -I scripts/modelo_plano.py "$P/v14d-ext/war3mapImported/TitleDummyBlend.mdl" v14e/TitleDummyFlat.mdl || exit 1
python3 scripts/w3u_tienda.py "$P/v14d-ext/war3map.w3u" v14e/war3map.w3u || exit 1
# Minimapa transparente: v14e/war3mapMap.blp, todo alfa 0, para que no sobresalga sobre la consola.
cur=TerrainDev-Titulo-v14d.w3x; n=0
add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/v14e-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/v14e-$n.w3x"; }
add war3map.j v14e/war3map.j
for f in war3map.w3e war3map.wpm war3map.w3i; do add $f v14e/$f; done
add war3map.shd "$P/amp-ext/war3map.shd"
add war3mapMap.blp v14e/war3mapMap.blp
add war3map.w3u v14e/war3map.w3u
add 'war3mapImported\TitleDummyFlat.mdl' v14e/TitleDummyFlat.mdl
cp "$cur" TerrainDev-Titulo-v14e.w3x
rm -f "${P:?}"/v14e-*.w3x
$W mpq verify TerrainDev-Titulo-v14e.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14e.w3x
