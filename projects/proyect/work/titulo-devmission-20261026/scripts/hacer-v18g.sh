#!/bin/bash
# v18g (15/11/2026), fase 3, segundo lote: "Elegir", el pie de los cuadros y el aviso de la tienda a textura
# (etiquetas_v18g.py, objetos_v18f.py con las etiquetas de v18g, v18g.py). Sobre v18f. Cambian j, w3b e imp y se
# añaden war3mapImported\TiendaEt8..11.blp.
# Salidas: TerrainDev-Titulo-v18g.w3x y TerrainDev-Titulo-v18g-prueba.w3x (registros en lat\v18g-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18g-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18g v18g-prueba
$PYP -I scripts/etiquetas_v18g.py $FUENTE etiquetas-v18f etiquetas-v18g || exit 1
for v in v18f v18f-prueba; do
  case $v in v18f) H=44d44bc282c00aa60bee2122db1dcf055e46f5d539d40a761674c2552e263230; M=;; *) H=a770d2d200f8b2eb8271b2ba1914758c05d738b740df052a9d164f9acb7737ae; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18f/v18g}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3b war3map.imp; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18f.py $P/$v-in $P/$N-obj etiquetas-v18g || exit 1
  python3 -I scripts/v18g.py $v/war3map.j $N/war3map.j etiquetas-v18g $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.imp --file $N/war3map.imp -o $P/c0.w3x > /dev/null || exit 1
  for n in 8 9 10 11; do
    $W mpq add $P/c$((n-8)).w3x "war3mapImported\\TiendaEt$n.blp" --file etiquetas-v18g/TiendaEt$n.blp -o $P/c$((n-7)).w3x > /dev/null || exit 1
  done
  { head -c 512 $B; tail -c +513 $P/c4.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for n in 8 9 10 11; do
    $W extract $O "war3mapImported\\TiendaEt$n.blp" -o $P/re > /dev/null && cmp -s $P/re etiquetas-v18g/TiendaEt$n.blp || { echo "$N: reextracción de TiendaEt$n.blp distinta"; exit 1; }
  done
  for f in war3map.w3u war3map.w3a war3map.w3i war3map.wts war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav' 'war3mapImported\SupTic.wav' 'war3mapImported\SupCaja.blp' 'war3mapImported\ShopPlano.mdx' 'war3mapImported\TiendaEt0.blp' 'war3mapImported\TiendaEt7.blp'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3b, imp y TiendaEt8..11.blp reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
