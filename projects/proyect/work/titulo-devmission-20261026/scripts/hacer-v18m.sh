#!/bin/bash
# v18m (15/11/2026): sobre v18l. Cambian war3map.j (v18m.py: recuento tras el sonido de misión, precarga de texturas,
# textos con el fondo; fase 7, pantalla de inicio de la tienda) y war3map.w3b (iconos DC0H-DC0J, objetos_v18m.py).
# Salidas: TerrainDev-Titulo-v18m.w3x y -prueba (lat\v18m-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18m-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18m v18m-prueba
for v in v18l v18l-prueba; do
  case $v in v18l) H=2f2121c46558bfa4c95e12bdc72c5e010c8b7e399c4b83591e089346d6c930da; M=;; *) H=08d4f335c7357758f18564852aa3ef54063dad7628d5db749a123a08cbc26fc3; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18l/v18m}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  $W extract $B war3map.w3b -o $P/base.w3b > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18m.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
  python3 -I scripts/objetos_v18m.py $P/base.w3b $N/war3map.w3b > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/b.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.j war3map.w3b " ] || { echo "$N: cambió algo más: $D"; exit 1; }
  $W mpq bytes-diff $B $O | grep -q 'DIFFERS. 4 changed, 0 only in A, 0 only in B' || { echo "$N: entradas añadidas o quitadas"; exit 1; }
  echo "$N: j y w3b reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
