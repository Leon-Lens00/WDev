#!/bin/bash
# v15c (con v15b y v15d): balas del color del tier, la tienda del prototipo de UI System y sus precios (v15c.py).
# Parte del mapa v15a. Objetos de objetos_v15c.py: 20 texturas DS17..DS1R del prototipo y los textos de Q W E R.
# Quads de clic de hits_v15c.cjs.
# Balas: copias teñidas de TerrainDev/scripts/balas_colores.cjs, según el manifiesto de TerrainDev/assets/balas-colores.
# Variantes: v15c-prueba (directa) y v15c-prueba-intro para Leon; v15c-auto prueba la tienda y las balas por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v15c; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v15a.w3x; TX=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-mejoras-20261105/texturas
DA=/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/assets
$W extract $B war3map.j -o $P/v15a-base.j > /dev/null && cmp -s $P/v15a-base.j v15a/war3map.j || { echo 'v15a/war3map.j no es el del mapa v15a'; exit 1; }
mkdir -p v15c/obj v15c-prueba v15c-prueba-intro v15c-auto
for f in war3map.w3a war3map.w3b war3map.imp; do $W extract $B $f -o v15c/obj/$f > /dev/null || exit 1; done
python3 -I scripts/objetos_v15c.py v15c/obj v15c/obj-out || exit 1
node scripts/hits_v15c.cjs v15c/hits > /dev/null || exit 1
python3 -I scripts/v15c.py v15a/war3map.j v15c/war3map.j || exit 1
python3 -I scripts/prueba_v15c.py v15c/war3map.j v15c-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v15c.py v15c/war3map.j v15c-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v15c.py v15c/war3map.j v15c-auto/war3map.j auto || exit 1
for f in v15c v15c-prueba v15c-prueba-intro v15c-auto; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
imp=("war3map.w3a=v15c/obj-out/war3map.w3a" "war3map.w3b=v15c/obj-out/war3map.w3b" "war3map.imp=v15c/obj-out/war3map.imp")
for n in $(python3 -I -c "import sys; sys.path.insert(0, 'scripts'); from objetos_v15c import TEX; print(' '.join(n for _, n in TEX))"); do
  imp+=("war3mapImported\\Tm$n.blp=$TX/$n.blp")
done
for n in Nodo Modelo Volver Comprar; do imp+=("war3mapImported\\ShopHit$n.mdx=v15c/hits/ShopHit$n.mdx"); done
while IFS='|' read -r interno archivo; do imp+=("$interno=$DA/$archivo"); done < <(python3 -I -c "
import json; d = json.load(open('$DA/balas-colores/manifest.json'))
print('\n'.join(x['internal'] + '|' + x['file'] for x in d['imports']))")
for sal in v15c v15c-prueba v15c-prueba-intro v15c-auto; do
  cur=$B; n=0
  lista=("war3map.j=$sal/war3map.j" "${imp[@]}")
  for e in "${lista[@]}"; do
    n=$((n+1)); $W mpq add "$cur" "${e%%=*}" --file "${e#*=}" -o "$P/$sal-$n.w3x" | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
    [ $n -gt 1 ] && rm -f "$cur"; cur="$P/$sal-$n.w3x"
  done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
echo "importados: $((${#imp[@]})) archivos"
sha256sum TerrainDev-Titulo-v15c.w3x TerrainDev-Titulo-v15c-prueba.w3x TerrainDev-Titulo-v15c-prueba-intro.w3x TerrainDev-Titulo-v15c-auto.w3x
