#!/bin/bash
# Sólo prueba (14/11/2026): qué parte de la bala cuesta dibujar (dibujo_v16t.py), sobre v16t-reserva con armas de antes
# y reserva 512. Dos mapas: dummy normal (dib) y dummy plano sin animación de hueso (dibp). No se entrega.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/dibujo-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
v=v16t-reserva; B=TerrainDev-Titulo-$v.w3x
echo "a16fd9455dd90fd5d989bf293d0d3ac83f08ff965c95311e2151169f43b672f6  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base $v/war3map.j || { echo "$v/war3map.j no es el del mapa"; exit 1; }
python3 -I scripts/armas_antes.py $v/war3map.j v16t-corto/war3map.j $P/armas.j > /dev/null || exit 1
python3 -I scripts/estres_v16t.py $P/armas.j $P/estres.j 6 > /dev/null || exit 1
python3 -I scripts/camara_v16t.py $P/estres.j $P/camara.j > /dev/null || exit 1
D='war3mapImported\dummy.mdx'
$W extract $B "$D" -o $P/dummy.mdx > /dev/null || exit 1
python3 -I scripts/dummy_plano.py $P/dummy.mdx $P/dummy-plano.mdx || exit 1
for pre in dib dibp; do
  sal=v16t-reserva-$pre; O=TerrainDev-Titulo-$sal.w3x; mkdir -p $sal
  python3 -I scripts/dibujo_v16t.py $P/camara.j $sal/war3map.j $pre || exit 1
  $PJ $sal/war3map.j | tail -1 | grep -q "Parse successful" || { $PJ $sal/war3map.j | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $sal/war3map.j -o $O | tail -1
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $sal/war3map.j || { echo "reextracción distinta"; exit 1; }
  if [ $pre = dibp ]; then
    $W mpq add $O "$D" --file $P/dummy-plano.mdx -o $P/plano.w3x | tail -1 && mv $P/plano.w3x $O
    $W extract $O "$D" -o $P/re.mdx > /dev/null && cmp -s $P/re.mdx $P/dummy-plano.mdx || { echo "dummy plano distinto"; exit 1; }
  fi
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
