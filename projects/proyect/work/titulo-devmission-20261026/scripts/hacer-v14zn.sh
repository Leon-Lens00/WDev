#!/bin/bash
# v14zn: fase 5 de docs/planes/devmission-armas-rachas-v14zj.md (misil de calor). Del mapa v14zm cambian war3map.j
# (v14zn.py), war3map.w3a, war3map.w3b y war3map.imp (objetos_v14zn.py: Aw00 «Misiles», foto 'DS17'), y se añaden los
# 6 modelos de efectos_v14zn.cjs (Interceptor Shell de Vinz por tier, sin luz) y las 2 imágenes de iconos_v14zn.py.
# v14zn-prueba-dia: las de prueba_v14zn.py («-misil T», «-tiro D», «-lluvia N», registro de misiles), de día, registro
# en lat\v14zn-N.txt.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
PY=/home/snz/Documentos/ChatGPT/Proyect/work/shots-vol-i-origen-20261022/plot-env/bin/python
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14zn-hacer; mkdir -p $P/obj
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v14zm.w3x
$W extract $B war3map.j -o $P/base > /dev/null && cmp -s $P/base v14zm/war3map.j || { echo "v14zm/war3map.j no es el del mapa v14zm"; exit 1; }
for f in war3map.w3a war3map.w3b war3map.imp; do
  $W extract $B $f -o $P/obj/$f > /dev/null || { echo "no sale $f de v14zm"; exit 1; }
done
node scripts/efectos_v14zn.cjs > /dev/null || exit 1
$PY -I scripts/iconos_v14zn.py > /dev/null || exit 1
mkdir -p v14zn v14zn-prueba-dia
python3 -I scripts/objetos_v14zn.py $P/obj v14zn || exit 1
python3 -I scripts/v14zn.py v14zm/war3map.j v14zn/war3map.j || exit 1
python3 -I scripts/prueba_v14zn.py v14zn/war3map.j v14zn-prueba-dia/war3map.j directa dia || exit 1
for f in v14zn v14zn-prueba-dia; do $PJ $f/war3map.j | tail -1 | grep -q "Parse successful" || { echo "pJASS falló en $f"; $PJ $f/war3map.j | tail -5; exit 1; }; done
imp=("war3map.w3a=v14zn/war3map.w3a" "war3map.w3b=v14zn/war3map.w3b" "war3map.imp=v14zn/war3map.imp"
     "war3mapImported\\Arma-misil.blp=misil-v14zn/Arma-misil.blp" "war3mapImported\\BTNMisil.blp=misil-v14zn/BTNMisil.blp")
for t in 1 2 3 4 5 6; do imp+=("war3mapImported\\InterceptorShell$t.mdx=misil-v14zn/InterceptorShell$t.mdx"); done
for sal in v14zn v14zn-prueba-dia; do
  lista=("war3map.j=$sal/war3map.j" "${imp[@]}")
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
sha256sum TerrainDev-Titulo-v14zn*.w3x
