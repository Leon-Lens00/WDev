#!/bin/bash
# v18b (15/11/2026): v18a con el sonido original de la tirada de Dark Moon (BoostCreeps.Random =
# panorama_custom_lobby_drawer_slide_in_01 de Dota 2, sacado sin tocar las muestras con scripts/sonido_v18b.py) y un
# sonido nuevo en cada cambio (scripts/v18b.py). Cambian el j y war3mapImported\SupTic.wav.
# Salidas: TerrainDev-Titulo-v18b.w3x (normal) y TerrainDev-Titulo-v18b-prueba.w3x (registros en lat\v18b-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
DOTA="/home/snz/.local/share/Steam/steamapps/common/dota 2 beta/game/dota/pak01_dir.vpk"
SND=sounds/ui/panorama/panorama_custom_lobby_drawer_slide_in_01.vsnd_c
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18b-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18b v18b-prueba sonidos-darkmoon
python3 -I scripts/vpkmulti.py "$DOTA" $P $SND > /dev/null || exit 1
python3 -I scripts/sonido_v18b.py $P/$(basename $SND) $P/tic.wav || exit 1
cp $P/tic.wav sonidos-darkmoon/BoostCreeps-Random.wav
for v in v18a v18a-prueba; do
  case $v in v18a) H=7895b03e23f43ac69726a725e3ba2a4273647b97816c2546ba0c3a63f79e4b89; M=;; *) H=aaf8d6071a357bcf5d111ad4e0f18ae7ed9cdf2de10522a7f939cf934d788151; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  N=${v/v18a/v18b}
  python3 -I scripts/v18b.py $v/war3map.j $N/war3map.j $M || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x 'war3mapImported\SupTic.wav' --file sonidos-darkmoon/BoostCreeps-Random.wav -o $P/c.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  $W extract $O 'war3mapImported\SupTic.wav' -o $P/re > /dev/null && cmp -s $P/re sonidos-darkmoon/BoostCreeps-Random.wav || { echo "$N: reextracción del wav distinta"; exit 1; }
  for f in war3map.w3a war3map.w3b war3map.w3i war3map.wts war3map.w3u war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j y SupTic.wav cambiados y reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
