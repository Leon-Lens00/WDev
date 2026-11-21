#!/bin/bash
# Entra a v16t-goku (sin registros): elegir la celda 0 del título (la del Tauren) para jugar con Goku.
# En la partida: -gk N cambia el nivel de Goku (1..100; fuerza de D.O.N 1.8c, por defecto 10).
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v16t-goku; mkdir -p $O
cp $M/TerrainDev-Titulo-v16t-goku.w3x $WC/Maps/Test/DevMission-v16t-goku.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16t-goku.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
