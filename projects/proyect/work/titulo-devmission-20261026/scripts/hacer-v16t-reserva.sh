#!/bin/bash
# v16t-reserva (14/11/2026): v16t-relojes con la reserva del reciclador de balas restaurada, 8 × 32 = 256
# (reserva32.py). Plan: Proyect/docs/planes/devmission-don-v16u.md.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-reserva-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-relojes.w3x; sal=v16t-reserva; O=TerrainDev-Titulo-$sal.w3x
echo "06995f1e081fed4d8a2a04951a062e1613c2ad239a70926829628ef0beb063a3  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v16t-relojes/war3map.j || { echo "v16t-relojes/war3map.j no es el del mapa"; exit 1; }
mkdir -p $sal
python3 -I scripts/reserva32.py v16t-relojes/war3map.j v13e/war3map.j $sal/war3map.j || exit 1
$PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file $sal/war3map.j -o $O | tail -1
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
$W mpq bytes-diff $B $O | grep -m2 "DIFFERS\|identical"
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
