#!/bin/bash
# v14zi: tarde 4 fija y día con neblina blanca (v14zi.py sobre el j de v14zh; Dark Nights de tarde_v14zh.cjs más la
# meseta de dia_v14zi.cjs). Las de prueba añaden «-dia N» y entran también de día. v14zh: tarde naranja, «-tarde N». v14zg: batería llena en el descanso. Lo demás como hacer-v14zf.sh. v14zf: batería de la luz del héroe (v14zf.py): Luz 8 de v14zc en pasos BatLuz0..5 (luz_bateria.cjs), barra en el
# marco de blindaje con el relleno HudCarga de v15a, texto «Batería» y Recargar batería (Aw0A, V; objetos_v14zi.py).
# Parte del j de v14ze y de sus doodads; w3a/w3b/imp extraídos del mapa v14ze. v14zi-prueba-tarde y -noche
# (prueba_v14zi.py) entran directas, con vida ilimitada, «-bateria N», «-cargas N», «-fin», «-tarde N», «-dia N» y registro en lat\v14zi-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zi; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14q.w3x; S=fuentes/storm-1.3.1/paquete
$W extract TerrainDev-Titulo-v14zh.w3x war3map.j -o $P/v14zh-base.j > /dev/null && cmp -s $P/v14zh-base.j v14zh/war3map.j || { echo 'v14zh/war3map.j no es el del mapa v14zh'; exit 1; }
for f in war3map.w3a war3map.w3b war3map.imp; do $W extract TerrainDev-Titulo-v14ze.w3x $f -o $P/obj/$f > /dev/null || exit 1; done
$W extract TerrainDev-Titulo-v14s.w3x 'war3mapImported\StormLuz.mdx' -o $P/luz.mdx > /dev/null && cmp -s $P/luz.mdx storm-luz/StormLuz.mdx || { echo 'StormLuz de v14s distinto'; exit 1; }
$W extract TerrainDev-Titulo-v15a.w3x 'war3mapImported\HudCarga.blp' -o $P/carga.blp > /dev/null && cmp -s $P/carga.blp v15a/recursos/HudCarga.blp || { echo 'HudCarga de v15a distinto'; exit 1; }
node scripts/doodads_v14ze.cjs fuentes/doodads-juego/orig doodads-v14ze > /dev/null || exit 1
mkdir -p tarde-v14zh dia-v14zi && node scripts/tarde_v14zh.cjs "fuentes/dark-nights/x/Dark Nights Day-night-cycle" tarde-v14zh > /dev/null && node scripts/dia_v14zi.cjs tarde-v14zh dia-v14zi > /dev/null || exit 1
node scripts/luz_bateria.cjs "fuentes/light-lights/x/Light White 700/LightWhite700.mdx" luz-bateria > /dev/null || exit 1
python3 -I scripts/objetos_v14zf.py $P/obj v14zf-obj > /dev/null || exit 1
mkdir -p v14zi v14zi-prueba-dia v14zi-prueba-tarde v14zi-prueba-noche
python3 -I scripts/v14zi.py v14zh/war3map.j v14zi/war3map.j || exit 1
for var in dia tarde noche; do
  python3 -I scripts/prueba_v14zi.py v14zi/war3map.j v14zi-prueba-$var/war3map.j directa $var || exit 1
done
for f in v14zi v14zi-prueba-dia v14zi-prueba-tarde v14zi-prueba-noche; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3u=v14y/obj-out/war3map.w3u" "war3mapImported\\StormLuz.mdx=storm-luz/StormLuz.mdx")
for f in w3a w3b imp; do imp+=("war3map.$f=v14zf-obj/war3map.$f"); done
imp+=("war3mapImported\\HudCarga.blp=v15a/recursos/HudCarga.blp")
for i in 0 1 2 3 4 5; do imp+=("war3mapImported\\BatLuz$i.mdx=luz-bateria/BatLuz$i.mdx"); done
while read -r r; do imp+=("${r//\//\\}=doodads-v14ze/$r"); done < <(cd doodads-v14ze && find Doodads -name '*.mdx' | sort)
D=dia-v14zi
for t in Terrain Unit; do imp+=("war3mapImported\\DNCDarkNightsLordaeron$t.mdx=$D/DNCDarkNightsLordaeron$t.mdx"); done
for i in 1 2 3; do imp+=("war3mapImported\\StormT$i.wav=$S/T$i.wav"); done
for sal in v14zi v14zi-prueba-dia v14zi-prueba-tarde v14zi-prueba-noche; do
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
sha256sum TerrainDev-Titulo-v14zi*.w3x
