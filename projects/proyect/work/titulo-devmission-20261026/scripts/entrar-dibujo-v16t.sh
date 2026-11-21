#!/bin/bash
# Prueba de qué parte de la bala cuesta dibujar (armas de antes, reserva 512) con rastreo de cuadros. Sólo mirar.
# Dos partidas seguidas: dummy normal (dib) y dummy plano sin animación de hueso (dibp). En cada una: 120 enemigos que
# no mueren, cámara en el héroe, 7 modos de 10 s, 2 vueltas; COMPLETE a los ~152 s de ronda (unos 3 minutos): entonces
# cerrar y se abre la siguiente. Uso: entrar-dibujo-v16t.sh [PARTIDAS] [FECHA] (p. ej. "dibp" 20261114-… repite una).
# El juego se pausa si la ventana pierde el foco: dejarla delante.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
F=${2:-$(date +%Y%m%d-%H%M%S)}
for pre in ${1:-dib dibp}; do
  for k in $(seq 30); do pgrep -x wineserver > /dev/null || break; sleep 1; done
  V=v16t-reserva-$pre
  [ $pre = dib ] && echo "Partida 1: dummy normal" || echo "Partida 2: dummy plano"
  O=$M/dibujo-v16t/$F/$pre; [ -d $O ] && gio trash $O; mkdir -p $O
  ls $WC/CustomMapData/lat/$pre-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/$pre-*.txt
  cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
  printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
  date +%s.%N > $O/lanzado.txt
  RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
  while pgrep -x war3.exe > /dev/null; do sleep 1; done
  mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/$pre-*.txt $O/lat/ 2>/dev/null
done
echo $M/dibujo-v16t/$F
