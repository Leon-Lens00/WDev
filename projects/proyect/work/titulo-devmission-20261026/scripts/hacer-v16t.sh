#!/bin/bash
# v16t: v16s con los 6 Firebrand Shot de la escopeta ligeros (efectos_v16t.cjs: partículas a 1/4, estela más corta).
# El j no cambia. También v16t-prueba, y v16t-perfil y v16t-estres-spas (los j de prueba de v16s sobre los modelos nuevos).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for sal in v16s v16s-prueba v16s-perfil v16s-estres-spas; do
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/base > /dev/null && cmp -s $P/base $sal/war3map.j || { echo "$sal/war3map.j no es el del mapa $sal"; exit 1; }
done
node scripts/efectos_v16t.cjs sin-luz-v14zk/FirebrandShots efectos-v16t > /dev/null || exit 1
for c in Yellow Green Teal Blue Purple Red; do
  $W extract TerrainDev-Titulo-v16s.w3x "FirebrandShots\\Firebrand Shot $c.mdx" -o $P/o.mdx > /dev/null
  cmp -s $P/o.mdx "sin-luz-v14zk/FirebrandShots/Firebrand Shot $c.mdx" || { echo "el $c del mapa no es el de sin-luz-v14zk"; exit 1; }
done
mkdir -p v16t v16t-prueba
cp v16s/war3map.j v16t/war3map.j
sed 's/lat\\\\v16s-/lat\\\\v16t-/' v16s-prueba/war3map.j > v16t-prueba/war3map.j
for par in "v16t v16s v16t" "v16t-prueba v16s-prueba v16t-prueba" "v16t-perfil v16s v16s-perfil" "v16t-estres-spas v16s v16s-estres-spas"; do
  set -- $par; sal=$1; cur=TerrainDev-Titulo-$2.w3x; j=$3/war3map.j; n=0
  for e in "war3map.j=$j" Yellow Green Teal Blue Purple Red; do
    n=$((n+1))
    if [ $n = 1 ]; then nom=war3map.j; f=$j; else nom="FirebrandShots\\Firebrand Shot $e.mdx"; f="efectos-v16t/Firebrand Shot $e.mdx"; fi
    $W mpq add "$cur" "$nom" --file "$f" -o $P/$sal-$n.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
    cur=$P/$sal-$n.w3x
  done
  cp $cur TerrainDev-Titulo-$sal.w3x
  $W extract TerrainDev-Titulo-$sal.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re $j || { echo "reextracción del j distinta: $sal"; exit 1; }
  for c in Yellow Green Teal Blue Purple Red; do
    $W extract TerrainDev-Titulo-$sal.w3x "FirebrandShots\\Firebrand Shot $c.mdx" -o $P/re > /dev/null && cmp -s $P/re "efectos-v16t/Firebrand Shot $c.mdx" || { echo "reextracción distinta: $sal $c"; exit 1; }
  done
  $W mpq bytes-diff TerrainDev-Titulo-$2.w3x TerrainDev-Titulo-$sal.w3x > $P/dif.txt
  grep -q ', 0 only in A, 0 only in B' $P/dif.txt || { echo "entradas añadidas o quitadas en $sal"; exit 1; }
  echo "$sal: distintos $(grep -A12 'payloads that differ' $P/dif.txt | grep '^  ' | awk '{print $1, $2, $3, $4}' | tr '\n' ';')"
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
sha256sum TerrainDev-Titulo-v16t*.w3x
