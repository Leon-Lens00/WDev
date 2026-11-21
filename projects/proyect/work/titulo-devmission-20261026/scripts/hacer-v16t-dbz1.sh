#!/bin/bash
# v16t-dbz1: v16t-dbz más la tanda 1 de habilidades DBZ (Goku y Vegeta) rehechas sobre nuestro Missile (dbz_t1.j vía
# dbz_t1.py; plan devmission-dbz-v16t.md). Importa los modelos, texturas y sonidos de la tanda (recursos_dbz_t1.tsv,
# bloques sin nombre de Battle Stadium D.O.N 2.1a resueltos por hash MPQ). NuclearExplosion.mdx ya estaba en el mapa.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-dbz1-hacer; mkdir -p $P
D=/home/snz/Documentos/ChatGPT/Proyect/work/battle-don-ref-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-dbz.w3x; O=TerrainDev-Titulo-v16t-dbz1.w3x
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t-dbz/war3map.j || { echo "v16t-dbz/war3map.j no es el del mapa v16t-dbz"; exit 1; }
mkdir -p v16t-dbz1
python3 -I scripts/dbz_t1.py v16t-dbz/war3map.j scripts/dbz_t1.j v16t-dbz1/war3map.j || exit 1
$PJ v16t-dbz1/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-dbz1/war3map.j | tail -8; exit 1; }
U=$D/extraido/todo/_unnamed
LISTA=("war3map.j|v16t-dbz1/war3map.j")
while IFS=$'\t' read -r nom blq; do LISTA+=("$nom|$U/$blq"); done < scripts/recursos_dbz_t1.tsv
cur=$B; n=0
for e in "${LISTA[@]}"; do
  n=$((n+1)); nom=${e%%|*}; f=${e#*|}
  [ -f "$f" ] || { echo "falta $f"; exit 1; }
  $W mpq add "$cur" "$nom" --file "$f" -o $P/paso-$((n % 2)).w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cur=$P/paso-$((n % 2)).w3x
done
cp $cur $O
for e in "${LISTA[@]}"; do
  nom=${e%%|*}; f=${e#*|}
  $W extract $O "$nom" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "reextracción distinta: $nom"; exit 1; }
done
$W mpq bytes-diff $B $O > $P/dif.txt
grep -q ", 0 only in A, $(( ${#LISTA[@]} - 1 )) only in B" $P/dif.txt || { echo "entradas inesperadas:"; grep 'only in' $P/dif.txt; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
