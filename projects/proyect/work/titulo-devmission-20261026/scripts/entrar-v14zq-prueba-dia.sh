#!/bin/bash
# Entra a v14zq-prueba-dia (día), entrada directa: «-sumar N», «-matar N», «-caer», «-rachas», «-ajuste dx dy s n l», «-alto Y», «-cara 0/1/-1»; registro en lat\v14zq-N.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14zq-prueba-dia; mkdir -p $O; [ -e $O/rastreo ] && gio trash $O/rastreo; mkdir -p $O/rastreo
ls $WC/CustomMapData/lat/v14zq-[0-9]*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14zq-[0-9]*.txt
cp $M/TerrainDev-Titulo-v14zq-prueba-dia.w3x $WC/Maps/Test/DevMission-v14zq-prueba-dia.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14zq-prueba-dia.w3x\r\n' > $O/lanzar.bat
RASTREO=$O/rastreo python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
