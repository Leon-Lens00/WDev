#!/bin/bash
# v12u: v12t con el bot desactivado. El código se conserva; con Bot_HUMANOS 0 no entra ni en menús ni en juego.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v12u
python3 -I - <<'P'
from pathlib import Path
s = Path('v12t/war3map.j').read_text(encoding='latin-1', newline='')
old = 'constant integer Bot_HUMANOS = 1\r\n'
assert s.count(old) == 1
Path('v12u/war3map.j').write_text(s.replace(old, 'constant integer Bot_HUMANOS = 0\r\n'), encoding='latin-1', newline='')
P
$PJ v12u/war3map.j | tail -1
B=TerrainDev-Titulo-v12u.w3x
$W mpq add TerrainDev-Titulo-v12t.w3x war3map.j --file v12u/war3map.j -o $B | tail -1 | grep -v round-trips
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12t.w3x $B | grep -i 'differs\|changed' | tail -3
sha256sum $B
