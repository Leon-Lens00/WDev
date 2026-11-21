#!/bin/bash
# Copia LAN de v14zo para 2 clientes (puente_lan_v14zo.py) y su map.cfg para ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v14zo.w3x war3map.j -o /tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zo-base.j > /dev/null && cmp -s /tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zo-base.j v14zo/war3map.j || { echo "v14zo/war3map.j no es el del mapa"; exit 1; }
mkdir -p v14zo-lan; python3 -I scripts/puente_lan_v14zo.py v14zo/war3map.j v14zo-lan/war3map.j || exit 1
$PJ v14zo-lan/war3map.j | tail -1 | grep -q 'Parse successful' || { $PJ v14zo-lan/war3map.j | tail -6; exit 1; }
B=TerrainDev-Titulo-v14zo-lan.w3x
$W mpq add TerrainDev-Titulo-v14zo.w3x war3map.j --file v14zo-lan/war3map.j -o $B | tail -1 | grep -v round-trips
[ -d v14zo-lan/x ] && gio trash v14zo-lan/x
$W mpq extract-all $B -o v14zo-lan/x | tail -1 | cut -c1-80
cmp -s v14zo-lan/x/war3map.j v14zo-lan/war3map.j || { echo 'reextracción distinta'; exit 1; }
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $B v14zo-lan/x $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v14zo-lan/map.cfg || exit 1
grep -v 'map_size\|map_info\|map_crc\|map_sha1' v14zo-lan/map.cfg | head -30
sha256sum $B
