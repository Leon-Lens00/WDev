#!/bin/bash
# Entra a v16y-prueba: v16y con registro de habilidades de D.O.N en CustomMapData/lat/v16y-1.txt (se reescribe cada 2 s).
# En la partida: -pj N cambia el personaje (3 Freezer, 4 Trunks, 5 Naruto); -gk N el nivel.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v16y-prueba; mkdir -p $O
L=$WC/CustomMapData/lat; [ -f $L/v16y-1.txt ] && gio trash $L/v16y-1.txt
cp $M/TerrainDev-Titulo-v16y-prueba.w3x $WC/Maps/Test/DevMission-v16y-prueba.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16y-prueba.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
