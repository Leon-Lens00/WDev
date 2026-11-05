#!/bin/bash
# Test general. Uso: general-v12t.sh CELDA INTENTO VIDAS LIMITE
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; cd $M; c=${1:-0}; v=${3:-3}; mkdir -p v12u-solo; t=v12u-solo/try$c-${2:-1}; mkdir -p $t
python3 scripts/puente_general_v12t.py $PWD/v12u/war3map.j $PWD/v12u-solo/war3map-$c.j $c $v | tail -1 || exit 1
$PJ v12u-solo/war3map-$c.j | tail -6 | grep -v 'common.j\|Blizzard.j'
$W mpq add TerrainDev-Titulo-v12u.w3x war3map.j --file v12u-solo/war3map-$c.j -o TerrainDev-Titulo-v12u-solo$c.w3x | tail -1 | grep -v round-trips
bash scripts/filmar.sh $M/$t/video ${FILMA:-200} &
f=$!
TECLAS_DASH=1 JUGAR=1 LIMITE=${4:-600} bash scripts/boton.sh TerrainDev-Titulo-v12u-solo$c.w3x $t > $t.salida 2>&1
wait $f
cat $t.salida | tail -8
