#!/bin/bash
# Sólo prueba (14/11/2026): bala Toy y versiones ligeras (ligera_v16t.py, bala_ligera.py), sobre v16t-reserva con armas
# de antes y reserva 512. No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/ligera-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
v=v16t-reserva; B=TerrainDev-Titulo-$v.w3x; TOY=../bench-misiles-toy-20261110/ToyBullet-Tier6-Lab-modelos.w3x
echo "a16fd9455dd90fd5d989bf293d0d3ac83f08ff965c95311e2151169f43b672f6  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base $v/war3map.j || { echo "$v/war3map.j no es el del mapa"; exit 1; }
$W extract $TOY 'ToyBench\Bullet2.mdx' -o $P/Bullet2.mdx > /dev/null || exit 1
echo "e3c63cd55f4b82260c560774160c0a4f8c0dfd79b43ad604b6f1ff0a55005d03  $P/Bullet2.mdx" | sha256sum -c --quiet || exit 1
python3 -I scripts/bala_ligera.py $P/Bullet2.mdx $P/BalaLigera1.mdx $P/BalaLigera2.mdx || exit 1
cp $P/Bullet2.mdx $P/BalaToy.mdx
python3 -I scripts/armas_antes.py $v/war3map.j v16t-corto/war3map.j $P/armas.j > /dev/null || exit 1
python3 -I scripts/estres_v16t.py $P/armas.j $P/estres.j 6 > /dev/null || exit 1
python3 -I scripts/camara_v16t.py $P/estres.j $P/camara.j > /dev/null || exit 1
sal=v16t-reserva-lig; O=TerrainDev-Titulo-$sal.w3x; mkdir -p $sal
python3 -I scripts/ligera_v16t.py $P/camara.j $sal/war3map.j || exit 1
$PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
$W mpq add $B war3map.j --file $sal/war3map.j -o $P/a.w3x | tail -1
for f in BalaToy BalaLigera1 BalaLigera2; do
  $W mpq add $P/a.w3x "war3mapImported\\$f.mdx" --file $P/$f.mdx -o $P/b.w3x | tail -1 && mv $P/b.w3x $P/a.w3x
done
mv $P/a.w3x $O
$W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
for f in BalaToy BalaLigera1 BalaLigera2; do
  $W extract $O "war3mapImported\\$f.mdx" -o $P/re.mdx > /dev/null && cmp -s $P/re.mdx $P/$f.mdx || { echo "$f distinto"; exit 1; }
done
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
