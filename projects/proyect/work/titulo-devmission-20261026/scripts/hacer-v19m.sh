#!/bin/bash
# v19m (19/11/2026): acabado de los cuadros: marco por pantalla, banda de tipo, cabecera, destello al elegir, panel de
# mutaciones activas y carta Purga (texturas_v19m.py, objetos_v19m.py, v19m.py). Normal sobre v19l; prueba sobre
# v19l-prueba. Cambian j, w3b e imp y se añaden war3mapImported\CuaBanda|CuaMarco|CuaCabecera.blp.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19m-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
$PYP -I scripts/texturas_v19m.py texturas-v19m > /dev/null || exit 1
TEX="CuaBanda CuaMarco CuaCabecera"
for par in "v19l ac3bfba19adcc7fa029fb2503ac72cc68c02a16af0d34ed1759364e92d9ee1c5 v19m normal" \
           "v19l-prueba 83e9db2e07617c942ffc37476ea14b42c2cbbefa7a52fea9bd71e0c78a284fee v19m-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3b war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19m.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19m.py $E $N > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.imp --file $N/war3map.imp -o $P/c0.w3x > /dev/null || exit 1
  k=0
  for t in $TEX; do
    $W mpq add $P/c$k.w3x "war3mapImported\\$t.blp" --file texturas-v19m/$t.blp -o $P/c$((k+1)).w3x > /dev/null || exit 1
    k=$((k+1))
  done
  { head -c 512 $B; tail -c +513 $P/c$k.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $TEX; do
    $W extract $O "war3mapImported\\$t.blp" -o $P/re > /dev/null && cmp -s $P/re texturas-v19m/$t.blp || { echo "$N: reextracción de $t.blp distinta"; exit 1; }
  done
  D=$($W mpq bytes-diff $B $O | sed -n '/^payloads that differ/,/^$/p' | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3b " ] || { echo "$N: cambió algo más: $D"; exit 1; }
  echo "$N: j, w3b, imp y 3 texturas reextraídos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
