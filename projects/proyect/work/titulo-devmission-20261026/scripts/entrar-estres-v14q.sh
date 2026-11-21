#!/bin/bash
# Prueba de estrés con rastreo de cuadros: v14p-estres (pe) o v14q-estres (qe). Uso: entrar-estres-v14q.sh pe|qe
# Cuadros en CARPETA/cuadros.txt y registros en CARPETA/lat al cerrar el juego (CARPETA = estres-v14q/<pe|qe>-fecha).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
case $1 in pe) MAPA=v14p-estres ;; qe) MAPA=v14q-estres ;; *) echo 'uso: pe|qe'; exit 1 ;; esac
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/estres-v14q/$1-$(date +%Y%m%d-%H%M%S); mkdir -p $O
ls $WC/CustomMapData/lat/$1-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/$1-*.txt
cp $M/TerrainDev-Titulo-$MAPA.w3x $WC/Maps/Test/DevMission-$MAPA.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $MAPA > $O/lanzar.bat
date +%s.%N > $O/lanzado.txt
RASTREO=$O python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp -p $WC/CustomMapData/lat/$1-*.txt $O/lat/ 2>/dev/null
echo $O
