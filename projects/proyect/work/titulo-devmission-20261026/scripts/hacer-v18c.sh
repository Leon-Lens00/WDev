#!/bin/bash
# v18c (15/11/2026): fondo propio de las tarjetas ('DSC0', tarjeta_v18c.py), súper élite sólo en élites (la común se
# cambia por la élite de su tipo), tirada igual para todos y élites/jefes más grandes (tamanos_v18c.py). Sobre v18b.
# Cambian j, w3u, w3b, imp y se añade war3mapImported\SupCaja.blp.
# Salidas: TerrainDev-Titulo-v18c.w3x y TerrainDev-Titulo-v18c-prueba.w3x (registros en lat\v18c-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18c-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18c v18c-prueba super-v18c
$PYP -I scripts/tarjeta_v18c.py super-v18c || exit 1
python3 -I scripts/tamanos_v18c.py
for v in v18b v18b-prueba; do
  case $v in v18b) H=3eaec51210c6b67c5b6fe297e76160e513bf18c1ddbbad6d1564b433296842eb; M=;; *) H=701b0a49be0d5dbc17dde4af84c560e6ec2d8c6134843722a117c0004cf011ca; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18b/v18c}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3u war3map.w3b war3map.imp; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18c.py $P/$v-in $P/$N-obj || exit 1
  python3 -I scripts/v18c.py $v/war3map.j $N/war3map.j $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3u $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3u --file $N/war3map.w3u -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.w3b --file $N/war3map.w3b -o $P/c.w3x > /dev/null || exit 1
  $W mpq add $P/c.w3x war3map.imp --file $N/war3map.imp -o $P/d.w3x > /dev/null || exit 1
  $W mpq add $P/d.w3x 'war3mapImported\SupCaja.blp' --file super-v18c/SupCaja.blp -o $P/e.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/e.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W extract $O 'war3mapImported\SupCaja.blp' -o $P/re > /dev/null && cmp -s $P/re super-v18c/SupCaja.blp || { echo "$N: reextracción del blp distinta"; exit 1; }
  for f in war3map.w3a war3map.w3i war3map.wts war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav' 'war3mapImported\SupTic.wav' 'war3mapImported\RachaCaja.blp'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3u, w3b, imp y SupCaja.blp reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
