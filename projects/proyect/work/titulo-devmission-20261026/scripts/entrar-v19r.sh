#!/bin/bash
# Entra a v19r: textos dentro de sus cuadros, sin el pie de Esc, cartas más abajo y paneles de mejoras (jefe/élite/comunes y héroe) en el inicio de la tienda.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v19r; mkdir -p $O
cp $M/TerrainDev-Titulo-v19r.w3x $WC/Maps/Test/DevMission-v19r.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v19r.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
