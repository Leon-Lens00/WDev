#!/bin/bash
# Prueba del bot con registro: D y S reales, luego combate. Uso: bot-v12s.sh CELDA INTENTO SEGUNDOS
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; c=${1:-0}; t=v12s-solo/try$c-${2:-1}; mkdir -p $M/$t
bash $M/scripts/filmar.sh $M/$t/video ${3:-110} &
v=$!
TECLAS_DASH=1 TECLA_A=32 TECLA_B=31 TANDAS=2 ESPERA=${3:-110} bash $M/scripts/boton.sh TerrainDev-Titulo-v12s-solo$c.w3x $t > $M/$t.salida 2>&1
wait $v
tail -3 $M/$t.salida
