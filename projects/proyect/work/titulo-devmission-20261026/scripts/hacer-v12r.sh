#!/bin/bash
# v12r: v12q con el dash de Missile.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
D=/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/entregas/dash-20261031
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=v12q/x; mkdir -p v12r
python3 scripts/dash_v12r.py v12q/war3map.j v12r/war3map.j || exit 1
python3 scripts/objetos_v12r.py $D $X/war3map.w3a v12r/war3map.w3a v12q/war3map.imp v12r/war3map.imp || exit 1
python3 -I - $D <<'P' || exit 1
import hashlib, json, pathlib, sys
d = pathlib.Path(sys.argv[1], 'imports')
for e in json.loads((d / 'imports.json').read_text(encoding='utf-8'))['imports']:
    f = d / e['internal'].replace('\\', '/')
    assert hashlib.sha256(f.read_bytes()).hexdigest() == e['sha256'], f
print('hashes ok')
P
$PJ v12r/war3map.j | tail -6 | grep -v 'common.j\|Blizzard.j'
B=TerrainDev-Titulo-v12r.w3x; cp TerrainDev-Titulo-v12q.w3x $B
add(){ $W mpq add $B "$1" --file "$2" -o $B.tmp | tail -1 | grep -v 'round-trips'; mv $B.tmp $B; }
add war3map.j v12r/war3map.j; add war3map.imp v12r/war3map.imp; add war3map.w3a v12r/war3map.w3a
for f in $D/imports/ValiantCharge/*; do add "ValiantCharge\\$(basename "$f")" "$f"; done
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12q.w3x $B | grep -i 'differs\|changed' | tail -3
sha256sum $B; ls -la $B | cut -c24-
