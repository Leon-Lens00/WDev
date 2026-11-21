#!/bin/bash
# v16t-ivan: v16t más Ivan, Arch Sage de Twilight's Eve Final R4.13a (Donach & KryptonRazer), para la prueba privada
# de Leon, sin tutorial (pertenece al modo de armas). Tiempos de la definitiva: [AF] Final (ver ivan.j). Objetos (objetos_ivan.py), JASS (ivan.j vía ivan_v16t.py), los 8 modelos de la definitiva y las 3 texturas
# de la Tierra sacados del mapa original (Proyect/work/twilights-eve-ref-20261112/tevef). No sustituye a v16t.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16t-ivan-hacer; mkdir -p $P
TE=/home/snz/Documentos/ChatGPT/Proyect/work/twilights-eve-ref-20261112/tevef
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16t.w3x; O=TerrainDev-Titulo-v16t-ivan.w3x
echo "d5e68eda56a63b1e55b716f3d71beaf06af410af0976db61f53fe4ef130ffb56  $TE/descarga/TwilightsEveFinal-R4.13a.w3x" | sha256sum -c --quiet || exit 1
$W extract $B war3map.j -o $P/base.j > /dev/null && cmp -s $P/base.j v16t/war3map.j || { echo "v16t/war3map.j no es el del mapa v16t"; exit 1; }
for f in war3map.w3u war3map.w3a war3mapMisc.txt; do $W extract $B $f -o $P/base-$f > /dev/null || exit 1; done
mkdir -p v16t-ivan
python3 -I scripts/objetos_ivan.py $TE/extraido/war3map.w3u $TE/extraido/war3map.w3a $P/base-war3map.w3u $P/base-war3map.w3a v16t-ivan/war3map.w3u v16t-ivan/war3map.w3a > /dev/null || exit 1
# 12/11/2026, Leon (como Battle Stadium D.O.N): velocidad mínima 50 para que la cámara lenta de la definitiva no pare a nadie.
python3 -I -c "import sys; b=open(sys.argv[1],'rb').read(); assert b'MinUnitSpeed' not in b and b.count(b'[Misc]\n')==1; open(sys.argv[2],'wb').write(b.replace(b'[Misc]\n', b'[Misc]\nMinUnitSpeed=50.0\n'))" $P/base-war3mapMisc.txt v16t-ivan/war3mapMisc.txt || exit 1
python3 -I scripts/efectos_ivan.py $TE/modelos-definitiva/earthLOW.mdx efectos-ivan/earthLOW.mdx > /dev/null || exit 1
python3 -I scripts/ivan_v16t.py v16t/war3map.j scripts/ivan.j v16t-ivan/war3map.j || exit 1
$PJ v16t-ivan/war3map.j | tail -1 | grep -q '^Parse successful' || { $PJ v16t-ivan/war3map.j | tail -5; exit 1; }
# Origen de cada import: modelos por su nombre interno MODL; texturas de la Tierra por inspección visual (block_187 el
# mapa del mundo; 183 y 184 las nubes, asignadas por orden alfabético de importación).
M=$TE/modelos-definitiva; U=$TE/extraido/_unnamed
LISTA=(
  "war3map.j|v16t-ivan/war3map.j" "war3map.w3u|v16t-ivan/war3map.w3u" "war3map.w3a|v16t-ivan/war3map.w3a" "war3mapMisc.txt|v16t-ivan/war3mapMisc.txt"
  "war3mapImported\\EmpyreanSigil.mdx|$M/EmpyreanSigil.mdx" "war3mapImported\\ExplosionBIG.mdx|$M/ExplosionBIG.mdx"
  "war3mapImported\\Great Lightning.mdx|$M/Great Lightning.mdx" "war3mapImported\\LaserStrike.mdx|$M/LaserStrike.mdx"
  "war3mapImported\\Lightnings.mdx|$M/Lightnings.mdx" "war3mapImported\\NewMassiveEX.mdx|$M/NewMassiveEX.mdx"
  "war3mapImported\\NuclearExplosion.mdx|$M/NuclearExplosion.mdx" "war3mapImported\\earthLOW.mdx|efectos-ivan/earthLOW.mdx"
  "Textures\\EarthMapLow.blp|$U/block_187.blp" "Textures\\CloudMap2Low.blp|$U/block_183.blp" "Textures\\CloudMapLow.blp|$U/block_184.blp"
)
cur=$B; n=0
for e in "${LISTA[@]}"; do
  n=$((n+1)); nom=${e%%|*}; f=${e#*|}
  $W mpq add "$cur" "$nom" --file "$f" -o $P/paso-$n.w3x | tail -1 | grep -v 'round-trips\|^Added\|^Replaced'
  cur=$P/paso-$n.w3x
done
cp $cur $O
for e in "${LISTA[@]}"; do
  nom=${e%%|*}; f=${e#*|}
  $W extract $O "$nom" -o $P/re > /dev/null && cmp -s $P/re "$f" || { echo "reextracción distinta: $nom"; exit 1; }
done
$W mpq bytes-diff $B $O > $P/dif.txt
grep -q ', 0 only in A, 11 only in B' $P/dif.txt || { echo "entradas inesperadas:"; grep 'only in' $P/dif.txt; exit 1; }
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
