#!/bin/bash
# Entra a v21x-prueba: piezas por el aire chocan con árboles y precipicios; registros lat\v21x-*.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
ls /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v21x-*.txt > /dev/null 2>&1 && gio trash /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v21x-*.txt
O=$M/v21x-prueba; mkdir -p $O
cp $M/TerrainDev-Titulo-v21x-prueba.w3x $WC/Maps/Test/DevMission-v21x-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v21x-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
