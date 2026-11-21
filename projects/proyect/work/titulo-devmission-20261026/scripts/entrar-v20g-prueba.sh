#!/bin/bash
# Entra a v20g: modelos del MVP y de menos puntos en el cuadro de resultados, y rachas más difíciles.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
ls /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v20g-*.txt > /dev/null 2>&1 && gio trash /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v20g-*.txt
O=$M/v20g-prueba; mkdir -p $O
cp $M/TerrainDev-Titulo-v20g-prueba.w3x $WC/Maps/Test/DevMission-v20g-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v20g-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
