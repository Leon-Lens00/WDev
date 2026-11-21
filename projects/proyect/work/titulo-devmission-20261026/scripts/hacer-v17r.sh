#!/bin/bash
# v17r (14/11/2026): v17q con las piezas de interfaz con Langosta que no se quedan seleccionadas (scripts/v17r.py).
# Sólo cambia el j (el de v17q es el de v17p). La de prueba anota cada pieza seleccionada en lat\v17r-seleccion.txt.
# Salidas: TerrainDev-Titulo-v17r.w3x (normal) y TerrainDev-Titulo-v17r-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17r-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17r v17r-prueba
for v in v17q v17q-prueba; do
  case $v in v17q) H=8bd0aa485560821e57266db12241cb489988aa642d01c549b00fe526477967ee; J=v17p; M=;; *) H=ffe9c95d0ef6fe60e73449fe306faaabf3803315cbad7ba773611a330395354c; J=v17p-prueba; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $J/war3map.j || { echo "la base no coincide con $J/war3map.j"; exit 1; }
  N=${v/v17q/v17r}
  python3 -I scripts/v17r.py $J/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  # wc3ctl escribe su propia cabecera; se conserva la de v17q (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for f in war3map.w3i war3map.wts war3map.w3u war3map.w3b war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reemplazado y reextraído; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
