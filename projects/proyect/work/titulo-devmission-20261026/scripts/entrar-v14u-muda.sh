#!/bin/bash
# Prueba propia de v14u: tormenta cada 4 s, registro en lat\v14u-N.txt, rastreo de cuadros en v14u-muda/cuadros.txt.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14u-muda-prueba; mkdir -p $O
ls $WC/CustomMapData/lat/v14u-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/v14u-*.txt
cp $M/TerrainDev-Titulo-v14u-muda.w3x $WC/Maps/Test/DevMission-v14u-muda.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14u-muda.w3x\r\n' > $O/lanzar.bat
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
