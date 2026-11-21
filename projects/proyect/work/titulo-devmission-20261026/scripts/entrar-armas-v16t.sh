#!/bin/bash
# Prueba de las armas de antes con reserva 512 (v16t-reserva) y rastreo de cuadros. Sólo mirar: todo va solo.
# 120, 180 y 240 enemigos que no mueren; nadie, MP5 de antes, FN SCAR de antes y MP5 todos al mismo lado.
# COMPLETE a los ~282 s de ronda (unos 5 minutos): entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = armas-v16t/<fecha>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
V=v16t-reserva-armas; A=armas
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
for k in $(seq 30); do pgrep -x wineserver > /dev/null || break; sleep 1; done
O=$M/armas-v16t/$(date +%Y%m%d-%H%M%S)-$A; mkdir -p $O
ls $WC/CustomMapData/lat/armas-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/armas-*.txt
cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/armas-*.txt $O/lat/ 2>/dev/null
echo $O
