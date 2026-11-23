#!/bin/bash
# v22j (23/11/2026): la tabla de resultados cuadra con varios jugadores y la columna de daño es más ancha.
# Normal sobre v22i; prueba sobre v22i-prueba. Cambian el j (v22j.py) y war3mapImported\PuntTabla.blp (puntos_v22j.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v22j-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
$PYP -I scripts/puntos_v22j.py $FUENTE fuentes/puntos-v22j > /dev/null || exit 1
TEX='war3mapImported\PuntTabla.blp'; NT=fuentes/puntos-v22j/PuntTabla.blp
for par in "v22i 34f5874d24a5464cea7945cb5a4998b3836547705ce0445b3d9a522720ca8d4b v22j normal" \
           "v22i-prueba d74be19b48ce300e7d02fdde8652437854aa5791604c0f9018484b908b34b75a v22j-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B "$TEX" -o $P/tex-base.blp > /dev/null || exit 1
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v22j.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c1.w3x > /dev/null || exit 1
  $W mpq add $P/c1.w3x "$TEX" --file $NT -o $P/c2.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c2.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  $W extract $O "$TEX" -o $P/re.blp > /dev/null && cmp -s $P/re.blp $NT || { echo "$N: reextracción de la tabla distinta"; exit 1; }
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|war3mapImported\\PuntTabla\.blp|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
WOE=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII/Maps/Test
for N in v22j v22j-prueba; do
  cp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && cmp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && echo "WOE $N: copiado"
done
