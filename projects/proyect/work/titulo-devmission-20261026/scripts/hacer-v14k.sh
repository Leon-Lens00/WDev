#!/bin/bash
# v14k: v14j con retratos vivos en la tienda (golem 'dgo0', Tauren 'dts0', Cairne 'dcs0', sin billboard), voz del comprador y "Abastecer todo"
# (scripts/v14k.py, objetos_v14k.py, retrato_golem.cjs). El fondo del retrato (DS0D, war3mapImported\ShopGolem.blp) pasa
# a ser el oscuro del título (PortraitDark.blp). Pruebas: v14k-prueba (directa) y v14k-prueba-intro para jugar;
# v14k-tienda (abre la tienda sola) y v14k-vista (recorrido automático) con las zonas de clic pintadas.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14k; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=v14k-recursos
$W extract TerrainDev-Titulo-v14j.w3x war3map.j -o $P/v14j-base.j > /dev/null && cmp -s $P/v14j-base.j v14j/war3map.j || { echo 'v14j/war3map.j no es el del mapa v14j'; exit 1; }
$W extract TerrainDev-Titulo-v14j.w3x 'war3mapImported\PortraitDark.blp' -o $R/ShopGolem.blp > /dev/null || exit 1
mkdir -p v14k/obj v14k-prueba v14k-prueba-intro v14k-tienda v14k-vista
$W extract TerrainDev-Titulo-v14j.w3x war3map.w3u -o v14k/obj/war3map-v14j.w3u > /dev/null || exit 1
python3 scripts/objetos_v14k.py v14k/obj/war3map-v14j.w3u v14k/obj/war3map.w3u || exit 1
cmp -s retrato-golem/salida/golem.mdx $R/RetratoGolem.mdx || { echo 'RetratoGolem.mdx no es la salida de retrato_golem.cjs'; exit 1; }
for n in tauren cairne; do $W extract TerrainDev-Titulo-v14j.w3x "UI\\Dialogue\\Portraits\\$n.mdx" -o $R/$n-titulo.mdx > /dev/null || exit 1; done
node scripts/retrato_sin_billboard.cjs $R/RetratoGolem.mdx $R/RetratoGolem-tienda.mdx || exit 1
node scripts/retrato_sin_billboard.cjs $R/tauren-titulo.mdx $R/RetratoTauren-tienda.mdx || exit 1
node scripts/retrato_sin_billboard.cjs $R/cairne-titulo.mdx $R/RetratoCairne-tienda.mdx || exit 1
# Zonas de clic pintadas (sólo v14k-tienda y v14k-vista): opacas (filtro 0), sin prueba ni escritura de profundidad.
for z in "Cat 38.5 211.5 00" "Row 34.8 383 01" "Wide 38.5 424 04" "Btn 38.5 227.6 06"; do set -- $z
  python3 scripts/zona_clic.py v14a-recursos/ShopHit$1.mdx $R/ShopHit$1-pintada.mdx $2 $3 14 "ReplaceableTextures\\TeamColor\\TeamColor$4.blp" 0 0xF1 > /dev/null || exit 1
done
python3 scripts/v14k.py v14j/war3map.j v14k/war3map.j || exit 1
python3 scripts/prueba_v14k.py v14k/war3map.j v14k-prueba/war3map.j directa || exit 1
python3 scripts/prueba_v14k.py v14k/war3map.j v14k-prueba-intro/war3map.j intro || exit 1
python3 scripts/prueba_v14k.py v14k/war3map.j v14k-tienda/war3map.j tienda || exit 1
python3 scripts/vista_v14k.py v14k/war3map.j v14k-vista/war3map.j || exit 1
for f in v14k v14k-prueba v14k-prueba-intro v14k-tienda v14k-vista; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14k v14k-prueba v14k-prueba-intro v14k-tienda v14k-vista; do
  cur=TerrainDev-Titulo-v14j.w3x; n=0
  add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$sal-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$sal-$n.w3x"; }
  lista=("war3map.j=$sal/war3map.j" "war3map.w3u=v14k/obj/war3map.w3u" "war3mapImported\\RetratoGolem.mdx=$R/RetratoGolem-tienda.mdx" "war3mapImported\\RetratoTauren.mdx=$R/RetratoTauren-tienda.mdx" "war3mapImported\\RetratoCairne.mdx=$R/RetratoCairne-tienda.mdx" "war3mapImported\\ShopGolem.blp=$R/ShopGolem.blp")
  if [ $sal = v14k-tienda ] || [ $sal = v14k-vista ]; then
    for x in Cat Row Wide Btn; do lista+=("war3mapImported\\ShopHit$x.mdx=$R/ShopHit$x-pintada.mdx"); done
  fi
  for e in "${lista[@]}"; do add "${e%%=*}" "${e#*=}"; done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
done
$W mpq verify TerrainDev-Titulo-v14k.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14k.w3x TerrainDev-Titulo-v14k-prueba.w3x TerrainDev-Titulo-v14k-prueba-intro.w3x TerrainDev-Titulo-v14k-tienda.w3x TerrainDev-Titulo-v14k-vista.w3x
