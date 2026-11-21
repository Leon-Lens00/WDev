#!/bin/bash
# v17t (14/11/2026): v17s con el ancla de la ventana de cuadros fijada; diagnóstico de la escena en la de prueba (scripts/v17t.py).
# Sólo cambia el j. La de prueba anota sorteo, elecciones y diagnóstico en lat\v17t-cuadros.txt.
# Salidas: TerrainDev-Titulo-v17t.w3x (normal) y TerrainDev-Titulo-v17t-prueba.w3x.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17t-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17t v17t-prueba
for v in v17s v17s-prueba; do
  case $v in v17s) H=6dde5a59b8802eb9ee3bd8da635954a824ee7028fbeede04be0fea85d419a795; J=v17s; M=;; *) H=12445ff5218fbfa015454e509fd128f97826f3842231aaa95e25f6ca37f57ab8; J=v17s-prueba; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $J/war3map.j || { echo "la base no coincide con $J/war3map.j"; exit 1; }
  N=${v/v17s/v17t}
  python3 -I scripts/v17t.py $J/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  # wc3ctl escribe su propia cabecera; se conserva la de v17s (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/a.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for f in war3map.w3i war3map.wts war3map.w3u war3map.w3b war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reemplazado y reextraído; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
