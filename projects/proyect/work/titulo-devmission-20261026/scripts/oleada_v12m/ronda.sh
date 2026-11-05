#!/bin/bash
# Reintenta la prueba de un personaje hasta que termine completa. Uso: ronda.sh CELDA
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; c=${1:-0}
for n in 3 4 5 6 7 8; do
 t=v12m-solo/try$c-$n
 bash $M/scripts/boton.sh TerrainDev-Titulo-v12m-solo$c.w3x $t 1 > $M/v12m-solo/try$c-$n.salida 2>&1
 tail -4 $M/v12m-solo/try$c-$n.salida
 [ -f $M/$t/f/07-final.png ] && { echo "[ok] $t"; exit 0; }
 sleep 20
done
echo "[fallo] sin ronda completa"
