#!/bin/bash
# Prueba de la reserva del reciclador de balas (v16t-relojes) con rastreo de cuadros. Sólo mirar: todo va solo.
# Tres partidas seguidas: sin reserva, reserva 96 y reserva 256. En cada una: 240 enemigos que no mueren y 4 modos de
# 10 s, 3 vueltas; COMPLETE a los ~132 s de ronda (unos 3 minutos): entonces cerrar y se abre la siguiente.
# Uso: entrar-reserva-v16t.sh [CUPOS] [FECHA] (p. ej. "32" 20261114-015856 repite sólo la de 256 en esa carpeta).
# El juego se pausa si la ventana pierde el foco: dejarla delante.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
F=${2:-$(date +%Y%m%d-%H%M%S)}
for c in ${1:-0 12 32}; do
  # esperar a que Wine termine de cerrar la partida anterior (si no, el .bat no arranca)
  for k in $(seq 30); do pgrep -x wineserver > /dev/null || break; sleep 1; done
  V=v16t-relojes-res$c
  echo "Partida: reserva $c por sector ($((c * 8)) unidades)"
  O=$M/reserva-v16t/$F/res$c; [ -d $O ] && gio trash $O; mkdir -p $O
  ls $WC/CustomMapData/lat/res$c-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/res$c-*.txt
  cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
  printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
  date +%s.%N > $O/lanzado.txt
  RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
  while pgrep -x war3.exe > /dev/null; do sleep 1; done
  mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/res$c-*.txt $O/lat/ 2>/dev/null
done
echo $M/reserva-v16t/$F
