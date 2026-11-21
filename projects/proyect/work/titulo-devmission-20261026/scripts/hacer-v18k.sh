#!/bin/bash
# v18k (15/11/2026): cuadro de puntuación al estilo "Round Score" de Dark Moon (centro, entra desde arriba, sale hacia
# abajo, recuento con los sonidos originales) y libro de habilidades del controlador (fase 6). Sobre v18j.
# Cambian j, w3a, w3b e imp; se añaden war3mapImported\PuntCuadro.blp y 7 wav (sonido_v18k.py desde el VPK de Dark
# Moon y el pak01 de Dota 2; audio de Valve: sólo para la prueba privada, ver sonidos-darkmoon/LEEME.md).
# Salidas: TerrainDev-Titulo-v18k.w3x y -prueba (lat\v18k-*.txt).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
DM=/home/snz/.local/share/Steam/steamapps/workshop/content/570/2837608304/2837608304.vpk
DOTA="/home/snz/.local/share/Steam/steamapps/common/dota 2 beta/game/dota/pak01_dir.vpk"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v18k-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P/vsnd
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v18k v18k-prueba sonidos-darkmoon
$PYP -I scripts/puntos_v18k.py $FUENTE puntos-v18k > /dev/null || exit 1
# Sonidos: VPK -> .vsnd_c -> wav con el nombre del mapa.
python3 -I scripts/vpkmulti.py $DM $P/vsnd sounds/round_fanfare.vsnd_c sounds/tally_rise_gold.vsnd_c \
  sounds/tally_end_gold.vsnd_c sounds/tally_end.vsnd_c sounds/bigtreant_step_01.vsnd_c sounds/bigtreant_step_02.vsnd_c > /dev/null || exit 1
python3 -I scripts/vpkmulti.py "$DOTA" $P/vsnd sounds/ui/item_drop_world.vsnd_c > /dev/null || exit 1
SND="round_fanfare:PuntFanfarria tally_rise_gold:PuntSube tally_end_gold:PuntSubeFin item_drop_world:PuntPerdida tally_end:PuntTic bigtreant_step_01:PuntEstrella1 bigtreant_step_02:PuntEstrella2"
for s in $SND; do
  python3 -I scripts/sonido_v18k.py $P/vsnd/${s%%:*}.vsnd_c sonidos-darkmoon/${s##*:}.wav || exit 1
done
for v in v18j v18j-prueba; do
  case $v in v18j) H=8dca71b74827387835418f818a86703d3f3b2aac840d912d5865655986e3f34d; M=;; *) H=e18544f405568a04526f6e9e8a55d6d605fd4297502751f798f3af0c4d017447; M=prueba;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v18j/v18k}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  mkdir -p $P/$v-in $P/$N-obj
  for f in war3map.j war3map.w3a war3map.w3b war3map.imp; do $W extract $B $f -o $P/$v-in/$f > /dev/null || exit 1; done
  cmp -s $P/$v-in/war3map.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/objetos_v18f.py $P/$v-in $P/$N-obj puntos-v18k || exit 1
  python3 -I scripts/objetos_v18k.py $P/$v-in/war3map.w3a $P/$N-obj/war3map.w3a > /dev/null || exit 1
  python3 -I scripts/v18k.py $v/war3map.j $N/war3map.j puntos-v18k $M > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cp $P/$N-obj/war3map.w3a $P/$N-obj/war3map.w3b $P/$N-obj/war3map.imp $N/
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/a.w3x > /dev/null || exit 1
  $W mpq add $P/a.w3x war3map.w3a --file $N/war3map.w3a -o $P/a2.w3x > /dev/null || exit 1
  $W mpq add $P/a2.w3x war3map.w3b --file $N/war3map.w3b -o $P/b.w3x > /dev/null || exit 1
  $W mpq add $P/b.w3x war3map.imp --file $N/war3map.imp -o $P/c0.w3x > /dev/null || exit 1
  $W mpq add $P/c0.w3x 'war3mapImported\PuntCuadro.blp' --file puntos-v18k/PuntCuadro.blp -o $P/c1.w3x > /dev/null || exit 1
  n=1
  for s in $SND; do
    $W mpq add $P/c$n.w3x "war3mapImported\\${s##*:}.wav" --file sonidos-darkmoon/${s##*:}.wav -o $P/c$((n+1)).w3x > /dev/null || exit 1
    n=$((n+1))
  done
  { head -c 512 $B; tail -c +513 $P/c$n.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3a war3map.w3b war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  $W extract $O 'war3mapImported\PuntCuadro.blp' -o $P/re > /dev/null && cmp -s $P/re puntos-v18k/PuntCuadro.blp || { echo "$N: reextracción de PuntCuadro.blp distinta"; exit 1; }
  for s in $SND; do
    $W extract $O "war3mapImported\\${s##*:}.wav" -o $P/re > /dev/null && cmp -s $P/re sonidos-darkmoon/${s##*:}.wav || { echo "$N: reextracción de ${s##*:}.wav distinta"; exit 1; }
  done
  for f in war3map.w3u war3map.w3i war3map.wts war3map.doo 'war3mapImported\PuntPanel.blp' 'war3mapImported\PuntEstrella.blp' 'war3mapImported\TiendaEt9.blp' 'war3mapImported\CuaHitBtn.mdx' 'war3mapImported\SupTic.wav' 'war3mapImported\ShopPlano.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: j, w3a, w3b, imp, 1 blp y 7 wav reextraídos; cabecera y resto igual a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
