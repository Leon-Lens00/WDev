#!/bin/bash
# Entra a v14zp-prueba-dia (día), entrada directa: las de v14zn más «-sumar N», «-matar N», «-caer», «-rachas»; registro en lat\v14zp-N.txt. Tiempo de cada cuadro en rastreo/cuadros.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zp-prueba-dia; mkdir -p $O; [ -e $O/rastreo ] && gio trash $O/rastreo; mkdir -p $O/rastreo
ls $WC/CustomMapData/lat/v14zp-[0-9]*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zp-[0-9]*.txt
cp $M/TerrainDev-Titulo-v14zp-prueba-dia.w3x $WC/Maps/Test/DevMission-v14zp-prueba-dia.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zp-prueba-dia.w3x\r\n' > $O/lanzar.bat
RASTREO=$O/rastreo python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
