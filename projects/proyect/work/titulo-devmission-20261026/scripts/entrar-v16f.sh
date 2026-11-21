#!/bin/bash
# Entra a v16f (sin registros): tutorial directo y luego la partida.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v16f; mkdir -p $O
cp $M/TerrainDev-Titulo-v16f.w3x $WC/Maps/Test/DevMission-v16f.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16f.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
