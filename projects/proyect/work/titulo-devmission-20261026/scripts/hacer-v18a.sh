#!/bin/bash
# v18a (15/11/2026): tarjetas de la súper élite como "Super Creep Random Boost" de Dark Moon: entrada en bloque, tirada de
# 2,4 s con un tic por cambio (scripts/v18a.py) y war3mapImported\SupTic.wav, sacado del vídeo de Leon
# (scripts/sonido_v18a.py, dos veces: debe salir igual). Cambian el j y se añade el wav.
# La de prueba anota entrada, cambios, salida y fuera en lat\v18a-super.txt; precarga y cuadros en lat\v18a-*.txt.
# Salidas: TerrainDev-Titulo-v18a.w3x (normal) y TerrainDev-Titulo-v18a-prueba.w3x.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/runtime-linux/python-3.12/bin/python3
VID="/home/snz/Vídeos/Videocapturas de pantalla/Videocaptura de pantalla_20261115_002900.mp4"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18a-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18a v18a-prueba sonidos-darkmoon
# Sonido: tramo 22,85-24,60 s del vídeo (48 kHz) y promedio de los tics.
for n in 1 2; do
  ffmpeg -v error -y -ss 22.85 -t 1.75 -i "$VID" -vn -ar 48000 -map_metadata -1 -fflags +bitexact -flags:a +bitexact -c:a pcm_s16le $P/tramo$n.wav || exit 1
  $PY -I scripts/sonido_v18a.py $P/tramo$n.wav $P/tic$n.wav > $P/tic$n.json || exit 1
done
cmp -s $P/tic1.wav $P/tic2.wav || { echo "el tic no sale igual dos veces"; exit 1; }
cp $P/tic1.wav sonidos-darkmoon/SupTic.wav; cat $P/tic1.json
for v in v17z v17z-prueba; do
  case $v in v17z) H=2baa6f073c0add8e46b85cf753bfb75aae53821527099c642706b982dfd8dba6; J=v17z; M=;; *) H=d912877a6969a610d556f16ad7a83339a89136c7b0aae16d547c825b4f9648a9; J=v17z-prueba; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $J/war3map.j || { echo "la base no coincide con $J/war3map.j"; exit 1; }
  N=${v/v17z/v18a}
  python3 -I scripts/v18a.py $J/war3map.j $N/war3map.j $M > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  O=TerrainDev-Titulo-$N.w3x
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x 'war3mapImported\SupTic.wav' --file sonidos-darkmoon/SupTic.wav -o $P/c.w3x > /dev/null || exit 1
  # wc3ctl escribe su propia cabecera; se conserva la de v17z (nombre "Proyect Dev Us").
  { head -c 512 $B; tail -c +513 $P/c.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  $W extract $O 'war3mapImported\SupTic.wav' -o $P/re > /dev/null && cmp -s $P/re sonidos-darkmoon/SupTic.wav || { echo "$N: reextracción del wav distinta"; exit 1; }
  for f in war3map.w3a war3map.w3b war3map.w3i war3map.wts war3map.w3u war3map.imp war3map.doo 'UI\HealthBarsHorizontal\HealthJefe5.mdx' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SonCaja.wav'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j y SupTic.wav añadidos y reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
