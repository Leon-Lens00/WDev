#!/bin/bash
# v18e (15/11/2026): multiplicador de élites barajado con suma al azar (hasta +0,60) y élites al 35 % de la vida del jefe.
# Sobre v18d; sólo cambia war3map.j (scripts/v18e.py).
# Salidas: TerrainDev-Titulo-v18e.w3x y TerrainDev-Titulo-v18e-prueba.w3x (registros en lat\v18e-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18e-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18e v18e-prueba
for v in v18d v18d-prueba; do
  case $v in v18d) H=9c35e32d293ca0850a0cdfdbab41d21a53f866372621f75f284b46b1e3aa3f03; M=;; *) H=736aa144bb5b77e34d650f2097779e83f55d3f9568892b3694f28351bcf160ae; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18d/v18e}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18e.py $v/war3map.j $N/war3map.j $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp war3map.w3a war3map.w3i war3map.wts war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav' 'war3mapImported\SupTic.wav' 'war3mapImported\SupCaja.blp'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reextraído; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
