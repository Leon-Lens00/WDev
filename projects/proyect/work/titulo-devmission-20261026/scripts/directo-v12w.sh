#!/bin/bash
# Prueba del mapa directo con entradas reales. Uso: directo-v12w.sh INTENTO LIMITE
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; cd $M; t=v12w-solo/directo-${1:-1}; mkdir -p $t
bash scripts/filmar.sh $M/$t/video ${FILMA:-40} &
f=$!
TECLAS_DASH=1 JUGAR=1 LIMITE=${2:-100} bash scripts/boton.sh TerrainDev-Titulo-v12w-directo.w3x $t > $t.salida 2>&1
wait $f; tail -6 $t.salida
