#!/bin/bash
# Medición por modos de v16r (v16r-perfil) con rastreo de cuadros. Sólo mirar: todo va solo.
# Desde que empieza la ronda: 25 s de llenado y 16 tramos de 15 s; COMPLETE a los 265 s (unos 4 min 25 s): entonces cerrar.
# El juego se pausa si la ventana pierde el foco: dejarla delante.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/perfil-v16r/$(date +%Y%m%d-%H%M%S); mkdir -p $O
ls $WC/CustomMapData/lat/perfil-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/perfil-*.txt
cp $M/TerrainDev-Titulo-v16r-perfil.w3x $WC/Maps/Test/DevMission-v16r-perfil.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16r-perfil.w3x\r\n' > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/perfil-*.txt $O/lat/ 2>/dev/null
echo $O
