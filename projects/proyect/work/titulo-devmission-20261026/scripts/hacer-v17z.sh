#!/bin/bash
# v17z (15/11/2026): iconos de las tarjetas de la súper élite delante del fondo (scripts/v17z.py). Sólo cambia el j.
# La de prueba anota las tarjetas en lat\v17z-super.txt; precarga y cuadros en lat\v17z-*.txt.
# Salidas: TerrainDev-Titulo-v17z.w3x (normal) y TerrainDev-Titulo-v17z-prueba.w3x.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17z-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17z v17z-prueba
for v in v17y v17y-prueba; do
  case $v in v17y) H=3ffc8e348d3db1358d6a174c019d97c843e8c4b709ce47abffafcb3b135d58db; J=v17y; M=;; *) H=95c4b0fbce7e1e73c87fa877f9eb1009ad68384d20958074acd87ebc16ca0d95; J=v17y-prueba; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $J/war3map.j || { echo "la base no coincide con $J/war3map.j"; exit 1; }
  N=${v/v17y/v17z}
  python3 -I scripts/v17z.py $J/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c.w3x > /dev/null || exit 1
  # wc3ctl escribe su propia cabecera; se conserva la de v17y (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for f in war3map.w3a war3map.w3b war3map.w3i war3map.wts war3map.w3u war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reemplazado y reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
