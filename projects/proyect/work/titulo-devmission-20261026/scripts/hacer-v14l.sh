#!/bin/bash
# v14l: v14k con tipos de daño y armaduras (scripts/v14l.py, objetos_v14l.py; tabla propia en war3mapMisc.txt).
# Variantes: v14l-prueba (directa), v14l-prueba-intro, v14l-tienda (abre la tienda sola) y v14l-dano (mide la tabla con 8 unidades de prueba de
# objetos_dano_prueba.py, sólo en su w3u).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14l; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14k.w3x
$W extract $B war3map.j -o $P/v14k-base.j > /dev/null && cmp -s $P/v14k-base.j v14k/war3map.j || { echo 'v14k/war3map.j no es el del mapa v14k'; exit 1; }
$W extract $B war3map.w3u -o $P/v14k.w3u > /dev/null && cmp -s $P/v14k.w3u v14k/obj/war3map.w3u || { echo 'v14k/obj/war3map.w3u no es el del mapa v14k'; exit 1; }
mkdir -p v14l/obj v14l-prueba v14l-prueba-intro v14l-tienda v14l-dano
$W extract $B war3mapMisc.txt -o v14l/obj/war3mapMisc-v14k.txt > /dev/null || exit 1
python3 scripts/objetos_v14l.py v14k/obj/war3map.w3u v14l/obj/war3map.w3u v14l/obj/war3mapMisc-v14k.txt v14l/obj/war3mapMisc.txt v14k/war3map.j || exit 1
python3 scripts/v14l.py v14k/war3map.j v14l/war3map.j || exit 1
python3 scripts/objetos_dano_prueba.py v14l/obj/war3map.w3u v14l-dano/war3map.w3u || exit 1
python3 scripts/prueba_v14l.py v14l/war3map.j v14l-prueba/war3map.j directa || exit 1
python3 scripts/prueba_v14l.py v14l/war3map.j v14l-prueba-intro/war3map.j intro || exit 1
python3 scripts/prueba_v14l.py v14l/war3map.j v14l-tienda/war3map.j tienda || exit 1
python3 scripts/prueba_dano_v14l.py v14l/war3map.j v14l-dano/war3map.j || exit 1
for f in v14l v14l-prueba v14l-prueba-intro v14l-tienda v14l-dano; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14l v14l-prueba v14l-prueba-intro v14l-tienda v14l-dano; do
  cur=$B; n=0
  add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$sal-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$sal-$n.w3x"; }
  u=v14l/obj/war3map.w3u; [ $sal = v14l-dano ] && u=v14l-dano/war3map.w3u
  lista=("war3map.j=$sal/war3map.j" "war3map.w3u=$u" "war3mapMisc.txt=v14l/obj/war3mapMisc.txt")
  for e in "${lista[@]}"; do add "${e%%=*}" "${e#*=}"; done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
done
$W mpq verify TerrainDev-Titulo-v14l.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14l.w3x TerrainDev-Titulo-v14l-prueba.w3x TerrainDev-Titulo-v14l-prueba-intro.w3x TerrainDev-Titulo-v14l-tienda.w3x TerrainDev-Titulo-v14l-dano.w3x
