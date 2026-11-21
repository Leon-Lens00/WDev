#!/bin/bash
# Entra a la medición de la tabla de daño de v14l (unos 5 s; luego cerrar el juego). Al cerrar copia el registro
# (lat\dano-N.txt) a v14l-dano/lat y lo evalúa con leer-dano-v14l.py.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v14l-dano; mkdir -p $O; [ -d $O/lat ] && gio trash $O/lat
ls $WC/CustomMapData/lat/dano-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/dano-*.txt
cp $M/TerrainDev-Titulo-v14l-dano.w3x $WC/Maps/Test/DevMission-v14l-dano.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v14l-dano.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
# El bat usa start: esperar a que el juego abra (hasta 60 s) y luego a que se cierre.
for i in $(seq 60); do pgrep -x war3.exe > /dev/null && break; sleep 1; done
echo 'Juego abierto: espera unos 5 s dentro de la partida y ciérralo.'
while pgrep -x war3.exe > /dev/null; do sleep 1; done
mkdir -p $O/lat; cp $WC/CustomMapData/lat/dano-*.txt $O/lat/ 2>/dev/null || { echo "No hay registro dano-*.txt"; exit 1; }
python3 -I $M/scripts/leer-dano-v14l.py $O/lat | tee $O/resultado.txt
