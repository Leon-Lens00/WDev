#!/bin/bash
# v21y (22/11/2026): Naruto Kurama de D.O.N 2.1a, personaje nuevo en la celda 6 (el sabio sigue en la 5), con tiers,
# regla de área, manto con bono a las armas y sonidos 3D. Normal sobre v21x; prueba sobre v21x-prueba.
# Cambian el j (v21y.py; código trasplantado en fuentes/nk21-j), w3u/w3a/w3h/w3b (objetos_nk21.py, guardados en
# fuentes/nk21-obj), el imp y 40 recursos (recursos_nk21.py y sonidos_don3d.py, fuentes/nk21.tsv).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21y-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
OBJ="war3map.w3u war3map.w3a war3map.w3h war3map.w3b"
# objetos de entrada de objetos_nk21.py (los de v21x)
BASEOBJ="3f608282de2d b1ff8dfe6e48 c4b010d1d0e2 be8652e03b73"
cp fuentes/nk21.tsv $P/imports.tsv
for par in "v21x e19cfc6f86e3eed5ea52cc601d3e90d7b330b1e7730bef689b820287d54a6e1c v21y normal" \
           "v21x-prueba 905c12c55c42a950bbe2c0b8338a11fffacf6464c642ed52ce0b60022432dace v21y-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in $OBJ war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  h=$(for f in $OBJ; do sha256sum $E/$f | cut -c1-12; done | tr '\n' ' ')
  [ "$h" = "$BASEOBJ " ] || { echo "$N: los objetos de la base no son los de objetos_nk21.py: $h"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21y.py $v/war3map.j fuentes/nk21-j/glob.j fuentes/nk21-j/func.j fuentes/nk3d-cambios.tsv $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  for f in $OBJ; do cp fuentes/nk21-obj/$f $N/$f; done
  python3 -I scripts/imp_v21e.py $E/war3map.imp $N/war3map.imp $P/imports.tsv > /dev/null || exit 1
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; [ $k -gt 1 ] && rm -f -- $P/c$((k-1)).w3x; cur=$P/c$k.w3x; }
  for f in war3map.j $OBJ war3map.imp; do add $f $N/$f; done
  while IFS=$'\t' read -r n f; do add "$n" "$f"; done < $P/imports.tsv
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j $OBJ war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "$N: reextracción de $n distinta"; exit 1; }
  done < $P/imports.tsv
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.(j|w3u|w3a|w3h|w3b|imp)|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  echo "$N: $(grep -ci 'only in' $P/$N-diff.txt) líneas 'only in'"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
