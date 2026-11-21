#!/bin/bash
# v17b (14/11/2026): v17a con las mejoras de la rama de pruebas v16t (escopeta de 3 perdigones grandes y perforación,
# Shot / Shot II, relojes del HUD, reserva del reciclador 8 × 32, armas de antes) más balas ligeras por jugador (-bl) y
# ritmo -25 % en rps (v17b.py). Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v17a.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17b-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17a.w3x; O=TerrainDev-Titulo-v17b.w3x; R=TerrainDev-Titulo-v16t-reserva.w3x
TOY=../bench-misiles-toy-20261110/ToyBullet-Tier6-Lab-modelos.w3x
echo "a6193565fffbde592f7dcee89c7d130d458f455cb67cb4e74490366cf18513d5  $B" | sha256sum -c --quiet || exit 1
echo "a16fd9455dd90fd5d989bf293d0d3ac83f08ff965c95311e2151169f43b672f6  $R" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17a/war3map.j || { echo "la base no coincide con v17a/war3map.j"; exit 1; }
# --- j ---
python3 -I scripts/perfora_v16t.py v17a/war3map.j $P/1.j > /dev/null || exit 1
python3 -I scripts/shots_v16t.py $P/1.j $P/2.j > /dev/null || exit 1
python3 -I scripts/relojes_v16t.py $P/2.j $P/3.j > /dev/null || exit 1
python3 -I scripts/reserva32.py $P/3.j v13e/war3map.j $P/4.j > /dev/null || exit 1
python3 -I scripts/armas_antes.py $P/4.j v16t-corto/war3map.j $P/5.j > /dev/null || exit 1
mkdir -p v17b
python3 -I scripts/v17b.py $P/5.j v17b/war3map.j > $P/ritmo.txt || exit 1
$PJ v17b/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v17b/war3map.j | tail -8; exit 1; }
# --- modelos: escopeta grande (de v16t-reserva) y balas ligeras (Toy Bullet2 sin partículas, con color y tamaño) ---
: > $P/lista.tsv
for c in Blue Green Orange Pink Purple Red Silver Teal Yellow; do
  n="FirebrandShots\\Grande\\Firebrand Shot $c.mdx"; f="$P/grande-$c.mdx"
  $W extract $R "$n" -o "$f" > /dev/null || exit 1
  printf '%s\t%s\n' "$n" "$f" >> $P/lista.tsv
done
$W extract $TOY 'ToyBench\Bullet2.mdx' -o $P/Bullet2.mdx > /dev/null || exit 1
echo "e3c63cd55f4b82260c560774160c0a4f8c0dfd79b43ad604b6f1ff0a55005d03  $P/Bullet2.mdx" | sha256sum -c --quiet || exit 1
python3 -I scripts/bala_ligera.py $P/Bullet2.mdx $P/ligera1.mdx $P/ligera2.mdx > /dev/null || exit 1
case $P in /tmp/claude-1000/*) [ -d $P/lig ] && rm -rf -- $P/lig;; esac
python3 -I scripts/bala_ligera_tier.py $P/ligera1.mdx $P/lig || exit 1
for f in $P/lig/BalaLigera/*.mdx; do printf '%s\t%s\n' "BalaLigera\\$(basename $f)" "$f" >> $P/lista.tsv; done
cp $B $P/a.w3x
$W mpq add $P/a.w3x war3map.j --file v17b/war3map.j -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
while IFS=$'\t' read -r n f; do
  $W mpq add $P/a.w3x "$n" --file "$f" -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $n"; exit 1; }
done < $P/lista.tsv
mv $P/a.w3x $O
# --- comprobación ---
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v17b/war3map.j || { echo "reextracción del j distinta"; exit 1; }
while IFS=$'\t' read -r n f; do
  $W extract $O "$n" -o $P/re.mdx > /dev/null && cmp -s $P/re.mdx "$f" || { echo "distinto: $n"; exit 1; }
done < $P/lista.tsv
echo "modelos añadidos: $(wc -l < $P/lista.tsv)"
$W mpq bytes-diff $B $O | grep -m1 'DIFFERS\|identical'
$W mpq verify $O | tail -1 | cut -c1-90
cat $P/ritmo.txt
sha256sum $O
