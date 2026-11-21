#!/bin/bash
# v17s (14/11/2026): fase 1 del plan devmission-mejoras-darkmoon.md, marco de cuadros (scripts/v17s.py).
# Cambia el j, el w3b (iconos DC00-DC0G, objetos_v17s.py) y añade war3mapImported\CuaHitBtn.mdx (zona_clic.py).
# Salidas: TerrainDev-Titulo-v17s.w3x (normal) y TerrainDev-Titulo-v17s-prueba.w3x (registro lat\v17s-cuadros.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17s-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=v17s-recursos
mkdir -p v17s v17s-prueba $R
python3 -I scripts/zona_clic.py v14a-recursos/ShopHitBtn.mdx $R/CuaHitBtn.mdx 34.8 105.7 14 > /dev/null || exit 1
for v in v17r v17r-prueba; do
  case $v in v17r) H=62ea39750ca5e7013f3a6dae5a2213054aac46d75adb335895a67eda0d39fa49; M=;; *) H=b59ac401849919dca68b8ded7fda9f181c8cedea37e6974e55c71372fb9afd3e; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  N=${v/v17r/v17s}
  python3 -I scripts/v17s.py $v/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  $W extract $B war3map.w3b -o $P/base.w3b > /dev/null || exit 1
  python3 -I scripts/objetos_v17s.py $P/base.w3b $N/war3map.w3b > /dev/null || exit 1
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x 'war3mapImported\CuaHitBtn.mdx' --file $R/CuaHitBtn.mdx -o $P/c.w3x > /dev/null || exit 1
  O=TerrainDev-Titulo-$N.w3x
  # wc3ctl escribe su propia cabecera; se conserva la de v17r (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  rm -f $P/a.w3x $P/b.w3x $P/c.w3x
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W extract $O 'war3mapImported\CuaHitBtn.mdx' -o $P/re > /dev/null && cmp -s $P/re $R/CuaHitBtn.mdx || { echo "$N: reextracción del mdx distinta"; exit 1; }
  for f in war3map.w3i war3map.wts war3map.w3u war3map.w3a war3map.imp war3map.doo 'war3mapImported\ShopHitBtn.mdx' 'UI\HealthBarsHorizontal\HealthJefe5.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3b y CuaHitBtn.mdx reemplazados y reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
