#!/bin/bash
# v16t-don: trasplante fiel de las habilidades DBZ de Battle Stadium D.O.N 2.1a (Valkemiere) sobre v16t-dbz, en lugar
# de las recetas aproximadas de v16t-dbz1 (plan devmission-dbz-v16t.md, «Cambio de método»). Objetos completos
# (objetos_don.py: héroes, 110 habilidades con los ids de la fase 1, auxiliares, dummies y buffs), código
# (don_trasplante.py + don_v16t.py) y recursos (recursos_don.py, por hash MPQ). El movimiento aún es el de DON; el
# paso a Missile se hace después por personaje.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-don-hacer; mkdir -p $P
D=/home/snz/Documentos/ChatGPT/Proyect/work/battle-don-ref-20261112
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
I=TerrainDev-Titulo-v16t-ivan.w3x; B=TerrainDev-Titulo-v16t-dbz.w3x; O=TerrainDev-Titulo-v16t-don.w3x
echo "e2666e8b6b322d0acb176d76343ec5735f9b6486436d25a419b65a41662d152f  $D/descarga/BattlestadiumDON-2.1a.w3x" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t-dbz/war3map.j || { echo "v16t-dbz/war3map.j no es el del mapa v16t-dbz"; exit 1; }
for f in war3map.w3u war3map.w3a war3map.w3h; do $W extract $I $f -o $P/ivan-$f > /dev/null || exit 1; done
$W extract $B '(listfile)' -o $P/listfile.txt > /dev/null && tr 'A-Z' 'a-z' < $P/listfile.txt | tr -d '\r' > $P/lista.txt
[ -s $P/lista.txt ] || { echo "no se pudo listar $B"; exit 1; }
mkdir -p v16t-don
python3 -I scripts/objetos_don.py $D/extraido v16t-dbz/rawcodes.txt $P/ivan-war3map.w3u $P/ivan-war3map.w3a $P/ivan-war3map.w3h v16t-don/war3map.w3u v16t-don/war3map.w3a v16t-don/war3map.w3h v16t-don/rawcodes.txt || exit 1
python3 -I scripts/don_trasplante.py $D/extraido v16t-dbz/rawcodes.txt v16t-don/rawcodes.txt $P/glob.j $P/func.j || exit 1
python3 -I scripts/don_v16t.py v16t-dbz/war3map.j $P/glob.j $P/func.j v16t-don/war3map.j || exit 1
$PJ v16t-don/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-don/war3map.j | tail -8; exit 1; }
python3 -I scripts/recursos_don.py $D/descarga/BattlestadiumDON-2.1a.w3x $D/extraido $P/func.j v16t-don/war3map.w3u v16t-don/war3map.w3a v16t-don/war3map.w3h v16t-don/rawcodes.txt scripts/recursos_dbz.tsv $P/lista.txt v16t-don/recursos.tsv || exit 1
U=$D/extraido/todo/_unnamed
LISTA=("war3map.j|v16t-don/war3map.j" "war3map.w3u|v16t-don/war3map.w3u" "war3map.w3a|v16t-don/war3map.w3a" "war3map.w3h|v16t-don/war3map.w3h")
while IFS=$'\t' read -r nom blq; do LISTA+=("$nom|$U/$blq"); done < v16t-don/recursos.tsv
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
grep -q ", 0 only in A, $(( ${#LISTA[@]} - 4 )) only in B" $P/dif.txt || { echo "entradas inesperadas:"; grep 'only in' $P/dif.txt; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
