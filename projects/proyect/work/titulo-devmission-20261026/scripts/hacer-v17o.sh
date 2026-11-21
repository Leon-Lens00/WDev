#!/bin/bash
# v17o (14/11/2026): v17n con la presentación y la barra del jefe en la precarga (Precarga_Todo).
# Sólo cambia el j: scripts/v17o.py sobre los dos j de v17n (normal y prueba). Resto igual que v17n.
# Salidas: TerrainDev-Titulo-v17o.w3x (normal) y TerrainDev-Titulo-v17o-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17o-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17o v17o-prueba
for v in v17n v17n-prueba; do
  case $v in v17n) H=f2ab5493a796d6ca46f653ee0ee20c714b95a18fc52ab2c2cbc73d148119bd58;; *) H=91d44115f5e515c76c6e8b35d0526fe5850cb87f023fee450b2d65fb6a3c7a97;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  N=${v/v17n/v17o}
  python3 -I scripts/v17o.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null && mv $P/a.w3x $O || exit 1
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp 'war3mapImported\PresJefe5.mdx' 'war3mapImported\JefeOscuro.blp' 'UI\HealthBarsHorizontal\HealthJefe5.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reemplazado y reextraído; resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
