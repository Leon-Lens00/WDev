#!/bin/bash
# v12q: v12p con rondas, descanso, reaparición y contador; copias de prueba solo0 (modo 1) y solo1 (modo 2).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
X=v12q/x; mkdir -p v12q v12q-solo; [ -d $X ] || $W mpq extract-all TerrainDev-Titulo-v12p.w3x -o $X | tail -1
python3 scripts/rondas_v12q.py v12p/war3map.j v12q/war3map.j || exit 1
python3 scripts/icono_v12q.py $X/UI/HealthBarsHorizontal/HealthIconTauren.mdx v12q/RondaIcono.mdx v12q/RondaIcono.blp || exit 1
python3 scripts/objetos_v12q.py $X/war3map.w3b v12q/war3map.w3b $X/war3map.imp v12q/war3map.imp $X/war3map.w3u v12q/war3map.w3u || exit 1
$PJ v12q/war3map.j | tail -8 | grep -v 'common.j\|Blizzard.j'
B=TerrainDev-Titulo-v12q.w3x; cp TerrainDev-Titulo-v12p.w3x $B
add(){ $W mpq add $B "$1" --file "$2" -o $B.tmp | tail -1 | grep -v 'round-trips'; mv $B.tmp $B; }
add war3map.j v12q/war3map.j; add war3map.imp v12q/war3map.imp; add war3map.w3u v12q/war3map.w3u
add 'UI\HealthBarsHorizontal\RondaIcono.mdx' v12q/RondaIcono.mdx; add 'UI\HealthBarsHorizontal\RondaIcono.blp' v12q/RondaIcono.blp
for c in 0 1; do
 python3 scripts/puente_rondas_v12q.py $PWD/v12q/war3map.j $PWD/v12q-solo/war3map-$c.j 0 $((c+1)) | tail -1
 $PJ v12q-solo/war3map-$c.j | tail -8 | grep -v 'common.j\|Blizzard.j'
 $W mpq add $B war3map.j --file v12q-solo/war3map-$c.j -o TerrainDev-Titulo-v12q-solo$c.w3x | tail -1 | grep -v round-trips
done
$W mpq verify $B | tail -1 | cut -c1-90
$W mpq bytes-diff TerrainDev-Titulo-v12p.w3x $B | grep -v -i 'same\|match' | tail -8
sha256sum $B
