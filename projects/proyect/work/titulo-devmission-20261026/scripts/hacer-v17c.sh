#!/bin/bash
# v17c (14/11/2026): v17b con entrada directa (sin intro ni tutorial). Sólo cambia el j (v17c.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17c-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17b.w3x; O=TerrainDev-Titulo-v17c.w3x
echo "50e7a9bab946a153a1f6318a54ae6b91fcf0c5ac629854284205da85b6030cf0  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17b/war3map.j || { echo "la base no coincide con v17b/war3map.j"; exit 1; }
mkdir -p v17c
python3 -I scripts/v17c.py v17b/war3map.j v17c/war3map.j || exit 1
$PJ v17c/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v17c/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file v17c/war3map.j -o $O > /dev/null || exit 1
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v17c/war3map.j || { echo "reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -c DIFFERS
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
