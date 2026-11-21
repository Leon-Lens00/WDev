#!/bin/bash
# v19r (19/11/2026): textos dentro de sus cuadros, cabecera en un renglón, sin el pie de Esc, cartas más abajo y
# paneles de mejoras (jefe/élite/comunes a la izquierda, héroe a la derecha) con su cuadro de detalle en la pantalla de
# inicio de la tienda (v19r.py, objetos_v19r.py, texturas_v19r.py, hits_v19r.cjs, burbuja_v19q.py panel|detalle).
# Normal sobre v19q; prueba sobre v19q-prueba. Cambian j, w3u, w3b e imp; se añaden CuaPanel.blp, CuaDetalle.blp,
# CuaBurbujaPan.mdx, CuaBurbujaDet.mdx, CuaHitIco.mdx y CuaHitTab.mdx.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v19r-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=texturas-v19r; mkdir -p $X
B0=TerrainDev-Titulo-v19q.w3x
echo "4f183622b391ba453a056e0954b91270e013c444d24f016b2fbe17adf6411d14  $B0" | sha256sum -c --quiet || exit 1
# La esfera original de la tienda (v19q conserva TiendaEsfera.mdx sin cambios).
$W extract $B0 'war3mapImported\TiendaEsfera.mdx' -o $P/TiendaEsfera.mdx > /dev/null || exit 1
for t in panel:CuaBurbujaPan detalle:CuaBurbujaDet; do
  python3 -I scripts/burbuja_v19q.py ${t%%:*} $P/TiendaEsfera.mdx $P/bb.mdx > /dev/null || exit 1
  python3 -I scripts/mdx_sin_billboard.py $P/bb.mdx $X/${t#*:}.mdx > /dev/null || exit 1
  python3 -I scripts/aro_v19o.py --extensiones $X/${t#*:}.mdx > /dev/null || exit 1
done
$PYP -I scripts/texturas_v19r.py ../tienda-prototipo-20261101/texturas $X > /dev/null || exit 1
node scripts/hits_v19r.cjs $X > /dev/null || exit 1
NUEVOS="CuaPanel.blp CuaDetalle.blp CuaBurbujaPan.mdx CuaBurbujaDet.mdx CuaHitIco.mdx CuaHitTab.mdx"
for par in "v19q 4f183622b391ba453a056e0954b91270e013c444d24f016b2fbe17adf6411d14 v19r normal" \
           "v19q-prueba e63296a5d1dd6cc4f8b6412edd6d392804cac44c525f17273b1ebb8dab209cbc v19r-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v19r.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  python3 -I scripts/objetos_v19r.py $E $N > /dev/null || exit 1
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
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  [ "$D" = "(attributes) (listfile) war3map.imp war3map.j war3map.w3b war3map.w3u " ] || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: j, w3u, w3b e imp cambiados y 6 imports nuevos; cabecera igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
