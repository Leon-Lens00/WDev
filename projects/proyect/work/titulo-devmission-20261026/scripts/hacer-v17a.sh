#!/bin/bash
# v17a (13/11/2026): v16z con intro completa, título y presentación, tutorial y luego la partida (v17a.py). Sólo cambia
# el j. Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16z.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17a-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16z.w3x; O=TerrainDev-Titulo-v17a.w3x
echo "04bd7afa3d880113a2c56735dfb60798e877c43c7cea3990190750503bdd1dc5  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16z/war3map.j || { echo "la base no coincide con v16z/war3map.j"; exit 1; }
mkdir -p v17a
python3 -I scripts/v17a.py v16z/war3map.j v17a/war3map.j || exit 1
$PJ v17a/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v17a/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file v17a/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v17a/war3map.j || { echo "reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -m2 'DIFFERS\|identical'
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
