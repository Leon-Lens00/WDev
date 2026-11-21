#!/bin/bash
# v17h (14/11/2026): v17g con la presentación del jefe de ronda antes de que aparezca.
# Texturas: scripts/recursos_v17h.py (dos veces, deben salir iguales); modelos: scripts/jefe_modelos_v17h.py sobre
# modelos/jefes-base-v17h (del juego, con SHA256SUMS); objetos: scripts/objetos_v17h.py; j: scripts/v17h.py.
# Salidas: TerrainDev-Titulo-v17h.w3x (normal) y TerrainDev-Titulo-v17h-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17h-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17g.w3x
echo "ddb7606c0d5fd0bce0606a7750d0c6a4b6ed3c8a35af9a7ac58d214cff1f0c3b  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17g/war3map.j || { echo "la base no coincide con v17g/war3map.j"; exit 1; }
(cd modelos/jefes-base-v17h && sha256sum -c --quiet SHA256SUMS) || exit 1
# --- recursos ---
$PY -I scripts/recursos_v17h.py $P/tex > /dev/null || exit 1
$PY -I scripts/recursos_v17h.py $P/tex2 > /dev/null || exit 1
(cd $P/tex && sha256sum *.blp) > $P/a.sum; (cd $P/tex2 && sha256sum *.blp) > $P/b.sum
cmp -s $P/a.sum $P/b.sum || { echo "las texturas no salen iguales dos veces"; exit 1; }
$PY -I scripts/jefe_modelos_v17h.py modelos/jefes-base-v17h $P/mdx 35 > $P/limites.json || exit 1
for f in war3map.w3u war3map.w3b war3map.imp; do $W extract $B $f -o $P/$f > /dev/null || exit 1; done
mkdir -p $P/obj
python3 -I scripts/objetos_v17h.py $P/war3map.w3b $P/obj/war3map.w3b $P/war3map.imp $P/obj/war3map.imp \
  $P/war3map.w3u $P/obj/war3map.w3u > /dev/null || exit 1
# --- j ---
mkdir -p v17h v17h-prueba
python3 -I scripts/v17h.py v17g/war3map.j $P/limites.json v17h/war3map.j v17h-prueba/war3map.j || exit 1
cp $P/limites.json v17h/limites-jefes.json
for f in v17h v17h-prueba; do
  $PJ $f/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ $f/war3map.j | tail -8; exit 1; }
done
# --- lista de miembros comunes ---
: > $P/lista.tsv
for f in war3map.w3u war3map.w3b war3map.imp; do printf '%s\t%s\n' $f $P/obj/$f >> $P/lista.tsv; done
for f in $P/tex/*.blp; do printf 'war3mapImported\\%s\t%s\n' "$(basename $f)" "$f" >> $P/lista.tsv; done
for f in $P/mdx/*.mdx; do printf 'war3mapImported\\%s\t%s\n' "$(basename $f)" "$f" >> $P/lista.tsv; done
for v in v17h v17h-prueba; do
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
  echo "$v: miembros añadidos y reextraídos: $(( $(wc -l < $P/lista.tsv) + 1 ))"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
