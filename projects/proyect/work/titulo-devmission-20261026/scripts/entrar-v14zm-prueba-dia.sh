#!/bin/bash
# Entra a v14zm-prueba-dia (día), entrada directa: vida ilimitada, «-oro N», «-compra C T», «-fin», «-llamar», «-cuchillo T», «-ataque»; registro en lat\v14zm-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zm-prueba-dia; mkdir -p $O
ls $WC/CustomMapData/lat/v14zm-[0-9]*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zm-[0-9]*.txt
cp $M/TerrainDev-Titulo-v14zm-prueba-dia.w3x $WC/Maps/Test/DevMission-v14zm-prueba-dia.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zm-prueba-dia.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
