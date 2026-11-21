#!/bin/bash
# Entra a v16u (sin registros). Título: celda 2 Goku, 3 Freezer, 4 Future Trunks, 5 Naruto (uno de cada por partida); 0 Tauren, 1 Cairne.
# En la partida: -gk N cambia el nivel (1..100, por defecto 10) de los cuatro héroes de D.O.N 1.8c.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/v16u; mkdir -p $O
cp $M/TerrainDev-Titulo-v16u.w3x $WC/Maps/Test/DevMission-v16u.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16u.w3x\r\n' > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1
