#!/bin/bash
# Prueba de estrés de v16s con rastreo de cuadros. Sólo mirar: los 8 tiradores disparan solos.
# Uso: entrar-estres-v16s.sh [spas]   (sin argumento: MP5; spas: escopeta SPAS-12)
# Escalones de 10 s desde la ronda: 0, 1, 2 y 4 tiradores; desde los 40 s los 8; COMPLETE a los 120 s: entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar (CARPETA = estres-v16s/<fecha>-<arma>).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
V=v16s-estres; A=mp5
[ "$1" = spas ] && { V=v16s-estres-spas; A=spas; }
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/estres-v16s/$(date +%Y%m%d-%H%M%S)-$A; mkdir -p $O
ls $WC/CustomMapData/lat/e16s-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/e16s-*.txt
cp $M/TerrainDev-Titulo-$V.w3x $WC/Maps/Test/DevMission-$V.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $V > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/e16s-*.txt $O/lat/ 2>/dev/null
echo $O
