#!/bin/bash
# v18l (15/11/2026): sobre v18k, sólo cambia war3map.j (v18l.py): sonido nativo de misión completada al salir el
# cuadro de puntuación, entrada retrasada 0,25 s y de 0,5 s, precarga de los wav del recuento y barras del mundo
# ocultas con el cuadro a la vista. Salidas: TerrainDev-Titulo-v18l.w3x y -prueba (lat\v18l-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18l-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18l v18l-prueba
for v in v18k v18k-prueba; do
  case $v in v18k) H=03843c440eb31c3e60723aaa74bff4fc1ab19ca384daf2103db59430dce626a2; M=;; *) H=2f92d508e8087a7bde5b5ea7cdd071319762b03df121587ad9ddee412b14bbd6; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18k/v18l}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18l.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
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
