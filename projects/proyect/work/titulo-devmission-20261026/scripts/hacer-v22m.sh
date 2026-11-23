#!/bin/bash
# v22m (23/11/2026): modelos del MVP con el giro fijo de la presentación del jefe (mvp_giro_camara.cjs, -20°), nombres
# largos recortados en la tabla y centrados/achicados en el lado, PUNTOS centrada. Normal sobre v22l; prueba sobre v22l-prueba.
# Cambian el j (v22m.py), PuntLado.blp (puntos_v22m.py; PuntTabla sale igual) y los 10 MvpFrente*.mdx.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v22m-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
PYP=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
FUENTE=/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/FRIZQT__.ttf
$PYP -I scripts/puntos_v22m.py $FUENTE fuentes/puntos-v22m > /dev/null || exit 1
MODS="Tauren Cairne Goku21 Freezer21 Trunks21 Naruto Kyuubi Kurama21 Vegeta21 Vegito21"
F=fuentes/mvp-v22m; mkdir -p $F
# modelos: de v22j (con billboard, salida de mvp_frente.cjs); la base v22l lleva los de fuentes/mvp-v22l (sin billboard)
for n in $MODS; do
  $W extract TerrainDev-Titulo-v22j.w3x "war3mapImported\\MvpFrente$n.mdx" -o $P/$n-base.mdx > /dev/null || exit 1
  node scripts/mvp_giro_camara.cjs $P/$n-base.mdx $F/MvpFrente$n.mdx -20 > /dev/null || exit 1
done
for par in "v22l eb84e9a39639071f1c7c63e7210122bbebd1a4bfd4894e75ec936053df12dd72 v22m normal" \
           "v22l-prueba a5409e8f1ceb10d4b0395f8b39f823b92ad3f73c9146701838dbc0551519941a v22m-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for n in $MODS; do
    $W extract $B "war3mapImported\\MvpFrente$n.mdx" -o $P/chk.mdx > /dev/null && cmp -s $P/chk.mdx fuentes/mvp-v22l/MvpFrente$n.mdx || { echo "$v: MvpFrente$n distinto de fuentes/mvp-v22l"; exit 1; }
  done
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v22m.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c0.w3x > /dev/null || exit 1
  $W mpq add $P/c0.w3x 'war3mapImported\PuntTabla.blp' --file fuentes/puntos-v22m/PuntTabla.blp -o $P/c1.w3x > /dev/null || exit 1
  $W mpq add $P/c1.w3x 'war3mapImported\PuntLado.blp' --file fuentes/puntos-v22m/PuntLado.blp -o $P/c2.w3x > /dev/null || exit 1
  i=2
  for n in $MODS; do
    $W mpq add $P/c$i.w3x "war3mapImported\\MvpFrente$n.mdx" --file $F/MvpFrente$n.mdx -o $P/c$((i+1)).w3x > /dev/null || exit 1
    i=$((i+1))
  done
  { head -c 512 $B; tail -c +513 $P/c$i.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  for t in PuntTabla PuntLado; do
    $W extract $O "war3mapImported\\$t.blp" -o $P/re.blp > /dev/null && cmp -s $P/re.blp fuentes/puntos-v22m/$t.blp || { echo "$N: $t distinta"; exit 1; }
  done
  for n in $MODS; do
    $W extract $O "war3mapImported\\MvpFrente$n.mdx" -o $P/re.mdx > /dev/null && cmp -s $P/re.mdx $F/MvpFrente$n.mdx || { echo "$N: MvpFrente$n distinto"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|war3mapImported\\PuntTabla\.blp|war3mapImported\\PuntLado\.blp|war3mapImported\\MvpFrente[A-Za-z0-9]+\.mdx|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
WOE=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII/Maps/Test
for N in v22m v22m-prueba; do
  cp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && cmp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && echo "WOE $N: copiado"
done
