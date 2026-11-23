#!/bin/bash
# LAN de la copia de Leon de v21b (Descargas/TerrainDevv21b.w3x, pasada por un optimizador: j compactado, sin listfile,
# sin war3mapUnits.doo ni war3map.imp; imports íntegros por contenido). El mapa se copia tal cual, sin tocarlo;
# map.cfg para ydhost con azul, verde azulado y morado cerrados (rojo y amarillo juegan).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21b-leon-lan
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
F=/home/snz/Descargas/TerrainDevv21b.w3x
echo "e3372215061c6efe07832301d397df0df056ce9338d17e1a27b1d6da3155c282  $F" | sha256sum -c --quiet || exit 1
N=v21b-leon-lan; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
cp $F $O; cmp -s $F $O || exit 1
$W extract $O war3map.j -o $P/j > /dev/null || exit 1
$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j $P/j | tail -1 | grep -q '^Parse successful' || { echo "pjass falla"; exit 1; }
Y=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all $O -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $O $P/lanx $Y/compiler/jass/24/common.j $Y/compiler/jass/24/blizzard.j > $P/map.cfg || exit 1
python3 -I - $P/map.cfg $N/map.cfg <<'PY'
import sys, re
t = open(sys.argv[1]).read().splitlines()
out = []
for l in t:
    m = re.match(r'map_slot(\d+) = (.*)', l)
    if m:
        f = m.group(2).split()
        if f[5] in ('1', '2', '3'):
            f[2] = '1'
        l = f'map_slot{m.group(1)} = ' + ' '.join(f)
    out.append(l)
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
PY
grep '^map_slot\|^map_size\|^map_crc\|^map_sha1' $N/map.cfg
sha256sum $O $N/map.cfg
