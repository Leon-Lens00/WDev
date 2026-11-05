#!/bin/bash
# Entra a Dev Mission v12w sin intro ni menús; con `intro` como argumento entra con todo. Los registros ocultos quedan en v12w-usuario/AAAAMMDD-HHMMSS/lat al cerrar el juego.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
O=$M/v12w-usuario/$(date +%Y%m%d-%H%M%S); mkdir -p $O
MAPA=directo; [ "$1" = intro ] && MAPA=registro
cp $M/TerrainDev-Titulo-v12w-$MAPA.w3x $WC/Maps/Test/DevMission-v12w.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v12w.w3x\r\n' > $O/lanzar.bat
mkdir -p $WC/CustomMapData/lat; find $WC/CustomMapData/lat -type f -delete
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
cp -r $WC/CustomMapData/lat $O/lat
echo "Registros en $O/lat"
