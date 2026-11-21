#!/bin/bash
# v17l (14/11/2026): v17k con el Mur'gul Snarecaster otra vez a su tamaño de v17j (al 75 % quedaba pequeño en reposo).
# Sólo cambia el j: scripts/v17l.py sobre los dos j de v17k (normal y prueba). Texturas, objetos y modelos los de v17k.
# Salidas: TerrainDev-Titulo-v17l.w3x (normal) y TerrainDev-Titulo-v17l-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17l-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v17l v17l-prueba
for v in v17k v17k-prueba; do
  case $v in v17k) H=5d9a1ab449e5ce58fc1317268c711a205264528388cc7253c7af067a824a3f7c;; *) H=a6870481925cf3825dacc0263dc25ea5f3badfef6366139cc72af31f6f0a5d80;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  N=${v/v17k/v17l}
  python3 -I scripts/v17l.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null && mv $P/a.w3x $O || exit 1
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for f in war3map.w3u war3map.w3b war3map.imp 'war3mapImported\PresJefe5.mdx' 'war3mapImported\JefeOscuro.blp' 'war3mapImported\JefeNombre5.blp'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j reemplazado y reextraído; resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
