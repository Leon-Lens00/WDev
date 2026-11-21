#!/bin/bash
# v17m (14/11/2026): v17l con el marcador (multiboard) oculto y la barra de vida del jefe a la derecha del HUD: entra al
# acabar la presentación, se carga y libera al jefe, muestra su vida y sale por la derecha al morir.
# Modelos: scripts/jefe_barras_v17m.py sobre HealthEnemyTauren.mdx y JefeIcono{n}.mdx del mapa (dos veces, iguales);
# objetos: scripts/objetos_v17m.py; j: scripts/v17m.py sobre los dos j de v17l (normal y prueba).
# Salidas: TerrainDev-Titulo-v17m.w3x (normal) y TerrainDev-Titulo-v17m-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17m-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P/base
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
echo "d86914c3faf6798d8bf92cba0911d2272a5a4cc813c69b6a32e9c706ccdfd896  TerrainDev-Titulo-v17l.w3x" | sha256sum -c --quiet || exit 1
echo "aa0cfcabea00c819a36d2fa3c1097a8ba4e2dd5c279799cb359fc4c9efe075d0  TerrainDev-Titulo-v17l-prueba.w3x" | sha256sum -c --quiet || exit 1
B=TerrainDev-Titulo-v17l.w3x
# --- modelos ---
$W extract $B 'UI\HealthBarsHorizontal\HealthEnemyTauren.mdx' -o $P/base/HealthEnemyTauren.mdx > /dev/null || exit 1
for c in 2 3 4 5 6 7 8 9 A; do
  $W extract $B "UI\\HealthBarsHorizontal\\JefeIcono$c.mdx" -o $P/base/JefeIcono$c.mdx > /dev/null || exit 1
done
python3 -I scripts/jefe_barras_v17m.py $P/base/HealthEnemyTauren.mdx $P/base $P/mdx > /dev/null || exit 1
python3 -I scripts/jefe_barras_v17m.py $P/base/HealthEnemyTauren.mdx $P/base $P/mdx2 > /dev/null || exit 1
(cd $P/mdx && sha256sum *.mdx) > $P/a.sum; (cd $P/mdx2 && sha256sum *.mdx) > $P/b.sum
cmp -s $P/a.sum $P/b.sum || { echo "los modelos no salen iguales dos veces"; exit 1; }
[ $(ls $P/mdx/*.mdx | wc -l) = 9 ] || { echo "faltan modelos"; exit 1; }
# --- objetos ---
for f in war3map.w3u war3map.imp; do $W extract $B $f -o $P/base/$f > /dev/null || exit 1; done
mkdir -p $P/obj
python3 -I scripts/objetos_v17m.py $P/base/war3map.w3u $P/obj/war3map.w3u $P/base/war3map.imp $P/obj/war3map.imp > /dev/null || exit 1
# --- lista de miembros ---
: > $P/lista.tsv
for f in war3map.w3u war3map.imp; do printf '%s\t%s\n' $f $P/obj/$f >> $P/lista.tsv; done
for f in $P/mdx/*.mdx; do printf 'UI\\HealthBarsHorizontal\\%s\t%s\n' "$(basename $f)" "$f" >> $P/lista.tsv; done
mkdir -p v17m v17m-prueba
for v in v17l v17l-prueba; do
  B=TerrainDev-Titulo-$v.w3x; N=${v/v17l/v17m}; O=TerrainDev-Titulo-$N.w3x
  $W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  python3 -I scripts/v17m.py $v/war3map.j $N/war3map.j > /dev/null || exit 1
  $PJ $N/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $N/war3map.j | tail -8; exit 1; }
  cp $B $P/a.w3x
  $W mpq add $P/a.w3x war3map.j --file $N/war3map.j -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
  while IFS=$'\t' read -r n f; do
    $W mpq add $P/a.w3x "$n" --file "$f" -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $n"; exit 1; }
  done < $P/lista.tsv
  mv $P/a.w3x $O
  # --- comprobación ---
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re.bin > /dev/null && cmp -s $P/re.bin "$f" || { echo "$N: distinto $n"; exit 1; }
  done < $P/lista.tsv
  for f in war3map.w3b war3map.w3a 'UI\HealthBarsHorizontal\HealthEnemyTauren.mdx' 'war3mapImported\PresJefe5.mdx' 'war3mapImported\JefeOscuro.blp'; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$N: cambió $f"; exit 1; }
  done
  echo "$N: miembros añadidos y reextraídos: $(( $(wc -l < $P/lista.tsv) + 1 ))"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
