#!/bin/bash
# v14h: v14g con tienda que baja y sube, ESC, descanso de 45 s, zonas de munición, élites con vida del jefe y Burning Rage.
# Usa las salidas de v14g (v14g/: war3map.j, w3u, w3q, iconos y esfera) y comprueba que su script sea el del mapa v14g.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad
PY=/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/runtime-linux/python-3.12/bin/python3
FX="/home/snz/Documentos/ChatGPT/Proyect/WaveSys/resources/devmission-v096/war3mapImported/Bondage Blue SD.mdx"
DOO=puntos/guardado-v14h-1318/war3mapUnits.doo
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
E=$P/v14f-ext
for f in war3map.w3u war3map.w3a 'UI\HealthBarsHorizontal\HealthIconTauren.mdx' 'war3mapImported\BossShield.mdx'; do
  o="$E/${f//\\//}"
  [ -f "$o" ] || { mkdir -p "$(dirname "$o")"; $W extract TerrainDev-Titulo-v14f.w3x "$f" -o "$o" > /dev/null || exit 1; }
done
$W extract TerrainDev-Titulo-v14g.w3x war3map.j -o $P/v14g-base.j > /dev/null || exit 1
cmp -s $P/v14g-base.j v14g/war3map.j || { echo 'v14g/war3map.j no es el del mapa v14g'; exit 1; }
mkdir -p v14h v14h-prueba
$PY -W ignore scripts/efectos_v14h.py . $E/war3mapImported/BossShield.mdx v14h-efectos > /dev/null || exit 1
python3 scripts/objetos_v14h.py v14g/war3map.w3u $E/war3map.w3a $E/UI/HealthBarsHorizontal/HealthIconTauren.mdx v14f/war3map.j v14h > /dev/null || exit 1
python3 scripts/v14h.py v14g/war3map.j v14h/war3map.j $DOO || exit 1
python3 scripts/prueba_v14h.py v14h/war3map.j v14h-prueba/war3map.j ${1:-2} || exit 1
for f in v14h v14h-prueba; do
  $PJ $f/war3map.j | tail -1 | grep -q 'Parse successful' || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -8; exit 1; }
done
for sal in v14h v14h-prueba; do
  cur=TerrainDev-Titulo-v14f.w3x; n=0
  add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$sal-$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$sal-$n.w3x"; }
  add war3map.j $sal/war3map.j
  add war3map.w3u v14h/war3map.w3u
  add war3map.w3a v14h/war3map.w3a
  add war3map.w3q v14g/war3map.w3q
  for c in 2 3 4 5 6 7 8 9 A; do add "UI\\HealthBarsHorizontal\\JefeIcono$c.mdx" v14g/JefeIcono$c.mdx; done
  add 'UI\HealthBarsHorizontal\TiendaIcono.mdx' v14h/TiendaIcono.mdx
  add 'war3mapImported\Bondage Blue SD.mdx' "$FX"
  add 'war3mapImported\JefeEsfera.mdx' v14g/JefeEsfera.mdx
  add 'war3mapImported\JefeEsferaBrillo.blp' v14g/JefeEsferaBrillo.blp
  for k in 1 2 3 4 5 6 7 8 9 10; do add "war3mapImported\\BurningRage$k.mdx" v14h-efectos/BurningRage$k.mdx; done
  # Las texturas propias de Burning Rage van en la raíz, con la ruta que tienen en los modelos.
  for t in AzureGlow5 VerdantGlow3 EmberGlow7 CrimsonGlow2 RoyalGlow02 PlataGlow VioletaGlow; do add "$t.blp" v14h-efectos/$t.blp; done
  for t in PlataBrillo.blp VioletaBrillo.blp RecargaVerde.mdx RecargaRoja.mdx TiendaEsfera.mdx; do add "war3mapImported\\$t" v14h-efectos/$t; done
  cp "$cur" TerrainDev-Titulo-$sal.w3x
  rm -f "${P:?}"/$sal-*.w3x
done
# Reextraer y comparar lo cambiado.
for par in "war3map.j:v14h/war3map.j" "war3map.w3u:v14h/war3map.w3u" "war3map.w3a:v14h/war3map.w3a" 'war3mapImported\BurningRage10.mdx:v14h-efectos/BurningRage10.mdx' 'VioletaGlow.blp:v14h-efectos/VioletaGlow.blp'; do
  $W extract TerrainDev-Titulo-v14h.w3x "${par%%:*}" -o $P/v14h-re > /dev/null && cmp -s $P/v14h-re "${par#*:}" || { echo "reextracción distinta: ${par%%:*}"; exit 1; }
done
$W extract TerrainDev-Titulo-v14h-prueba.w3x war3map.j -o $P/v14h-re > /dev/null && cmp -s $P/v14h-re v14h-prueba/war3map.j || { echo 'reextracción distinta: prueba'; exit 1; }
$W mpq verify TerrainDev-Titulo-v14h.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14h.w3x TerrainDev-Titulo-v14h-prueba.w3x
