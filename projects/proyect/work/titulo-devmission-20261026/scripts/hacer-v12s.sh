#!/bin/bash
# v12s: v12r con dash en D y S, solo Shots Vol. I, emblema nuevo, apariciones por toda la arena y bot.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=v12q/x; mkdir -p v12s
python3 scripts/icono_v12s.py $X/UI/HealthBarsHorizontal/HealthIconTauren.mdx v12s/RondaIcono.mdx v12s/RondaIcono.blp || exit 1
python3 scripts/bot_v12s.py $PWD/v12r/war3map.j $PWD/v12s/war3map.j $X || exit 1
python3 scripts/objetos_v12s.py v12r/war3map.w3a v12s/war3map.w3a || exit 1
$PJ v12s/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
B=TerrainDev-Titulo-v12s.w3x; cp TerrainDev-Titulo-v12r.w3x $B
add(){ $W mpq add $B "$1" --file "$2" -o $B.tmp | tail -1 | grep -v 'round-trips'; mv $B.tmp $B; }
add war3map.j v12s/war3map.j; add war3map.w3a v12s/war3map.w3a
add 'UI\HealthBarsHorizontal\RondaIcono.mdx' v12s/RondaIcono.mdx; add 'UI\HealthBarsHorizontal\RondaIcono.blp' v12s/RondaIcono.blp
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12r.w3x $B | grep -i 'differs\|changed' | tail -3
sha256sum $B
