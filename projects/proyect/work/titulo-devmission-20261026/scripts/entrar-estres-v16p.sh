#!/bin/bash
# Prueba de estrés de misiles (v16p-estres) con rastreo de cuadros. Sólo mirar: los 8 tiradores disparan solos.
# Escalones de 10 s desde la ronda: 0, 1, 2 y 4 tiradores; desde los 40 s los 8; COMPLETE a los 120 s: entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = estres-v16p/<fecha>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/estres-v16p/$(date +%Y%m%d-%H%M%S); mkdir -p $O
ls $WC/CustomMapData/lat/e16-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/e16-*.txt
cp $M/TerrainDev-Titulo-v16p-estres.w3x $WC/Maps/Test/DevMission-v16p-estres.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16p-estres.w3x\r\n' > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/e16-*.txt $O/lat/ 2>/dev/null
echo $O
