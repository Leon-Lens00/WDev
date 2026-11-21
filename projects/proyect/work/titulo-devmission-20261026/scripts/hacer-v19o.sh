#!/bin/bash
# v19o (19/11/2026): cartas con las ventanas de la tienda y contorno azul/carmesí rehecho de las esferas de los
# indicadores (texturas_v19o.py, aro_v19o.py + mdx_sin_billboard.py, objetos_v19o.py, v19o.py). Normal sobre v19n;
# prueba sobre v19n-prueba. Cambian j, w3u, w3b e imp; se añaden war3mapImported\CuaCarta.blp, CuaAroAzul.mdx y
# CuaAroRojo.mdx.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19o-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=texturas-v19o; mkdir -p $X
$PYP -I scripts/texturas_v19o.py ../tienda-prototipo-20261101/texturas $X > /dev/null || exit 1
B0=TerrainDev-Titulo-v19n.w3x
echo "bde2052a63b5a8b26a4ac447244952eff7c870a13a7dc510e71e62d95441dc17  $B0" | sha256sum -c --quiet || exit 1
for c in Azul:TiendaEsfera Rojo:JefeEsfera; do
  n=${c%%:*}; e=${c##*:}
  $W extract $B0 "war3mapImported\\$e.mdx" -o $P/$e.mdx > /dev/null || exit 1
  python3 -I scripts/aro_v19o.py $P/$e.mdx $P/bb-$n.mdx > /dev/null || exit 1
  python3 -I scripts/mdx_sin_billboard.py $P/bb-$n.mdx $X/CuaAro$n.mdx > /dev/null || exit 1
  python3 -I scripts/aro_v19o.py --extensiones $X/CuaAro$n.mdx > /dev/null || exit 1
done
NUEVOS="CuaCarta.blp CuaAroAzul.mdx CuaAroRojo.mdx"
for par in "v19n bde2052a63b5a8b26a4ac447244952eff7c870a13a7dc510e71e62d95441dc17 v19o normal" \
           "v19n-prueba cbb2b01d4f6527a2d48a727a748fbeda5bdaf17e2858c3fcb696296e5ddc4fe8 v19o-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19o.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19o.py $E $N > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3u war3map.w3b war3map.imp; do add $f $N/$f; done
  for t in $NUEVOS; do add "war3mapImported\\$t" $X/$t; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $NUEVOS; do
    $W extract $O "war3mapImported\\$t" -o $P/re > /dev/null && cmp -s $P/re $X/$t || { echo "$N: reextracción de $t distinta"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3b war3map.w3u " ] || { echo "$N: cambió algo más: $D"; exit 1; }
  echo "$N: j, w3u, w3b, imp y 3 archivos nuevos reextraídos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
