#!/bin/bash
# Entra a Dev Mission v13m, sin registros en el mapa y sin rastreador.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
O=$M/v13m; mkdir -p $O
cp $M/TerrainDev-Titulo-v13m.w3x $WC/Maps/Test/DevMission-v13m.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v13m.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
