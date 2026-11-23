#!/bin/bash
# v22e (23/11/2026): la R (y la W) de Vegito mandan "stop" a la copia al despausarla, y no se lanza dos veces;
# el retrato de Vegito sube 14 (retrato_vt22e.cjs). Normal sobre v22d; prueba sobre v22d-prueba.
# Cambian el j (v22e.py) y war3mapImported\Vegito21_portrait.mdx (fuentes/vt22e).
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v22e-hacer
case $P in /tmp/claude-1000/*) [ -d $P ] && rm -rf -- $P;; esac; mkdir -p $P
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
RET='war3mapImported\Vegito21_portrait.mdx'
mkdir -p fuentes/vt22e
node scripts/retrato_vt22e.cjs fuentes/vt21/war3mapImported/Vegito21_portrait.mdx fuentes/vt22e/Vegito21_portrait.mdx || exit 1
for par in "v22d 6cdee0e40d2fd25fce2d38f2310c2c2f8691ce08c6149a32e38f792ddf31c6d5 v22e normal" \
           "v22d-prueba 9983b5cc75cbae3d2487e6bf5df4ad84d687f0cbfa2cf000afd897da4f301f39 v22e-prueba prueba"; do
  set -- $par; v=$1; H=$2; N=$3; m=$4
  B=TerrainDev-Titulo-$v.w3x; O=TerrainDev-Titulo-$N.w3x; mkdir -p $N
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  $W extract $B war3map.j -o $P/base.j > /dev/null || exit 1
  cmp -s $P/base.j $v/war3map.j || { echo "la base no coincide con $v/war3map.j"; exit 1; }
  $W extract $B "$RET" -o $P/ret-base.mdx > /dev/null || exit 1
  cmp -s $P/ret-base.mdx fuentes/vt21/war3mapImported/Vegito21_portrait.mdx || { echo "$v: el retrato no es el de fuentes/vt21"; exit 1; }
  [ $m = normal ] && a= || a=$m
  python3 -I scripts/v22e.py $v/war3map.j $N/war3map.j $a > /dev/null || exit 1
  bash -c "$PJ $N/war3map.j" | tail -1 | grep -q '^Parse successful' || { bash -c "$PJ $N/war3map.j" | tail -8; exit 1; }
  $W mpq add $B war3map.j --file $N/war3map.j -o $P/c1.w3x > /dev/null || exit 1
  $W mpq add $P/c1.w3x "$RET" --file fuentes/vt22e/Vegito21_portrait.mdx -o $P/c2.w3x > /dev/null || exit 1
  { head -c 512 $B; tail -c +513 $P/c2.w3x; } > $O
  [ "$(head -c 512 $O | sha256sum)" = "$(head -c 512 $B | sha256sum)" ] || { echo "$N: cabecera"; exit 1; }
  $W extract $O war3map.j -o $P/re > /dev/null && cmp -s $P/re $N/war3map.j || { echo "$N: reextracción del j distinta"; exit 1; }
  $W extract $O "$RET" -o $P/re.mdx > /dev/null && cmp -s $P/re.mdx fuentes/vt22e/Vegito21_portrait.mdx || { echo "$N: reextracción del retrato distinta"; exit 1; }
  $W mpq bytes-diff $B $O > $P/$N-diff.txt
  D=$(sed -n '/^payloads that differ/,/^$/p' $P/$N-diff.txt | tail -n +2 | awk 'NF{print $1}' | sort | tr '\n' ' ')
  echo "$N: difieren $D"
  X=$(echo "$D" | tr ' ' '\n' | grep -vxE '\(attributes\)|\(listfile\)|war3map\.j|war3mapImported\\Vegito21_portrait\.mdx|')
  [ -z "$X" ] || { echo "$N: cambió algo más: $X"; cat $P/$N-diff.txt; exit 1; }
  grep -i 'only in' $P/$N-diff.txt
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
# copias en WOE (Maps/Test), comprobadas byte a byte
WOE=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-woe/pfx/drive_c/WarcraftIII/Maps/Test
for N in v22e v22e-prueba; do
  cp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && cmp TerrainDev-Titulo-$N.w3x $WOE/DevMission-$N.w3x && echo "WOE $N: copiado"
done
