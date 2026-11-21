#!/bin/bash
# v18d (15/11/2026): las mejoras de élite son para todas las élites (vivas y las que salgan), se retiran al acabar su
# tiempo y se ponen las de la tirada siguiente; pausa si no hay élites ni pueden salir. Sin cambio común→élite.
# Sobre v18c; sólo cambia war3map.j (scripts/v18d.py).
# Salidas: TerrainDev-Titulo-v18d.w3x y TerrainDev-Titulo-v18d-prueba.w3x (registros en lat\v18d-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18d-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18d v18d-prueba
for v in v18c v18c-prueba; do
  case $v in v18c) H=9ea4f2b58ee5b83823b3099bbcdc021238f6bc737057c3fdc58fc001bd156e86; M=;; *) H=7ddc42a473e8d031e5cbfc1ecc85c2ecf078ec1afab29f6a5d3eb34ab383cef8; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18c/v18d}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v18d.py $v/war3map.j $N/war3map.j $M || exit 1
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
