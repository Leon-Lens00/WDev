#!/bin/bash
# Entra a v21n-prueba: Freezer de D.O.N 2.1a con tiers, técnicas en área y Golden Form con bono a las armas.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
ls /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v21n-*.txt > /dev/null 2>&1 && gio trash /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/WarcraftIII/CustomMapData/lat/v21n-*.txt
O=$M/v21n-prueba; mkdir -p $O
cp $M/TerrainDev-Titulo-v21n-prueba.w3x $WC/Maps/Test/DevMission-v21n-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v21n-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
