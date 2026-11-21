#!/bin/bash
# Entra a la prueba de v14zf (noche), entrada directa: vida ilimitada, «-bateria N» (0..100) y «-cargas N»; registro en lat\v14zf-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zf-prueba-noche; mkdir -p $O
ls $WC/CustomMapData/lat/v14zf-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zf-*.txt
cp $M/TerrainDev-Titulo-v14zf-prueba-noche.w3x $WC/Maps/Test/DevMission-v14zf-prueba-noche.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zf-prueba-noche.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
