#!/bin/bash
# v14n: vuelve al script de v14l (se quitan las habilidades del Prawn de v14m, que se rehacen) e importa, sin usarlos
# todavía, los avisos de habilidad de ShootingGay 0.7ENG (fuentes/shootinggay-0.7/HALLAZGOS.md): 14 modelos v800,
# sus 7 texturas en la raíz, 7 texturas de rayo y Splats\LightningData.slk con 9 rayos nuevos (rayos_v14n.py).
# Variantes: v14n-prueba (directa) y v14n-prueba-intro, con el registro ligero de prueba_v14n.py.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
G=/home/snz/Documentos/ChatGPT/FrozenThone/games/WarcraftIII-1.27b
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14n; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14l.w3x; SG=fuentes/shootinggay-0.7/ext
$W extract $B war3map.j -o $P/v14l-base.j > /dev/null && cmp -s $P/v14l-base.j v14l/war3map.j || { echo 'v14l/war3map.j no es el del mapa v14l'; exit 1; }
mkdir -p v14n/imp v14n-prueba v14n-prueba-intro
cp v14l/war3map.j v14n/war3map.j
$W extract $G/War3x.mpq 'Splats\LightningData.slk' -o v14n/imp/LightningData-War3x.slk > /dev/null || exit 1
python3 -I scripts/rayos_v14n.py v14n/imp/LightningData-War3x.slk $SG/Splats/LightningData.slk v14n/imp/LightningData.slk || exit 1
imp=("Splats\\LightningData.slk=v14n/imp/LightningData.slk")
for t in ArrowLine BluePhaserTex LaserBlue LaserWhite PinkPhaserTex StorongLightning white; do
  imp+=("ReplaceableTextures\\Weather\\$t.blp=$SG/ReplaceableTextures/Weather/$t.blp"); done
for m in DangerousCircle bossjinggaoh BigDangerous SpawnCircle "Snipe Target" ExclamationMarkMini az_firering1a CommandAuraTarget \
         MrWar3_XZ4 MrWar3_XZ4Pink LightningCircle LightningGround WhiteBox WhiteBox3X2; do
  imp+=("war3mapImported\\$m.mdx=$SG/war3mapImported/$m.mdx"); done
for t in SelectionCircleSmall SelectionCircle BossjinggaozhixianBG BossjinggaozhixianBG2 ExclamationMark az_firering1a BYDG; do
  imp+=("$t.blp=$SG/$t.blp"); done
python3 scripts/prueba_v14n.py v14n/war3map.j v14n-prueba/war3map.j directa || exit 1
python3 scripts/prueba_v14n.py v14n/war3map.j v14n-prueba-intro/war3map.j intro || exit 1
for f in v14n v14n-prueba v14n-prueba-intro; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14n v14n-prueba v14n-prueba-intro; do
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
sha256sum TerrainDev-Titulo-v14n.w3x TerrainDev-Titulo-v14n-prueba.w3x TerrainDev-Titulo-v14n-prueba-intro.w3x
