#!/bin/bash
# v14p: seis tiers por arma con mejoras por tier (v14p.py, tabla en armas_v14p.py) y habilidades de arma con seis
# niveles (objetos_v14p.py). Parte del mapa v14o.
# Balas de los tiers nuevos (Blue, Purple, Red): Shot, Shot II y Firebrand ya están en el mapa; se añaden la Daemonic
# Arrow Blue y Red (TerrainDev/assets/balas-colores), la Purple ajustada (daemonic-ajustada, con su RoyalGlow clásica)
# y la Chain Grenade Blue y Purple de Vinz y la Red teñida (TerrainDev/assets/chain-grenade).
# Variantes: v14p-prueba (directa) y v14p-prueba-intro para Leon; v14p-auto dispara solo para la prueba por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14p; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14o.w3x; DA=/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/assets; DC=$DA/daemonic-arrow-classic
$W extract $B war3map.j -o $P/v14o-base.j > /dev/null && cmp -s $P/v14o-base.j v14o/war3map.j || { echo 'v14o/war3map.j no es el del mapa v14o'; exit 1; }
mkdir -p v14p/obj-in v14p-prueba v14p-prueba-intro v14p-auto
$W extract $B war3map.w3a -o v14p/obj-in/war3map.w3a > /dev/null || exit 1
python3 -I scripts/objetos_v14p.py v14p/obj-in v14p/obj-out || exit 1
python3 -I scripts/v14p.py v14o/war3map.j v14p/war3map.j || exit 1
python3 -I scripts/prueba_v14p.py v14p/war3map.j v14p-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v14p.py v14p/war3map.j v14p-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v14p.py v14p/war3map.j v14p-auto/war3map.j auto || exit 1
for f in v14p v14p-prueba v14p-prueba-intro v14p-auto; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
imp=("war3map.w3a=v14p/obj-out/war3map.w3a")
# Modelos Blue y Red de la Daemonic Arrow y Blue, Purple y Red de la granada, con sus texturas.
while IFS='|' read -r interno archivo; do imp+=("$interno=$DA/$archivo"); done < <(python3 -I -c "
import json
for m, cols in (('balas-colores', ('Blue', 'Red')), ('chain-grenade', ('Blue', 'Purple', 'Red'))):
    d = json.load(open('$DA/' + m + '/manifest.json'))['imports']
    usados = [x for x in d if x['internal'].endswith(tuple(c + '.mdx' for c in cols)) and ('Daemonic' in x['internal'] or 'Grenade' in x['internal'])]
    tex = {t for x in usados for t in x.get('textures', [])}
    print('\n'.join(x['internal'] + '|' + x['file'] for x in d if x in usados or x['internal'] in tex))")
imp+=("DaemonicArrow\\Daemonic Arrow Purple.mdx=$DA/daemonic-ajustada/Daemonic Arrow Purple.mdx")
imp+=("war3mapImported\\RoyalGlow.blp=$DC/RoyalGlow.blp")
for sal in v14p v14p-prueba v14p-prueba-intro v14p-auto; do
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
printf '%s\n' "${imp[@]}" | cut -d= -f1
echo "importados: $((${#imp[@]})) archivos"
sha256sum TerrainDev-Titulo-v14p.w3x TerrainDev-Titulo-v14p-prueba.w3x TerrainDev-Titulo-v14p-prueba-intro.w3x TerrainDev-Titulo-v14p-auto.w3x
