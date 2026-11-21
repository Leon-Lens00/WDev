#!/bin/bash
# v18f (15/11/2026), fase 3: las 8 etiquetas fijas de la tienda pasan de texttag a textura (etiquetas_v18f.py,
# objetos_v18f.py, v18f.py). Sobre v18e. Cambian j, w3b e imp y se añaden war3mapImported\TiendaEt0..7.blp.
# Salidas: TerrainDev-Titulo-v18f.w3x y TerrainDev-Titulo-v18f-prueba.w3x (registros en lat\v18f-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18f-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18f v18f-prueba
$PYP -I scripts/etiquetas_v18f.py $FUENTE etiquetas-v18f || exit 1
for v in v18e v18e-prueba; do
  case $v in v18e) H=0fbc051c7b5841c27f45580f351ec69d43741a3d702b90a14d8ce7d89a49ca30; M=;; *) H=8732ddb4697d4022592ac8eca616e8391525a77a88a3f99bbb89a061b45455c8; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18e/v18f}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3b war3map.imp; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18f.py $P/$v-in $P/$N-obj etiquetas-v18f || exit 1
  python3 -I scripts/v18f.py $v/war3map.j $N/war3map.j etiquetas-v18f $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.imp --file $N/war3map.imp -o $P/c0.w3x > /dev/null || exit 1
  for n in 0 1 2 3 4 5 6 7; do
    $W mpq add $P/c$n.w3x "war3mapImported\\TiendaEt$n.blp" --file etiquetas-v18f/TiendaEt$n.blp -o $P/c$((n+1)).w3x > /dev/null || exit 1
  done
  { head -c 512 $B; tail -c +513 $P/c8.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for n in 0 1 2 3 4 5 6 7; do
    $W extract $O "war3mapImported\\TiendaEt$n.blp" -o $P/re > /dev/null && cmp -s $P/re etiquetas-v18f/TiendaEt$n.blp || { echo "$N: reextracción de TiendaEt$n.blp distinta"; exit 1; }
  done
  for f in war3map.w3u war3map.w3a war3map.w3i war3map.wts war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav' 'war3mapImported\SupTic.wav' 'war3mapImported\SupCaja.blp' 'war3mapImported\ShopPlano.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3b, imp y 8 TiendaEt*.blp reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
