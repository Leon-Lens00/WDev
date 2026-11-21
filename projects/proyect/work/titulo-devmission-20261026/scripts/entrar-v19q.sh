#!/bin/bash
# Entra a v19q: cartas de 330 × 540, cabecera en cuadro con burbuja, fondo de rayos en tienda y cartas, cerradas oscuras, descanso de 60 s.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v19q; mkdir -p $O
cp $M/TerrainDev-Titulo-v19q.w3x $WC/Maps/Test/DevMission-v19q.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v19q.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
