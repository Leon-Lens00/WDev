#!/bin/bash
# v17n (14/11/2026): v17m con la barra del jefe con porcentaje, rellenándose de derecha a izquierda y tapada en la
# presentación, y la vida de unidades, élites y jefes ×2 (el oro por muerte igual).
# Modelos: scripts/jefe_barras_v17n.py sobre los HealthJefe{n}.mdx de v17m (dos veces, iguales); objetos:
# scripts/objetos_v17n.py; j: scripts/v17n.py sobre los dos j de v17m (normal y prueba).
# Salidas: TerrainDev-Titulo-v17n.w3x (normal) y TerrainDev-Titulo-v17n-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17n-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P/base
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
echo "850568dcc6c8877a90a1e47ab21428d6011926404435b51c53a2b31a24b556a5  TerrainDev-Titulo-v17m.w3x" | sha256sum -c --quiet || exit 1
echo "c70f80e2201e6ddfba5e2e186fe33d1fe7f3362ca3cb69bbfa27e8d8021c6674  TerrainDev-Titulo-v17m-prueba.w3x" | sha256sum -c --quiet || exit 1
B=TerrainDev-Titulo-v17m.w3x
for c in 2 3 4 5 6 7 8 9 A; do
  $W extract $B "UI\\HealthBarsHorizontal\\HealthJefe$c.mdx" -o $P/base/HealthJefe$c.mdx > /dev/null || exit 1
done
python3 -I scripts/jefe_barras_v17n.py $P/base $P/mdx > /dev/null || exit 1
python3 -I scripts/jefe_barras_v17n.py $P/base $P/mdx2 > /dev/null || exit 1
(cd $P/mdx && sha256sum *.mdx) > $P/a.sum; (cd $P/mdx2 && sha256sum *.mdx) > $P/b.sum
cmp -s $P/a.sum $P/b.sum || { echo "los modelos no salen iguales dos veces"; exit 1; }
$W extract $B war3map.w3u -o $P/base/war3map.w3u > /dev/null || exit 1
mkdir -p $P/obj
python3 -I scripts/objetos_v17n.py $P/base/war3map.w3u $P/obj/war3map.w3u > $P/vida.json || exit 1
: > $P/lista.tsv
printf '%s\t%s\n' war3map.w3u $P/obj/war3map.w3u >> $P/lista.tsv
for f in $P/mdx/*.mdx; do printf 'UI\\HealthBarsHorizontal\\%s\t%s\n' "$(basename $f)" "$f" >> $P/lista.tsv; done
mkdir -p v17n v17n-prueba
for v in v17m v17m-prueba; do
  B=TerrainDev-Titulo-$v.w3x; N=${v/v17m/v17n}; O=TerrainDev-Titulo-$N.w3x
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v17n.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  cp $B $P/a.w3x
  $W mpq add $P/a.w3x war3map.j --file $N/war3map.j -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
  while IFS=$'\t' read -r n f; do
    $W mpq add $P/a.w3x "$n" --file "$f" -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $n"; exit 1; }
  done < $P/lista.tsv
  mv $P/a.w3x $O
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re.bin > /dev/null && cmp -s $P/re.bin "$f" || { echo "$N: distinto $n"; exit 1; }
  done < $P/lista.tsv
  for f in war3map.w3b war3map.imp war3map.w3q 'war3mapImported\PresJefe5.mdx'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: miembros reemplazados y reextraídos: $(( $(wc -l < $P/lista.tsv) + 1 ))"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
cat $P/vida.json
