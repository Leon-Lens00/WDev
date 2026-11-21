#!/bin/bash
# v18s (15/11/2026): sobre v18r cambian war3map.j (v18s.py) y 3 sonidos del cuadro de puntuación, más fuertes
# (sonidos-v18s/: PuntSube, PuntSubeFin, PuntPerdida). Salidas: v18s, -prueba y -lan con map.cfg.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18s-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18s v18s-prueba v18s-lan
for v in v18r v18r-prueba v18r-lan; do
  case $v in v18r) H=7e51f435a03c416cee72853517b7281de8f0b7c5d35f7a6a00b654a3a2ca0f73; M=;; v18r-prueba) H=9784a2cf8e3b52fc5378d85f3836c5dccecce7520dd208c18fb1e89fc2bb5c6d; M=prueba;; *) H=09e4dea9358a4073576211ac534c30b62430570a0161cce493867738e4c8c3f6; M=lan;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18r/v18s}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18s.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  for w in PuntSube PuntSubeFin PuntPerdida; do
    $W mpq add $P/a.w3x "war3mapImported\\$w.wav" --file sonidos-v18s/$w.wav -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
  done
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for w in PuntSube PuntSubeFin PuntPerdida; do
    $W extract $O "war3mapImported\\$w.wav" -o $P/rw > /dev/null && cmp -s $P/rw sonidos-v18s/$w.wav || { echo "$N: $w.wav distinto"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$(echo $D | sed 's/(attributes) //; s/(listfile) //')" = "war3mapImported\\PuntPerdida.wav war3mapImported\\PuntSubeFin.wav war3mapImported\\PuntSube.wav war3map.j" ] || { echo "$N: cambió algo más que el j: $D"; exit 1; }
  $W mpq bytes-diff $B $O | grep -q 'DIFFERS. [56] changed, 0 only in A, 0 only in B' || { echo "$N: entradas añadidas o quitadas"; exit 1; }
  echo "$N: j reextraído; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# map.cfg de la LAN para ydhost (como hacer-lan-v14zo.sh).
D=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE
mkdir -p $P/lanx; $W mpq extract-all TerrainDev-Titulo-v18s-lan.w3x -o $P/lanx > /dev/null || exit 1
python3 -I ../negro-terreno-20261026/scripts/ydhost_mapcfg.py TerrainDev-Titulo-v18s-lan.w3x $P/lanx $D/compiler/jass/24/common.j $D/compiler/jass/24/blizzard.j > v18s-lan/map.cfg || exit 1
echo "map.cfg: $(grep -c . v18s-lan/map.cfg) líneas"
