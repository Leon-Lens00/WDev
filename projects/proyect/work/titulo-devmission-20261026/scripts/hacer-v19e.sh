#!/bin/bash
# v19e-prueba (19/11/2026): diagnóstico de las copias de D.O.N (v19e.py) en lat\v19e-don.txt y arranque en la oleada 6.
# Sólo variante de prueba, sobre v19d-prueba; cambia únicamente war3map.j. El mapa normal sigue siendo v19d.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19e-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
v=v19d-prueba; H=9ababbd0b0220083de8ec4a8053aab98ae98434bba26289cdbfb7aa2db4ada52; N=v19e-prueba
B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
echo "$H  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
python3 -I scripts/v19e.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
$W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
{ head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
[ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción de war3map.j distinta"; exit 1; }
D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
[ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j" ] || { echo "$N: cambió otra cosa: $D"; exit 1; }
echo "$N: j reextraído; cabecera igual a $v"
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
