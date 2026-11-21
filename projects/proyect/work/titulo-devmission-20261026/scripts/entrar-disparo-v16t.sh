#!/bin/bash
# Prueba del disparo por partes (v16t-relojes) con rastreo de cuadros. Sólo mirar: todo va solo.
# 240 enemigos que no mueren; 7 modos de 10 s, 3 vueltas.
# COMPLETE a los ~222 s de ronda (unos 4 minutos): entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = disparo-v16t/<fecha>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
V=v16t-relojes-disparo; A=disparo
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/disparo-v16t/$(date +%Y%m%d-%H%M%S)-$A; mkdir -p $O
ls $WC/CustomMapData/lat/disp-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/disp-*.txt
cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/disp-*.txt $O/lat/ 2>/dev/null
echo $O
