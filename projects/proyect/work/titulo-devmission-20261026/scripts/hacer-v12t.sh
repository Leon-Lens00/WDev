#!/bin/bash
# v12t: v12s con el bot eligiendo en los menús y el emblema más pequeño.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=v12q/x; mkdir -p v12t
python3 scripts/icono_v12s.py $X/UI/HealthBarsHorizontal/HealthIconTauren.mdx v12t/RondaIcono.mdx v12t/RondaIcono.blp || exit 1
python3 scripts/menu_v12t.py $PWD/v12s/war3map.j $PWD/v12t/war3map.j || exit 1
$PJ v12t/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
B=TerrainDev-Titulo-v12t.w3x; cp TerrainDev-Titulo-v12s.w3x $B
add(){ $W mpq add $B "$1" --file "$2" -o $B.tmp | tail -1 | grep -v 'round-trips'; mv $B.tmp $B; }
add war3map.j v12t/war3map.j
add 'UI\HealthBarsHorizontal\RondaIcono.mdx' v12t/RondaIcono.mdx; add 'UI\HealthBarsHorizontal\RondaIcono.blp' v12t/RondaIcono.blp
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12s.w3x $B | grep -i 'differs\|changed' | tail -3
sha256sum $B
