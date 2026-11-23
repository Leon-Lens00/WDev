#!/bin/bash
# v21e (22/11/2026): Goku de D.O.N 2.1a (fase 2 del rework) y sonidos 3D de los personajes D.O.N.
# Normal sobre v21d; prueba sobre v21d-prueba. Cambian el j (v21e.py), w3u/w3a/w3h/w3b (objetos_goku21.py, guardados en
# fuentes/goku21-obj), el imp, 108 recursos de 2.1a (recursos_goku21.py, fuentes/goku21.tsv) y 11 sonidos mono
# (sonidos_don3d.py, fuentes/don3d.tsv). El código trasplantado está en fuentes/goku21-j (goku21_trasplante.py +
# don_misil.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v21e-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
OBJ="war3map.w3u war3map.w3a war3map.w3h war3map.w3b"
# objetos de entrada de objetos_goku21.py (los de v21c = v21d)
BASEOBJ="bc2cda1f9433 092d6d7ba1bc d045101fc6c9 fe04c52ed020"
cat fuentes/goku21.tsv fuentes/don3d.tsv > $P/imports.tsv
for par in "v21d 23b5bcbe10a13faa1e4fb63dc1f08efcb030a7a8c9e873ae3a4efe3a011deeba v21e normal" \
           "v21d-prueba 3f3d0cc4326b83317a0fe2b4e988ab62a5aa066b4a2602dc190bb71f45d49f5d v21e-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in $OBJ war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  h=$(for f in $OBJ; do sha256sum $E/$f | cut -c1-12; done | tr '\n' ' ')
  [ "$h" = "$BASEOBJ " ] || { echo "$N: los objetos de la base no son los de objetos_goku21.py: $h"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v21e.py $v/war3map.j fuentes/goku21-j/glob.j fuentes/goku21-j/func.j fuentes/don3d-cambios.tsv $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  for f in $OBJ; do cp fuentes/goku21-obj/$f $N/$f; done
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
