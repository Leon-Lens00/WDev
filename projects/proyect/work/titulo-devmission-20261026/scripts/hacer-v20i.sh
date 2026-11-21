#!/bin/bash
# v20i-prueba (20/11/2026): modelos del MVP de frente (billboard, como el retrato de rachas). Sólo prueba.
# Sobre v20h-prueba. Cambian j, w3u e imp; añade los siete MvpFrente*.mdx (mvp-frente, mvp_frente.cjs).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20i-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B0=mvp-frente/base
while IFS='|' read -r f nom; do
  node scripts/mvp_frente.cjs "$f" $P/MvpFrente$nom.mdx > /dev/null || exit 1
  cmp -s $P/MvpFrente$nom.mdx mvp-frente/MvpFrente$nom.mdx || { echo "MvpFrente$nom distinto de mvp-frente"; exit 1; }
done <<FIN
mvp-incl/base/Tauren-war3.mpq.mdx|Tauren
$B0/Cairne-war3.mpq.mdx|Cairne
$B0/Goku_squished.mdx|Goku
$B0/Cooler4_squished.mdx|Freezer
$B0/Vegeta'sBody_squished.mdx|Trunks
$B0/Naruto (Sage Mode)_squished.mdx|Naruto
$B0/6-tail_Kyuubi2_squished.mdx|Kyuubi
FIN
for par in "v20h-prueba 6af059ed21bee6e2750b271dd8e8999cd551d1befc5b724ad7609a33da061ed0 v20i-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N; E=$P/$N-in; mkdir -p $E
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  for f in war3map.w3u war3map.imp; do $W extract $B $f -o $E/$f > /dev/null || exit 1; done
  python3 -I scripts/objetos_v20i.py $E $N > /dev/null || exit 1
  python3 -I scripts/v20i.py $v/war3map.j $N/war3map.j $m > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  cur=$B; k=0
  add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
  for f in war3map.j war3map.w3u war3map.imp; do add $f $N/$f; done
  for g in Tauren Cairne Goku Freezer Trunks Naruto Kyuubi; do add "war3mapImported\\MvpFrente$g.mdx" mvp-frente/MvpFrente$g.mdx; done
  { head -c 512 $B; tail -c +513 $cur; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  for f in war3map.j war3map.w3u war3map.imp; do
    $W extract $O $f -o $P/re > /dev/null && cmp -s $P/re $N/$f || { echo "$N: reextracción de $f distinta"; exit 1; }
  done
  for g in Tauren Cairne Goku Freezer Trunks Naruto Kyuubi; do
    $W extract $O "war3mapImported\\MvpFrente$g.mdx" -o $P/re > /dev/null && cmp -s $P/re mvp-frente/MvpFrente$g.mdx || { echo "$N: reextracción de MvpFrente$g distinta"; exit 1; }
  done
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"; grep -qxE '\(attributes\)( \(listfile\))? war3map.imp war3map.j war3map.w3u' <<< "${D% }" || { echo "$N: cambió algo más: $D"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
