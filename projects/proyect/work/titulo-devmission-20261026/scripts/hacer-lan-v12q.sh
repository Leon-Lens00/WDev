#!/bin/bash
# Copia LAN de v12q y su map.cfg.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12q-lan; python3 scripts/puente_rondas_lan_v12q.py $PWD/v12q/war3map.j $PWD/v12q-lan/war3map.j || exit 1
$PJ v12q-lan/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
B=TerrainDev-Titulo-v12q-lan.w3x
$W mpq add TerrainDev-Titulo-v12q.w3x war3map.j --file v12q-lan/war3map.j -o $B | tail -1 | grep -v round-trips
[ -d v12q-lan/x ] && gio trash v12q-lan/x
$W mpq extract-all $B -o v12q-lan/x | tail -1 | cut -c1-80
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $B v12q-lan/x $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v12q-lan/map.cfg || exit 1
diff <(grep -v 'map_size\|map_info\|map_crc\|map_sha1' v12i-lan/map.cfg) <(grep -v 'map_size\|map_info\|map_crc\|map_sha1' v12q-lan/map.cfg) && echo same-slots
sha256sum $B
