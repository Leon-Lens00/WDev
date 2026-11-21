#!/bin/bash
# Prueba de bala Toy y versiones ligeras (armas de antes, reserva 512) con rastreo de cuadros. Sólo mirar.
# Una partida: 120 enemigos que no mueren, cámara en el héroe, 6 modos de 10 s (nadie, Shot, Toy, ligera1, ligera2, sin modelo),
# 2 vueltas; COMPLETE a los ~132 s de ronda (unos 3 minutos): entonces cerrar.
# Uso: entrar-ligera-v16t.sh [FECHA]
# El juego se pausa si la ventana pierde el foco: dejarla delante.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
F=${1:-$(date +%Y%m%d-%H%M%S)}
for pre in lig; do
  for k in $(seq 30); do pgrep -x wineserver > /dev/null || break; sleep 1; done
  V=v16t-reserva-$pre
  O=$M/ligera-v16t/$F/$pre; [ -d $O ] && gio trash $O; mkdir -p $O
  ls $WC/CustomMapData/lat/$pre-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/$pre-*.txt
  cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
  printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
  date +%s.%N > $O/lanzado.txt
  RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
  while pgrep -x war3.exe > /dev/null; do sleep 1; done
  mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/$pre-*.txt $O/lat/ 2>/dev/null
done
echo $M/ligera-v16t/$F
