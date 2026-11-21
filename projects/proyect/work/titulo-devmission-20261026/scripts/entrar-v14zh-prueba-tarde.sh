#!/bin/bash
# Entra a la prueba de v14zh (tarde), entrada directa: vida ilimitada, «-bateria N» (0..100), «-cargas N», «-fin» y «-tarde N» (1..4); registro en lat\v14zh-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zh-prueba-tarde; mkdir -p $O
ls $WC/CustomMapData/lat/v14zh-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zh-*.txt
cp $M/TerrainDev-Titulo-v14zh-prueba-tarde.w3x $WC/Maps/Test/DevMission-v14zh-prueba-tarde.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zh-prueba-tarde.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
