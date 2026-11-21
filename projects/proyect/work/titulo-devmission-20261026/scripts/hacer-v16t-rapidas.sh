#!/bin/bash
# v16t-rapidas (13/11/2026): v16t-rpm con el fusil de asalto a 480 rpm (daño compensado) y velocidad ×2 en subfusil,
# asalto, francotirador y escopeta (rapidas_v16t.py). Sólo cambia el j. Plan: Proyect/docs/planes/devmission-don-v16u.md.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-rapidas-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-rpm.w3x; O=TerrainDev-Titulo-v16t-rapidas.w3x
echo "dcffbcdf5dc451fe0c239d932fac3218622345cc63b97f67c681c7cae80b0527  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t-rpm/war3map.j || { echo "la base no coincide con v16t-rpm/war3map.j"; exit 1; }
mkdir -p v16t-rapidas
python3 -I scripts/rapidas_v16t.py v16t-corto/war3map.j v16t-rpm/war3map.j v16t-rapidas/war3map.j > v16t-rapidas/tabla.txt || exit 1
$PJ v16t-rapidas/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-rapidas/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file v16t-rapidas/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v16t-rapidas/war3map.j || { echo "reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -m2 'DIFFERS\|identical'
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
