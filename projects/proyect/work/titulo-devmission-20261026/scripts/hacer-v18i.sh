#!/bin/bash
# v18i (15/11/2026): aviso de ESC 10,5 px más arriba (v18i.py) y bolsas más grandes (objetos_v18i.py). Sobre v18h.
# Cambian j y w3u. Salidas: TerrainDev-Titulo-v18i.w3x y -prueba (lat\v18i-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18i-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18i v18i-prueba
for v in v18h v18h-prueba; do
  case $v in v18h) H=b46ca67dc05551b47a1670696573c0abc6c9dc20d460d1c8945495ed0f87d2db; M=;; *) H=aaf6c9c4993582a4e66f353b7413f702d7abdaf90fa2f665492ba36658f435c6; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18h/v18i}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3u; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18i.py $P/$v-in $P/$N-obj || exit 1
  python3 -I scripts/v18i.py $v/war3map.j $N/war3map.j $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3u $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3u --file $N/war3map.w3u -o $P/b.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/b.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for f in war3map.w3b war3map.imp war3map.w3a war3map.w3i war3map.wts war3map.doo 'war3mapImported\TiendaEt9.blp' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SupTic.wav' 'war3mapImported\ShopPlano.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j y w3u reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
