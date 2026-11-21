#!/bin/bash
# v15a: cuatro armas fijas (Q W E R) y sobrecarga en lugar de munición; Refrescar sobrecarga en F (v15a.py).
# Objetos de objetos_v15a.py (teclas, textos y la textura DS0F), relleno de la barra de recursos_v15a.py, sonidos de
# disparo de ShootingGay 0.7ENG y la Daemonic Arrow clásica movida en X (TerrainDev/scripts/daemonic_ajustada.cjs).
# DISBTNArma0..4 (faltaban: con pausa los botones salían verdes). Variantes: v15a-prueba (directa) y v15a-prueba-intro para Leon; v15a-auto dispara solo para la prueba por registro.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v15a; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14n.w3x; SG=fuentes/shootinggay-0.7/ext/war3mapImported
DA=/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/assets; DC=$DA/daemonic-arrow-classic
$W extract $B war3map.j -o $P/v14n-base.j > /dev/null && cmp -s $P/v14n-base.j v14n/war3map.j || { echo 'v14n/war3map.j no es el del mapa v14n'; exit 1; }
mkdir -p v15a/obj v15a-prueba v15a-prueba-intro v15a-auto
for f in war3map.w3a war3map.w3b war3map.imp; do $W extract $B $f -o v15a/obj/$f > /dev/null || exit 1; done
python3 -I scripts/objetos_v15a.py v15a/obj v15a/obj-out || exit 1
mkdir -p v15a/btn; for i in 0 1 2 3 4; do $W extract $B "war3mapImported\\BTNArma$i.blp" -o v15a/btn/BTNArma$i.blp > /dev/null || exit 1; done
$PY -I scripts/recursos_v15a.py v15a/recursos v15a/btn || exit 1
python3 -I scripts/v15a.py v14n/war3map.j v15a/war3map.j || exit 1
python3 -I scripts/prueba_v15a.py v15a/war3map.j v15a-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v15a.py v15a/war3map.j v15a-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v15a.py v15a/war3map.j v15a-auto/war3map.j auto || exit 1
for f in v15a v15a-prueba v15a-prueba-intro v15a-auto; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
imp=("war3map.w3a=v15a/obj-out/war3map.w3a" "war3map.w3b=v15a/obj-out/war3map.w3b" "war3map.imp=v15a/obj-out/war3map.imp"
     "war3mapImported\\HudCarga.blp=v15a/recursos/HudCarga.blp")
for i in 0 1 2 3 4; do imp+=("ReplaceableTextures\\CommandButtonsDisabled\\DISBTNArma$i.blp=v15a/recursos/DISBTNArma$i.blp"); done
for n in PistolShoot.wav MachineGunShoot.wav ShotGunShoot.mp3 SniperRifleShoot.mp3; do imp+=("war3mapImported\\$n=$SG/$n"); done
imp+=("DaemonicArrow\\Daemonic Arrow Purple.mdx=$DA/daemonic-ajustada/Daemonic Arrow Purple.mdx")
# smoke_bw y flaresimple01_bw ya están en el mapa, idénticas; dust3 y flaresimple02_bw del mapa son otras.
for t in flareshot01_bw RoyalGlow flash01_bw; do imp+=("war3mapImported\\$t.blp=$DC/$t.blp"); done
for t in dust3 flaresimple02_bw; do imp+=("DaemonicArrow\\$t.blp=$DC/$t.blp"); done
for sal in v15a v15a-prueba v15a-prueba-intro v15a-auto; do
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
sha256sum TerrainDev-Titulo-v15a.w3x TerrainDev-Titulo-v15a-prueba.w3x TerrainDev-Titulo-v15a-prueba-intro.w3x TerrainDev-Titulo-v15a-auto.w3x
