#!/bin/bash
# v17v (14/11/2026): súper élite con habilidades de un nivel por bit y precargadas (scripts/v17v.py, objetos_v17v.py).
# Cambian el j y el w3a (sin las 'Sp0*' de 100 niveles; 'SpM0', 'SpD*', 'SpA*', 'SpS*', 'SpR*', 'SpE*', 'SpV*').
# La de prueba anota cada súper élite en lat\v17v-super.txt y los cuadros en lat\v17v-cuadros.txt.
# Salidas: TerrainDev-Titulo-v17v.w3x (normal) y TerrainDev-Titulo-v17v-prueba.w3x.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17v-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17v v17v-prueba
for v in v17u v17u-prueba; do
  case $v in v17u) H=3c91ff39e0257fc5725dc1420b51c5fe4ccf4d03d072f1b6cd11b02ccbf57c49; J=v17u; M=;; *) H=d655260acc83ad10b576ee56b12742a7e1abc3c4f1ad85c5a3ef2956d7ec0a7d; J=v17u-prueba; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $J/war3map.j || { echo "la base no coincide con $J/war3map.j"; exit 1; }
  N=${v/v17u/v17v}
  python3 -I scripts/v17v.py $J/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  $W extract $B war3map.w3a -o $P/in.w3a > /dev/null || exit 1
  python3 -I scripts/objetos_v17v.py $P/in.w3a $N/war3map.w3a > /dev/null || exit 1
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3a --file $N/war3map.w3a -o $P/c.w3x > /dev/null || exit 1
  # wc3ctl escribe su propia cabecera; se conserva la de v17u (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for f in war3map.w3b war3map.w3i war3map.wts war3map.w3u war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j y w3a reemplazados y reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
