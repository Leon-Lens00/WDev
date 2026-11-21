#!/bin/bash
# v18j (15/11/2026), fase 5: puntuación de fin de ronda con 1-3 estrellas (puntos_v18j.py, objetos_v18f.py con las
# texturas de v18j, v18j.py). Sobre v18i. Cambian j, w3b e imp y se añaden war3mapImported\PuntPanel.blp,
# PuntEstrella.blp y PuntEstrellaVacia.blp. Salidas: TerrainDev-Titulo-v18j.w3x y -prueba (lat\v18j-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18j-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18j v18j-prueba
$PYP -I scripts/puntos_v18j.py $FUENTE puntos-v18j || exit 1
TEX="PuntPanel PuntEstrella PuntEstrellaVacia"
for v in v18i v18i-prueba; do
  case $v in v18i) H=05ddc19c01416118c037bcdd041df37417898aabe5a033e3bbc9d250ad709e74; M=;; *) H=9a677915ea9ec905c23ebe673ac01ca64bc0f5cb7e4bd5f9f3c7af506bda5ece; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18i/v18j}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3b war3map.imp; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18f.py $P/$v-in $P/$N-obj puntos-v18j || exit 1
  python3 -I scripts/v18j.py $v/war3map.j $N/war3map.j $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.imp --file $N/war3map.imp -o $P/c0.w3x > /dev/null || exit 1
  n=0
  for t in $TEX; do
    $W mpq add $P/c$n.w3x "war3mapImported\\$t.blp" --file puntos-v18j/$t.blp -o $P/c$((n+1)).w3x > /dev/null || exit 1
    n=$((n+1))
  done
  { head -c 512 $B; tail -c +513 $P/c$n.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for t in $TEX; do
    $W extract $O "war3mapImported\\$t.blp" -o $P/re > /dev/null && cmp -s $P/re puntos-v18j/$t.blp || { echo "$N: reextracción de $t.blp distinta"; exit 1; }
  done
  for f in war3map.w3u war3map.w3a war3map.w3i war3map.wts war3map.doo 'war3mapImported\TiendaEt9.blp' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SupTic.wav' 'war3mapImported\SupCaja.blp' 'war3mapImported\ShopPlano.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3b, imp y 3 blp reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
