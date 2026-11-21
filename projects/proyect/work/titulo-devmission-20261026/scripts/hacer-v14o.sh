#!/bin/bash
# v14o: bala por categoría con el color del tier (Yellow, Green, Cyan), granada en arco que sólo daña al caer, ráfaga de
# 1,5 s y ajustes de pistola, subfusil, rifle y francotirador (v14o.py). Parte del mapa v14n.
# Balas: copias teñidas de TerrainDev/assets/balas-colores (Shot y Shot II Cyan, Daemonic Arrow) con las texturas de la
# Daemonic Arrow clásica que pidió v15a; granada: TerrainDev/assets/chain-grenade (Vinz, y sus copias teñidas).
# Variantes: v14o-prueba (directa) y v14o-prueba-intro para Leon; v14o-auto dispara solo para la prueba por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14o; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14n.w3x; DA=/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/assets; DC=$DA/daemonic-arrow-classic
$W extract $B war3map.j -o $P/v14n-base.j > /dev/null && cmp -s $P/v14n-base.j v14n/war3map.j || { echo 'v14n/war3map.j no es el del mapa v14n'; exit 1; }
mkdir -p v14o v14o-prueba v14o-prueba-intro v14o-auto
python3 -I scripts/v14o.py v14n/war3map.j v14o/war3map.j || exit 1
python3 -I scripts/prueba_v14o.py v14o/war3map.j v14o-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v14o.py v14o/war3map.j v14o-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v14o.py v14o/war3map.j v14o-auto/war3map.j auto || exit 1
for f in v14o v14o-prueba v14o-prueba-intro v14o-auto; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
imp=()
# Sólo los colores de los 3 tiers: modelos Yellow, Green y Cyan de cada manifiesto, con sus texturas.
while IFS='|' read -r interno archivo; do imp+=("$interno=$DA/$archivo"); done < <(python3 -I -c "
import json
for m in ('balas-colores', 'chain-grenade'):
    d = json.load(open('$DA/' + m + '/manifest.json'))['imports']
    usados = [x for x in d if x['internal'].endswith(('Yellow.mdx', 'Green.mdx', 'Cyan.mdx'))]
    tex = {t for x in usados for t in x.get('textures', [])}
    print('\n'.join(x['internal'] + '|' + x['file'] for x in d if x in usados or x['internal'] in tex))")
# Texturas de la Daemonic Arrow clásica (como en v15a); smoke_bw y flaresimple01_bw ya están en el mapa, idénticas.
for t in flareshot01_bw flash01_bw; do imp+=("war3mapImported\\$t.blp=$DC/$t.blp"); done
for t in dust3 flaresimple02_bw; do imp+=("DaemonicArrow\\$t.blp=$DC/$t.blp"); done
for sal in v14o v14o-prueba v14o-prueba-intro v14o-auto; do
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
sha256sum TerrainDev-Titulo-v14o.w3x TerrainDev-Titulo-v14o-prueba.w3x TerrainDev-Titulo-v14o-prueba-intro.w3x TerrainDev-Titulo-v14o-auto.w3x
