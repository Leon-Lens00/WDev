#!/bin/bash
# v18r (15/11/2026): sobre v18q, sólo cambia war3map.j (v18r.py): muestra de la Mutación Evo como cuadro central de
# interfaz con la cámara en el héroe. Salidas: v18r, -prueba (lat\v18r-*.txt) y -lan (lat\j<id>-v18r-*.txt) con map.cfg.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18r-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18r v18r-prueba v18r-lan
for v in v18q v18q-prueba v18q-lan; do
  case $v in v18q) H=afb173df742e27302dfe1d796e3124e8f157cfbb97a4c88ca1ad34df5aad2358; M=;; v18q-prueba) H=af15f153e16a3cef576a0ea827898451338b4cecdcaf0bc5359628d389523ea7; M=prueba;; *) H=38523639b5006a7b2f5e238ed47cd90dcd7737092f2b1f76fd7ff752bf52c61f; M=lan;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18q/v18r}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18r.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3map.j" ] || { echo "$N: cambió algo más que el j: $D"; exit 1; }
  $W mpq bytes-diff $B $O | grep -q 'DIFFERS. [23] changed, 0 only in A, 0 only in B' || { echo "$N: entradas añadidas o quitadas"; exit 1; }
  echo "$N: j reextraído; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# map.cfg de la LAN para ydhost (como hacer-lan-v14zo.sh).
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all TerrainDev-Titulo-v18r-lan.w3x -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v18r-lan.w3x $P/lanx $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v18r-lan/map.cfg || exit 1
echo "map.cfg: $(grep -c . v18r-lan/map.cfg) líneas"
