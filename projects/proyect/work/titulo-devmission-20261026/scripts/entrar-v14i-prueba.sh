#!/bin/bash
# Entra a la prueba de v14i: rondas 5 (jugadores reales) y 6 (como 8 jugadores), descanso de 6 s, héroe que se cura, registro oculto en lat\\v14i-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14i-prueba; mkdir -p $O
ls $WC/CustomMapData/lat/v14i-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14i-*.txt
cp $M/TerrainDev-Titulo-v14i-prueba.w3x $WC/Maps/Test/DevMission-v14i-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14i-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
