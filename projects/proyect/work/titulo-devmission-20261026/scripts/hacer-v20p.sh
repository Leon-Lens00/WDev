#!/bin/bash
# v20p-lan (20/11/2026): LAN de dos jugadores rojo y morado (slots 2 y 3 cerrados) con vidas infinitas, sobre v20o.
# Sólo cambia el j (v20p.py); map.cfg para ydhost generado del mapa, con azul y verde azulado cerrados.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20p-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
v=v20o; H=f411ede03c147f2de8acd250e067a559f776d6f9d312e9fe0ece8501c3194227; N=v20p-lan
B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
echo "$H  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
python3 -I scripts/v20p.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
$W mpq add $B war3map.j --file $N/war3map.j -o $P/c1.w3x > /dev/null || exit 1
{ head -c 512 $B; tail -c +513 $P/c1.w3x; } > $O
[ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O > $P/$N-diff.txt
D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
echo "$N: difieren $D"; grep -qxE '\(attributes\)( \(listfile\))? war3map.j' <<< "${D% }" || { echo "$N: cambió algo más: $D"; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
Y=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all $O -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py $O $P/lanx $Y/compiler/jass/24/common.j $Y/compiler/jass/24/blizzard.j > $P/map.cfg || exit 1
# Rojo (color 0) y morado (color 3): se cierran los huecos de azul (1) y verde azulado (2).
python3 -I - $P/map.cfg $N/map.cfg <<'PY'
import sys, re
t = open(sys.argv[1]).read().splitlines()
out = []
for l in t:
    m = re.match(r'map_slot(\d+) = (.*)', l)
    if m:
        f = m.group(2).split()
        if f[5] in ('1', '2'):
            f[2] = '1'
        l = f'map_slot{m.group(1)} = ' + ' '.join(f)
    out.append(l)
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
PY
grep '^map_slot' $N/map.cfg
