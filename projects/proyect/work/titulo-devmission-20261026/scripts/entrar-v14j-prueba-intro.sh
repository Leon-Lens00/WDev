#!/bin/bash
# Entra a la prueba de v14j, con la intro y el título: partida normal, registro oculto de la cámara cada 2 s en lat\\v14j-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14j-prueba-intro; mkdir -p $O
ls $WC/CustomMapData/lat/v14j-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14j-*.txt
cp $M/TerrainDev-Titulo-v14j-prueba-intro.w3x $WC/Maps/Test/DevMission-v14j-prueba-intro.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14j-prueba-intro.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
