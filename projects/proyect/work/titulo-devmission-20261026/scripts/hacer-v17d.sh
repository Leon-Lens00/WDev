#!/bin/bash
# v17d (14/11/2026): v17c con sonidos de armas, impactos, explosión, cajas, tienda, cambio de arma y truenos (AudioClip).
# Sonidos: scripts/sonidos_v17d.py (dos veces, deben salir iguales); j: scripts/v17d.py.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
AC=/home/snz/Descargas/AudioClip
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v17d-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v17c.w3x; O=TerrainDev-Titulo-v17d.w3x
echo "24538466e58229f54647686abb3162aa4b5cf2a8a535d1f169e4288e883f426b  $B" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v17c/war3map.j || { echo "la base no coincide con v17c/war3map.j"; exit 1; }
python3 -I scripts/sonidos_v17d.py $AC $P/son > /dev/null || exit 1
python3 -I scripts/sonidos_v17d.py $AC $P/son2 > /dev/null || exit 1
(cd $P/son && sha256sum war3mapImported/*.wav) > $P/a.sum; (cd $P/son2 && sha256sum war3mapImported/*.wav) > $P/b.sum
cmp -s $P/a.sum $P/b.sum || { echo "los sonidos no salen iguales dos veces"; exit 1; }
mkdir -p v17d
python3 -I scripts/v17d.py v17c/war3map.j $P/son/lista.tsv v17d/war3map.j || exit 1
$PJ v17d/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v17d/war3map.j | tail -8; exit 1; }
cp $B $P/a.w3x
$W mpq add $P/a.w3x war3map.j --file v17d/war3map.j -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || exit 1
while IFS=$'\t' read -r n f; do
  $W mpq add $P/a.w3x "$n" --file "$f" -o $P/b.w3x > /dev/null && mv $P/b.w3x $P/a.w3x || { echo "no se pudo añadir $n"; exit 1; }
done < $P/son/lista.tsv
mv $P/a.w3x $O
# --- comprobación ---
$W extract $O war3map.j -o $P/re.j > /dev/null && cmp -s $P/re.j v17d/war3map.j || { echo "reextracción del j distinta"; exit 1; }
while IFS=$'\t' read -r n f; do
  $W extract $O "$n" -o $P/re.wav > /dev/null && cmp -s $P/re.wav "$f" || { echo "distinto: $n"; exit 1; }
done < $P/son/lista.tsv
echo "sonidos añadidos: $(wc -l < $P/son/lista.tsv)"
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
