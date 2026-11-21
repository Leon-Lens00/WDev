#!/bin/bash
# v18n (15/11/2026): sobre v18m, sólo cambia war3map.j (v18n.py): el recuento de bolsas empieza 2 s antes del
# final del sonido de misión completada (Punt_Ini[1] 3,45). Salidas: TerrainDev-Titulo-v18n.w3x y -prueba (lat\v18n-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18n-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18n v18n-prueba
for v in v18m v18m-prueba; do
  case $v in v18m) H=499341a1dee935c444cb6927ae44811344b7cfceba6ab98a47bdcc3323743c06; M=;; *) H=0200edfaa474e7a80e33bdb34aaa01cd49ef98a4bed0a1cbcab91f3dcde4abde; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18m/v18n}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18n.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.j " ] || { echo "$N: cambió algo más que el j: $D"; exit 1; }
  $W mpq bytes-diff $B $O | grep -q 'DIFFERS. 3 changed, 0 only in A, 0 only in B' || { echo "$N: entradas añadidas o quitadas"; exit 1; }
  echo "$N: j reextraído; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
