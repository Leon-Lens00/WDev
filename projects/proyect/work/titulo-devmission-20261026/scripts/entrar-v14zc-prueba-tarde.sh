#!/bin/bash
# Entra a la prueba de v14zc (tarde), entrada directa: «-luz N» (0..10) cambia la luz del héroe; registro en lat\v14zc-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zc-prueba-tarde; mkdir -p $O
ls $WC/CustomMapData/lat/v14zc-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zc-*.txt
cp $M/TerrainDev-Titulo-v14zc-prueba-tarde.w3x $WC/Maps/Test/DevMission-v14zc-prueba-tarde.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zc-prueba-tarde.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
