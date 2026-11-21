#!/bin/bash
# v20k-prueba (20/11/2026): las copias MvpFrenteTauren10/20/30 rehechas con el método del retrato (ayudante MvpVista).
# Sobre v20j-prueba. Cambian el j (prefijo de registros) y los tres MDX; w3u e imp iguales.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v20k-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
node scripts/mvp_frente.cjs mvp-incl/base/Tauren-war3.mpq.mdx $P/f0.mdx > /dev/null || exit 1
cmp -s $P/f0.mdx mvp-frente/MvpFrenteTauren.mdx || { echo "sin grados ya no coincide con v20i"; exit 1; }
for g in 10 20 30; do
  node scripts/mvp_frente.cjs mvp-incl/base/Tauren-war3.mpq.mdx $P/MvpFrenteTauren$g.mdx $g > /dev/null || exit 1
  cmp -s $P/MvpFrenteTauren$g.mdx mvp-frente/vista/MvpFrenteTauren$g.mdx || { echo "MvpFrenteTauren$g distinto"; exit 1; }
done
v=v20j-prueba; H=e91006810669ebfc38bb50f043a7773d02a2b429c9bcd36addff3c18b706a0c6; N=v20k-prueba
B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
echo "$H  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
python3 -I scripts/v20k.py $v/war3map.j $N/war3map.j prueba > /dev/null || exit 1
bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
cur=$B; k=0
add() { k=$((k+1)); $W mpq add $cur "$1" --file "$2" -o $P/c$k.w3x > /dev/null || exit 1; cur=$P/c$k.w3x; }
add war3map.j $N/war3map.j
for g in 10 20 30; do add "war3mapImported\\MvpFrenteTauren$g.mdx" mvp-frente/vista/MvpFrenteTauren$g.mdx; done
{ head -c 512 $B; tail -c +513 $cur; } > $O
[ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
for g in 10 20 30; do
  $W extract $O "war3mapImported\\MvpFrenteTauren$g.mdx" -o $P/re > /dev/null && cmp -s $P/re mvp-frente/vista/MvpFrenteTauren$g.mdx || { echo "$N: reextracción de MvpFrenteTauren$g distinta"; exit 1; }
done
$W mpq bytes-diff $B $O > $P/$N-diff.txt
D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
echo "$N: difieren $D"
grep -i 'only in' $P/$N-diff.txt
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
