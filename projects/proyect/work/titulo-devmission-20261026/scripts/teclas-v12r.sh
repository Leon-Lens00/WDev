#!/bin/bash
# Teclas reales E y D con cada personaje, con vídeo.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for c in 0 1; do
 t=v12r-solo/try$c; mkdir -p $M/$t
 bash $M/scripts/filmar.sh $M/$t/video ${FILMAR:-45} &
 v=$!
 TECLAS_DASH=1 bash $M/scripts/boton.sh TerrainDev-Titulo-v12r-solo$c.w3x $t > $M/v12r-solo/try$c.salida 2>&1
 wait $v
 tail -4 $M/v12r-solo/try$c.salida
 sleep 8
done
echo terminado
