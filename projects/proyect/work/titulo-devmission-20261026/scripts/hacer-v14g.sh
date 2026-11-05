#!/bin/bash
# v14g: v14f con élites, jefes con salto y refuerzos, localizador del jefe y barras más altas.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad
FX="/home/snz/Documentos/ChatGPT/Proyect/WaveSys/resources/devmission-v096/war3mapImported/Bondage Blue SD.mdx"
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14g v14g-prueba
python3 scripts/objetos_v14g.py "$P/v14f-ext/war3map.w3u" "$P/v14f-ext/UI/HealthBarsHorizontal/HealthIconTauren.mdx" v14g v14f/war3map.j > /dev/null || exit 1
python3 scripts/esfera_v14g.py "$P/v14f-ext/war3mapImported/BossShield.mdx" texturas/jefe-esfera/Blue_Glow2.ppm v14g/JefeEsfera.mdx v14g/JefeEsferaBrillo.blp || exit 1
python3 scripts/v14g.py v14f/war3map.j v14g/war3map.j || exit 1
python3 scripts/prueba_v14g.py v14g/war3map.j v14g-prueba/war3map.j ${1:-7} || exit 1
for f in v14g v14g-prueba; do
  $PJ $f/war3map.j | tail -1 | grep -q 'Parse successful' || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }
done
for sal in v14g v14g-prueba; do
  cur=TerrainDev-Titulo-v14f.w3x; n=0
  add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$sal-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$sal-$n.w3x"; }
  add war3map.j $sal/war3map.j
  add war3map.w3u v14g/war3map.w3u
  add war3map.w3q v14g/war3map.w3q
  for c in 2 3 4 5 6 7 8 9 A; do add "UI\\HealthBarsHorizontal\\JefeIcono$c.mdx" v14g/JefeIcono$c.mdx; done
  add 'war3mapImported\Bondage Blue SD.mdx' "$FX"
  add 'war3mapImported\JefeEsfera.mdx' v14g/JefeEsfera.mdx
  add 'war3mapImported\JefeEsferaBrillo.blp' v14g/JefeEsferaBrillo.blp
  cp "$cur" TerrainDev-Titulo-$sal.w3x
  rm -f "${P:?}"/$sal-*.w3x
done
$W mpq verify TerrainDev-Titulo-v14g.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14g.w3x TerrainDev-Titulo-v14g-prueba.w3x
