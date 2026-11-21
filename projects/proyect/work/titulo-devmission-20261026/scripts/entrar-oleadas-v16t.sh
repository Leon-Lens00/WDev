#!/bin/bash
# Prueba de oleadas (v16t-shots) con rastreo de cuadros. Sólo mirar: todo va solo.
# Ronda 9 con 8 jugadores: 240 enemigos que no mueren; 30 s de llenado y 14 tramos de 15 s (sin interfaz, sin IA,
# enemigos quietos, cámara lejos, 8 tiradores con MP5). COMPLETE a los 240 s de ronda: entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = oleadas-v16t/<fecha>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
V=v16t-shots-oleadas; A=oleadas
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/oleadas-v16t/$(date +%Y%m%d-%H%M%S)-$A; mkdir -p $O
ls $WC/CustomMapData/lat/olas-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/olas-*.txt
cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/olas-*.txt $O/lat/ 2>/dev/null
echo $O
