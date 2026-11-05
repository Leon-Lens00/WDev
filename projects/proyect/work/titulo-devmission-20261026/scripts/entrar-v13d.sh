#!/bin/bash
# Entra a Dev Mission v13d en el terreno de Swamped Temple. Los registros ocultos quedan en v13d-usuario/AAAAMMDD-HHMMSS/lat al cerrar el juego.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
O=$M/v13d-usuario/$(date +%Y%m%d-%H%M%S); mkdir -p $O
cp $M/TerrainDev-Titulo-v13d-registro.w3x $WC/Maps/Test/DevMission-v13d.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v13d.w3x\r\n' > $O/lanzar.bat
mkdir -p $WC/CustomMapData/lat; find $WC/CustomMapData/lat -type f -delete
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
cp -r $WC/CustomMapData/lat $O/lat
echo "Registros en $O/lat"
