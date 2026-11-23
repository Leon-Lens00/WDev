#!/bin/bash
# v22k-prueba (23/11/2026): "-tabla [N]" saca el cuadro de resultados con N jugadores inventados (v22k.py).
# Sólo prueba, sobre v22j-prueba; la normal sigue siendo v22j. Sólo cambia el j.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v22k-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
v=v22j-prueba; H=43363d01679c280e52eab72d73cde8b429ac4c8ae815e500b58c256ba2a3af45; N=v22k-prueba
B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
echo "$H  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
python3 -I scripts/v22k.py $v/war3map.j $N/war3map.j prueba > /dev/null || exit 1
bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
$W mpq add $B war3map.j --file $N/war3map.j -o $P/c1.w3x > /dev/null || exit 1
{ head -c 512 $B; tail -c +513 $P/c1.w3x; } > $O
[ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
$W mpq bytes-diff $B $O > $P/$N-diff.txt
D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
echo "$N: difieren $D"
X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|')
[ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
grep -i 'only in' $P/$N-diff.txt
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
WOE=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII/Maps/Test
cp $O $WOE/DevMission-$N.w3x && cmp $O $WOE/DevMission-$N.w3x && echo "WOE $N: copiado"
