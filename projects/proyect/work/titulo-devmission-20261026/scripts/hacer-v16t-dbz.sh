#!/bin/bash
# v16t-dbz: v16t-ivan más los 16 personajes DBZ de Battle Stadium D.O.N 2.1a (Valkemiere), para la prueba privada de
# Leon. Fase 1 (devmission-dbz-v16t.md): selección al entrar (-dbz), modelos, iconos, texturas y habilidades de DON con
# rawcodes nuevos (objetos_dbz.py), misiones de créditos (dbz.j vía dbz_v16t.py). No sustituye a v16t ni a v16t-ivan.
# Los recursos salen de los bloques sin nombre de DON (todo/_unnamed), resueltos por hash MPQ en recursos_dbz.tsv
# (recursos_dbz.py, mpqhash.py).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-dbz-hacer; mkdir -p $P
D=/home/snz/Documentos/ChatGPT/Proyect/work/battle-don-ref-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t-ivan.w3x; O=TerrainDev-Titulo-v16t-dbz.w3x
echo "e2666e8b6b322d0acb176d76343ec5735f9b6486436d25a419b65a41662d152f  $D/descarga/BattlestadiumDON-2.1a.w3x" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t-ivan/war3map.j || { echo "v16t-ivan/war3map.j no es el del mapa v16t-ivan"; exit 1; }
for f in war3map.w3u war3map.w3a; do $W extract $B $f -o $P/base-$f > /dev/null || exit 1; done
mkdir -p v16t-dbz
python3 -I scripts/objetos_dbz.py $D/extraido/war3map.w3u $D/extraido/war3map.w3a $D/extraido/war3map.wts $P/base-war3map.w3u $P/base-war3map.w3a v16t-dbz/war3map.w3u v16t-dbz/war3map.w3a v16t-dbz/rawcodes.txt || exit 1
python3 -I scripts/dbz_v16t.py v16t-ivan/war3map.j scripts/dbz.j v16t-dbz/war3map.j || exit 1
$PJ v16t-dbz/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-dbz/war3map.j | tail -5; exit 1; }
U=$D/extraido/todo/_unnamed
LISTA=("war3map.j|v16t-dbz/war3map.j" "war3map.w3u|v16t-dbz/war3map.w3u" "war3map.w3a|v16t-dbz/war3map.w3a")
while IFS=$'\t' read -r nom blq; do LISTA+=("$nom|$U/$blq"); done < scripts/recursos_dbz.tsv
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
grep -q ", 0 only in A, $(( ${#LISTA[@]} - 3 )) only in B" $P/dif.txt || { echo "entradas inesperadas:"; grep 'only in' $P/dif.txt; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
