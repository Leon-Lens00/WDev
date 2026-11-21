#!/bin/bash
# v17p (14/11/2026): v17o con la sala configurada: nombre "Proyect Dev Us", dos fuerzas fijas (Dev Us 1-4, Dev Mission
# 5-8, aliadas en el juego) y raza Humano fija. w3i y wts: scripts/w3i_v17p.py; j: scripts/v17p.py (normal y prueba).
# Salidas: TerrainDev-Titulo-v17p.w3x (normal) y TerrainDev-Titulo-v17p-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17p-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17p v17p-prueba
for v in v17o v17o-prueba; do
  case $v in v17o) H=bdc73708acbde5791626f13304fcb59ce31ccfccbd03573b867296d8aff24eaf;; *) H=5f37057a686a5a2858276d5743c62288e9d80b2c54545ece06018dbc901b8fd3;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  N=${v/v17o/v17p}
  for f in war3map.w3i war3map.wts; do $W extract $B $f -o $P/$v.$f > /dev/null || exit 1; done
  ID=$(python3 -I scripts/w3i_v17p.py $P/$v.war3map.w3i $P/$v.war3map.wts $N/war3map.w3i $N/war3map.wts) || exit 1
  python3 -I scripts/v17p.py $v/war3map.j $N/war3map.j "$ID" > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  cp $B $P/a.w3x
  for f in war3map.j war3map.w3i war3map.wts; do
    $W mpq add $P/a.w3x $f --file $N/$f -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $f"; exit 1; }
  done
  mv $P/a.w3x $O
  for f in war3map.j war3map.w3i war3map.wts; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción distinta de $f"; exit 1; }
  done
  for f in war3map.w3u war3map.w3b war3map.imp war3map.doo war3map.w3e 'war3mapImported\PresJefe5.mdx' 'UI\HealthBarsHorizontal\HealthJefe5.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3i y wts reemplazados y reextraídos (cadena de la 2.ª fuerza: $ID); resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
