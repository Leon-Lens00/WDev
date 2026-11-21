#!/bin/bash
# Copia LAN de v14zi para 4 clientes (puente_lan_v14zi.py) y su map.cfg para ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$W extract TerrainDev-Titulo-v14zi.w3x war3map.j -o /tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zi-base.j > /dev/null && cmp -s /tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zi-base.j v14zi/war3map.j || { echo "v14zi/war3map.j no es el del mapa"; exit 1; }
mkdir -p v14zi-lan; python3 -I scripts/puente_lan_v14zi.py v14zi/war3map.j v14zi-lan/war3map.j || exit 1
$PJ v14zi-lan/war3map.j | tail -1 | grep -q 'Parse successful' || { $PJ v14zi-lan/war3map.j | tail -6; exit 1; }
B=TerrainDev-Titulo-v14zi-lan.w3x
$W mpq add TerrainDev-Titulo-v14zi.w3x war3map.j --file v14zi-lan/war3map.j -o $B | tail -1 | grep -v round-trips
[ -d v14zi-lan/x ] && gio trash v14zi-lan/x
$W mpq extract-all $B -o v14zi-lan/x | tail -1 | cut -c1-80
cmp -s v14zi-lan/x/war3map.j v14zi-lan/war3map.j || { echo 'reextracción distinta'; exit 1; }
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $B v14zi-lan/x $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v14zi-lan/map.cfg || exit 1
grep -v 'map_size\|map_info\|map_crc\|map_sha1' v14zi-lan/map.cfg | head -30
sha256sum $B
