#!/bin/bash
# v18p (15/11/2026): sobre v18p, sólo cambia war3map.j (v18p.py): 8 s con tic para recoger las bolsas, luego el cuadro
# de resultados y después el tiempo de compra y el golem. Salidas: v18p, -prueba (lat\v18p-*.txt) y -lan
# (lat\j<id>-v18p-*.txt, desde v18p-lan) con su map.cfg para ydhost.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18p-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18p v18p-prueba v18p-lan
for v in v18o v18o-prueba v18o-lan; do
  case $v in v18o) H=db0cf5e091c8d53d4fb976403c528b90651564384fbff122d769296097efe1f4; M=;; v18o-prueba) H=f29d64474b08853514bcfaf49bad1f2fdfacb58e8d2e0f99f5ed261f55bf99d2; M=prueba;; *) H=4de372f5efd204e74bd86300aaf6e11f3b6b3f85d603c0d5d7e0f9a861f76009; M=lan;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18o/v18p}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18p.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
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
mkdir -p $P/lanx; $W mpq extract-all TerrainDev-Titulo-v18p-lan.w3x -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v18p-lan.w3x $P/lanx $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v18p-lan/map.cfg || exit 1
echo "map.cfg: $(grep -c . v18p-lan/map.cfg) líneas"
