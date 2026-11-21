#!/bin/bash
# v17a-tuto (13/11/2026): v17a con entrada directa al tutorial y luego la partida (v17a_tuto.py). Sólo cambia el j.
# Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v17a.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17a-tuto-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17a.w3x; O=TerrainDev-Titulo-v17a-tuto.w3x
echo "a6193565fffbde592f7dcee89c7d130d458f455cb67cb4e74490366cf18513d5  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17a/war3map.j || { echo "la base no coincide con v17a/war3map.j"; exit 1; }
mkdir -p v17a-tuto
python3 -I scripts/v17a_tuto.py v17a/war3map.j v17a-tuto/war3map.j || exit 1
$PJ v17a-tuto/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v17a-tuto/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file v17a-tuto/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v17a-tuto/war3map.j || { echo "reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -m2 'DIFFERS\|identical'
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
