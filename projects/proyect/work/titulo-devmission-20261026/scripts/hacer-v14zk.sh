#!/bin/bash
# v14zk: fase 2 de docs/planes/devmission-armas-rachas-v14zj.md. Copias sin luz (sin_luz_v14zk.cjs) de los 58 efectos
# con luz de v14zj: Shot y Shot II, Firebrand Shot, Chain Grenade, Valiant Charge (dash), Windwalk, efectos del jefe
# (Flamestrike, SoulBeam, Spark y sus L/R) y RecargaRoja/RecargaVerde. Se quedan con luz StormLuz, BatLuz0..5 y el ciclo
# Dark Nights. El j es el de v14zj sin cambios. v14zk-prueba-noche: las de prueba_v14zk.py («-efectos»), de noche, registro en lat\v14zk-N.txt;
# v14zk-conluz: el mismo j de prueba sobre v14zj, con las luces, para comparar.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zk-hacer; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zj.w3x; L=sin-luz-v14zk
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v14zj/war3map.j || { echo 'v14zj/war3map.j no es el del mapa v14zj'; exit 1; }
# Los originales de sin-luz-v14zk/orig tienen que ser los del mapa v14zj, y cada copia sale de nuevo de ellos.
while IFS= read -r r; do
  $W extract $B "$r" -o $P/o.mdx > /dev/null && cmp -s $P/o.mdx "$L/orig/${r//\\//}" || { echo "original distinto: $r"; exit 1; }
  mkdir -p "$(dirname "$L/${r//\\//}")"; node scripts/sin_luz_v14zk.cjs "$L/orig/${r//\\//}" "$L/${r//\\//}" > /dev/null || exit 1
done < $L/lista.txt
mkdir -p v14zk v14zk-prueba-noche
cp v14zj/war3map.j v14zk/war3map.j
python3 -I scripts/prueba_v14zk.py v14zk/war3map.j v14zk-prueba-noche/war3map.j v14zk directa noche || exit 1
mkdir -p v14zk-conluz && cp v14zk-prueba-noche/war3map.j v14zk-conluz/war3map.j && sed -i 's/lat\\\\v14zk-/lat\\\\v14zk-conluz-/' v14zk-conluz/war3map.j
grep -ac 'v14zk-conluz-' v14zk-conluz/war3map.j | grep -qx 1 || { echo 'nombre del registro conluz'; exit 1; }
for f in v14zk v14zk-prueba-noche v14zk-conluz; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14zk v14zk-prueba-noche; do
  lista=("war3map.j=$sal/war3map.j")
  while IFS= read -r r; do lista+=("$r=$L/${r//\\//}"); done < $L/lista.txt
  cur=$B; n=0
  for e in "${lista[@]}"; do
    n=$((n+1)); $W mpq add "$cur" "${e%%=*}" --file "${e#*=}" -o "$P/$sal-$n.w3x" | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
    [ $n -gt 1 ] && rm -f "$cur"; cur="$P/$sal-$n.w3x"
  done
  cp "$cur" TerrainDev-Titulo-$sal.w3x; rm -f "${P:?}"/$sal-*.w3x
  for e in "${lista[@]}"; do
    $W extract TerrainDev-Titulo-$sal.w3x "${e%%=*}" -o $P/re > /dev/null && cmp -s $P/re "${e#*=}" || { echo "reextracción distinta: $sal ${e%%=*}"; exit 1; }
  done
  $W mpq verify TerrainDev-Titulo-$sal.w3x | tail -1 | cut -c1-90
done
# Sólo prueba A/B: el mismo j de prueba sobre el mapa v14zj, con las luces originales.
$W mpq add $B war3map.j --file v14zk-conluz/war3map.j -o TerrainDev-Titulo-v14zk-conluz.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
$W extract TerrainDev-Titulo-v14zk-conluz.w3x war3map.j -o $P/re > /dev/null && cmp -s $P/re v14zk-conluz/war3map.j || { echo 'reextracción distinta: conluz'; exit 1; }
sha256sum TerrainDev-Titulo-v14zk*.w3x
