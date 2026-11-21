#!/bin/bash
# Prueba de cámara lejos y armas solas sin oleadas (armas de antes, reserva 512) con rastreo de cuadros. Sólo mirar.
# 120 enemigos con cámara en el héroe y lejos; luego sin enemigos de 1 a 8 tiradores MP5 y de 1 a 8 FN SCAR.
# COMPLETE a los ~262 s de ronda (unos 5 minutos): entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = camara-v16t/<fecha>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
V=v16t-reserva-camara; A=camara
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
for k in $(seq 30); do pgrep -x wineserver > /dev/null || break; sleep 1; done
O=$M/camara-v16t/$(date +%Y%m%d-%H%M%S)-$A; mkdir -p $O
ls $WC/CustomMapData/lat/cam-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/cam-*.txt
cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/cam-*.txt $O/lat/ 2>/dev/null
echo $O
