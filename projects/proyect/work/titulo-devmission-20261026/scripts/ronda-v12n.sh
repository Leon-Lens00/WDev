#!/bin/bash
# Prueba completa de un personaje con video. Uso: ronda-v12n.sh CELDA
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; c=${1:-0}
for n in 2 3 4 5 6 7; do
 t=v12n-solo/try$c-$n
 mkdir -p $M/$t
 bash $M/scripts/filmar.sh $M/$t/video 55 &
 v=$!
 bash $M/scripts/boton.sh TerrainDev-Titulo-v12n-solo$c.w3x $t 1 > $M/v12n-solo/try$c-$n.salida 2>&1
 wait $v
 tail -3 $M/v12n-solo/try$c-$n.salida
 [ -f $M/$t/f/07-final.png ] && { echo "[ok] $t"; exit 0; }
 sleep 20
done
echo "[fallo] sin ronda completa"
