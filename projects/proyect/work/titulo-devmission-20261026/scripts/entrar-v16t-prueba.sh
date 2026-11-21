#!/bin/bash
# Entra a la prueba de v16t con notas del tutorial (CustomMapData/lat/v16t-1.txt).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v16t-prueba; mkdir -p $O
L=$R/pfx/drive_c/WarcraftIII/CustomMapData/lat; [ -f $L/v16t-1.txt ] && gio trash $L/v16t-1.txt
cp $M/TerrainDev-Titulo-v16t-prueba.w3x $WC/Maps/Test/DevMission-v16t-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16t-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
