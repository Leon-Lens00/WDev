#!/bin/bash
# v16t-shots (13/11/2026): v16t-perfora con el MP5 en Shot (vol. 1) y el fusil de asalto en Shot II (shots_v16t.py).
# Sólo cambia el j. Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16t-perfora.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-shots-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-perfora.w3x; O=TerrainDev-Titulo-v16t-shots.w3x
echo "d97e601ff3c6a19eba93d58868a998104d2753a2122e435d25a790878c88da6c  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t-perfora/war3map.j || { echo "la base no coincide con v16t-perfora/war3map.j"; exit 1; }
mkdir -p v16t-shots
python3 -I scripts/shots_v16t.py v16t-perfora/war3map.j v16t-shots/war3map.j || exit 1
$PJ v16t-shots/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-shots/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file v16t-shots/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v16t-shots/war3map.j || { echo "reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -m2 'DIFFERS\|identical'
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
