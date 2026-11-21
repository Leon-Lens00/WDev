#!/bin/bash
# Copia de v14d con la intro y los menús de vuelta: sólo cambia la entrada del mapa.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14d-intro
python3 - <<'P' || exit 1
from pathlib import Path
s = Path('v14d/war3map.j').read_text(encoding='latin-1', newline='')
a = 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)'
assert s.count(a) == 1
Path('v14d-intro/war3map.j').write_text(s.replace(a, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)'), encoding='latin-1', newline='')
P
$PJ v14d-intro/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14d-intro/war3map.j' || { echo 'pJASS falló'; exit 1; }
$W mpq add TerrainDev-Titulo-v14d.w3x war3map.j --file v14d-intro/war3map.j -o TerrainDev-Titulo-v14d-intro.w3x | tail -1 | grep -v round-trips
$W mpq verify TerrainDev-Titulo-v14d-intro.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14d-intro.w3x
