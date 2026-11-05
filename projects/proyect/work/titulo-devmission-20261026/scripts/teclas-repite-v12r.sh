#!/bin/bash
# Repite las teclas con un personaje y varias tandas. Uso: teclas-repite-v12r.sh CELDA INTENTOS TANDAS
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; c=$1
for n in $(seq ${4:-1} $2); do
 t=v12r-solo/rep$c-$n; mkdir -p $M/$t
 TECLAS_DASH=1 TANDAS=$3 ESPERA=1 bash $M/scripts/boton.sh TerrainDev-Titulo-v12r-solo$c.w3x $t > $M/v12r-solo/rep$c-$n.salida 2>&1
 tail -2 $M/v12r-solo/rep$c-$n.salida; sleep 8
done
echo terminado
