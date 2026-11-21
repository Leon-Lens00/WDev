#!/bin/bash
# v19p (19/11/2026): la esfera del indicador entera en rectángulo alto de puntas redondeadas, gris y teñida con el color
# de cada carta (burbuja_v19p.py + mdx_sin_billboard.py, objetos_v19p.py, v19p.py). Normal sobre v19o; prueba sobre
# v19o-prueba. Cambian j, w3u e imp; se añaden war3mapImported\CuaBurbuja.mdx, CuaBurbujaGris.mdx (cartas cerradas) y CuaBurbujaBrillo.blp; se quitan
# CuaAroAzul.mdx y CuaAroRojo.mdx.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
G=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19p-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=texturas-v19p; mkdir -p $X
B0=TerrainDev-Titulo-v19o.w3x
echo "5091daaa6f82a862cac542bf3b809ee053e9ec2740c7d9b6dc9e18b86f386649  $B0" | sha256sum -c --quiet || exit 1
$W extract $B0 'war3mapImported\TiendaEsfera.mdx' -o $P/TiendaEsfera.mdx > /dev/null || exit 1
$W extract $G/War3x.mpq 'Textures\Blue_Glow2.blp' -o $P/Blue_Glow2.blp > /dev/null || exit 1
$PYP -I scripts/burbuja_v19p.py $P/TiendaEsfera.mdx $P/Blue_Glow2.blp $P/bb.mdx $X/CuaBurbujaBrillo.blp 2> /dev/null > /dev/null || exit 1
python3 -I scripts/mdx_sin_billboard.py $P/bb.mdx $X/CuaBurbuja.mdx > /dev/null || exit 1
python3 -I scripts/aro_v19o.py --extensiones $X/CuaBurbuja.mdx > /dev/null || exit 1
python3 -I scripts/burbuja_gris_v19p.py $X/CuaBurbuja.mdx $X/CuaBurbujaGris.mdx > /dev/null || exit 1
NUEVOS="CuaBurbuja.mdx CuaBurbujaGris.mdx CuaBurbujaBrillo.blp"
FUERA="CuaAroAzul.mdx CuaAroRojo.mdx"
for par in "v19o 5091daaa6f82a862cac542bf3b809ee053e9ec2740c7d9b6dc9e18b86f386649 v19p normal" \
           "v19o-prueba 5f9f5734cffaad8a1288641cb43cadc66ace68cae3da6b53163435e5a9500e26 v19p-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19p.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19p.py $E $N > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  rem() { k=$((k+1)); $W mpq remove $cur "$1" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for t in $FUERA; do rem "war3mapImported\\$t"; done
  for f in war3map.j war3map.w3u war3map.imp; do add $f $N/$f; done
  for t in $NUEVOS; do add "war3mapImported\\$t" $X/$t; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $NUEVOS; do
    $W extract $O "war3mapImported\\$t" -o $P/re > /dev/null && cmp -s $P/re $X/$t || { echo "$N: reextracción de $t distinta"; exit 1; }
  done
  for t in $FUERA; do
    $W extract $O "war3mapImported\\$t" -o $P/re > /dev/null 2>&1 && { echo "$N: $t sigue dentro"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3u " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: j, w3u, imp y 3 archivos nuevos reextraídos, 2 quitados; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
