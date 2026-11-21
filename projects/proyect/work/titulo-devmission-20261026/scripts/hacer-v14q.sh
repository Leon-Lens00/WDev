#!/bin/bash
# v14q: alcance por tier, precarga en la pantalla de carga y cadáveres de las oleadas fuera a los 3,5 s (v14q.py,
# objetos_v14q.py, tabla en armas_v14q.py). Parte del mapa v14p.
# Variantes: v14q-prueba (directa) y v14q-prueba-intro para Leon; v14q-estres y v14p-estres (el mismo puente sobre v14p)
# para comparar cuadros con el rastreador.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14q; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14p.w3x
$W extract $B war3map.j -o $P/v14p-base.j > /dev/null && cmp -s $P/v14p-base.j v14p/war3map.j || { echo 'v14p/war3map.j no es el del mapa v14p'; exit 1; }
mkdir -p v14q/obj-in v14q-prueba v14q-prueba-intro v14q-estres v14p-estres
$W imports list $B > v14q/imports.txt || exit 1
$W extract $B war3map.w3a -o v14q/obj-in/war3map.w3a > /dev/null || exit 1
python3 -I scripts/objetos_v14q.py v14q/obj-in v14q/obj-out || exit 1
python3 -I scripts/v14q.py v14p/war3map.j v14q/war3map.j v14q/imports.txt || exit 1
python3 -I scripts/prueba_v14q.py v14q/war3map.j v14q-prueba/war3map.j directa || exit 1
python3 -I scripts/prueba_v14q.py v14q/war3map.j v14q-prueba-intro/war3map.j intro || exit 1
python3 -I scripts/prueba_v14q.py v14q/war3map.j v14q-estres/war3map.j estres qe || exit 1
python3 -I scripts/prueba_v14q.py v14p/war3map.j v14p-estres/war3map.j estres pe || exit 1
for f in v14q v14q-prueba v14q-prueba-intro v14q-estres v14p-estres; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; exit 1; }; done
for sal in v14q v14q-prueba v14q-prueba-intro v14q-estres v14p-estres; do
  lista=("war3map.j=$sal/war3map.j")
  [ $sal != v14p-estres ] && lista+=("war3map.w3a=v14q/obj-out/war3map.w3a")
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
sha256sum TerrainDev-Titulo-v14q.w3x TerrainDev-Titulo-v14q-prueba.w3x TerrainDev-Titulo-v14q-prueba-intro.w3x TerrainDev-Titulo-v14q-estres.w3x TerrainDev-Titulo-v14p-estres.w3x
