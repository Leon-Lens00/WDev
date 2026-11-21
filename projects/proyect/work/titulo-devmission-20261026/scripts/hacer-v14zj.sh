#!/bin/bash
# v14zj: fase 1 de docs/planes/devmission-armas-rachas-v14zj.md (v14zj.py sobre el j de v14zi): sin pistolas, empieza con
# el subfusil, daño y precios nuevos, requisito de ronda por tier, R arma, F recargar, G batería (objetos_v14zj.py
# sobre el w3a del mapa v14zi). Parte del mapa v14zi y sólo reemplaza war3map.j y war3map.w3a.
# v14zj-prueba-dia (prueba_v14zj.py): entrada directa, vida ilimitada, «-oro N», «-compra C T», «-fin»; registro en lat\v14zj-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zj; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zi.w3x
$W extract $B war3map.j -o $P/v14zi-base.j > /dev/null && cmp -s $P/v14zi-base.j v14zi/war3map.j || { echo 'v14zi/war3map.j no es el del mapa v14zi'; exit 1; }
$W extract $B war3map.w3a -o $P/obj/war3map.w3a > /dev/null || exit 1
mkdir -p v14zj v14zj-obj v14zj-prueba-dia
python3 -I scripts/objetos_v14zj.py $P/obj v14zj-obj || exit 1
python3 -I scripts/v14zj.py v14zi/war3map.j v14zj/war3map.j || exit 1
python3 -I scripts/prueba_v14zj.py v14zj/war3map.j v14zj-prueba-dia/war3map.j directa dia || exit 1
for f in v14zj v14zj-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
for sal in v14zj v14zj-prueba-dia; do
  lista=("war3map.j=$sal/war3map.j" "war3map.w3a=v14zj-obj/war3map.w3a")
  $W mpq add $B war3map.j --file $sal/war3map.j -o $P/$sal-1.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  $W mpq add $P/$sal-1.w3x war3map.w3a --file v14zj-obj/war3map.w3a -o $P/$sal-2.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cp $P/$sal-2.w3x TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v14zj*.w3x
