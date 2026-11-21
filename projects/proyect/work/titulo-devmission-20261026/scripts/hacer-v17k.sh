#!/bin/bash
# v17k (14/11/2026): v17j con el fondo al 80 % (y los textos y barras tapados igual), la banda del nombre larga como en
# el vídeo, nombres más grandes y el Mur'gul Snarecaster al 75 % (su ataque salta y se cortaba arriba).
# Texturas: scripts/recursos_v17k.py (dos veces, deben salir iguales); j: scripts/v17k.py sobre los dos j de v17j (la
# normal y la de prueba). Objetos y modelos los de v17h (ya en el mapa base): sólo se reemplazan el j y las 18 texturas.
# Salidas: TerrainDev-Titulo-v17k.w3x (normal) y TerrainDev-Titulo-v17k-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17k-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17j.w3x
echo "350c9dcc5ece85f41b9540df09e2229976475b5a85e5910b3c6789933806bbb1  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17j/war3map.j || { echo "la base no coincide con v17j/war3map.j"; exit 1; }
echo "e0dc7b1c31413379b7fb3f22e15345bc988efe450ddb0c31655ac4135cd40fd3  TerrainDev-Titulo-v17j-prueba.w3x" | sha256sum -c --quiet || exit 1
$W extract TerrainDev-Titulo-v17j-prueba.w3x war3map.j -o $P/basep.j > /dev/null && cmp -s $P/basep.j v17j-prueba/war3map.j || { echo "la prueba no coincide con v17j-prueba/war3map.j"; exit 1; }
sha256sum -c --quiet <<< "0d5a507c9c133f682f6278d972c881b6f97cf9a7235225b94c77921d213bf7e9  fuentes/presentacion/jefe/warning-mediana.png" || exit 1
# --- recursos ---
$PY -I scripts/recursos_v17k.py $P/tex > /dev/null || exit 1
$PY -I scripts/recursos_v17k.py $P/tex2 > /dev/null || exit 1
(cd $P/tex && sha256sum *.blp) > $P/a.sum; (cd $P/tex2 && sha256sum *.blp) > $P/b.sum
cmp -s $P/a.sum $P/b.sum || { echo "las texturas no salen iguales dos veces"; exit 1; }
[ $(ls $P/tex/*.blp | wc -l) = 18 ] || { echo "faltan texturas"; exit 1; }
# --- j ---
mkdir -p v17k v17k-prueba
python3 -I scripts/v17k.py v17j/war3map.j v17k/war3map.j > /dev/null || exit 1
python3 -I scripts/v17k.py v17j-prueba/war3map.j v17k-prueba/war3map.j > /dev/null || exit 1
for f in v17k v17k-prueba; do
  $PJ $f/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $f/war3map.j | tail -8; exit 1; }
done
# --- miembros: las texturas existen ya en la base con la misma ruta ---
: > $P/lista.tsv
for f in $P/tex/*.blp; do
  n="war3mapImported\\$(basename $f)"
  $W extract $B "$n" -o $P/viejo.blp > /dev/null || { echo "no está en la base: $n"; exit 1; }
  printf '%s\t%s\n' "$n" "$f" >> $P/lista.tsv
done
for v in v17k v17k-prueba; do
  O=TerrainDev-Titulo-$v.w3x
  cp $B $P/a.w3x
  $W mpq add $P/a.w3x war3map.j --file $v/war3map.j -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
  while IFS=$'\t' read -r n f; do
    $W mpq add $P/a.w3x "$n" --file "$f" -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $n"; exit 1; }
  done < $P/lista.tsv
  mv $P/a.w3x $O
  # --- comprobación ---
  $W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j $v/war3map.j || { echo "$v: reextracción del j distinta"; exit 1; }
  while IFS=$'\t' read -r n f; do
    $W extract $O "$n" -o $P/re.bin > /dev/null && cmp -s $P/re.bin "$f" || { echo "$v: distinto $n"; exit 1; }
  done < $P/lista.tsv
  for f in war3map.w3u war3map.w3b war3map.imp war3mapImported\\PresJefe2.mdx; do
    $W extract $B "$f" -o $P/x1 > /dev/null; $W extract $O "$f" -o $P/x2 > /dev/null
    cmp -s $P/x1 $P/x2 || { echo "$v: cambió $f"; exit 1; }
  done
  echo "$v: miembros reemplazados y reextraídos: $(( $(wc -l < $P/lista.tsv) + 1 ))"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
