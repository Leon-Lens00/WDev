#!/bin/bash
# Entra a un mapa de diagnóstico del cierre de v16k/v16l: d0, d1, d2 o d3 (ver diag_v16l.py y el informe de errores).
D=$1; case "$D" in d0|d1|d2|d3) ;; *) echo "uso: entrar-diag-v16l.sh d0|d1|d2|d3"; exit 1;; esac
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
O=$M/diag-v16l/$D; mkdir -p $O
cp $M/diag-v16l/DevMission-v16l-$D.w3x $WC/Maps/Test/DevMission-v16l-$D.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-v16l-%s.w3x\r\n' $D > $O/lanzar.bat
date '+inicio %T' > $O/runtime.log
python3 -I $M/scripts/lan-run.py $O/lanzar.bat >> $O/runtime.log 2>&1
date '+fin %T' >> $O/runtime.log
