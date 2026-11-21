#!/bin/bash
# v18h (15/11/2026), fase 4: bolsas de oro (v18h.py) y sus unidades 'nbg0'..'nbg2' (objetos_v18h.py). Sobre v18g.
# Cambian j y w3u (modelos del juego, sin imports). Salidas: TerrainDev-Titulo-v18h.w3x y -prueba (lat\v18h-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18h-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18h v18h-prueba
for v in v18g v18g-prueba; do
  case $v in v18g) H=f03376ace21e569788cfe99d7847ae9456bb7a2470efe570dfd42644d05d183f; M=;; *) H=1e7218736baa53ec8c12d1ba94a246b5d534a72a333926608c69ecfb625227d5; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18g/v18h}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3u; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18h.py $P/$v-in $P/$N-obj || exit 1
  python3 -I scripts/v18h.py $v/war3map.j $N/war3map.j $M || exit 1
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
