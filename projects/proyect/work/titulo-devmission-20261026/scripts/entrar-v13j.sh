#!/bin/bash
# Entra a Dev Mission v13j con el rastreador de cuadros. El mapa no escribe registros, para que no pesen en el dash.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
O=$M/v13j-usuario/$(date +%Y%m%d-%H%M%S); mkdir -p $O
cp $M/TerrainDev-Titulo-v13j.w3x $WC/Maps/Test/DevMission-v13j.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v13j.w3x\r\n' > $O/lanzar.bat
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
python3 -I $M/scripts/informe_lag.py $O | head -12
echo "Informe en $O/informe.txt"
