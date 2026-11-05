#!/bin/bash
# v14a: v13m con armas, munición, oro, tienda del golem y diez rondas. Sin registros en el mapa.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14a-pack
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
mkdir -p v14a v14a/obj v14a/m13 "$P"
if [ ! -f v14a/m13/war3map.w3a ]; then
    $W mpq extract-all TerrainDev-Titulo-v13m.w3x -o v14a/ext >/dev/null || exit 1
    cp v14a/ext/war3map.w3a v14a/ext/war3map.w3b v14a/ext/war3map.imp v14a/m13/
    gio trash v14a/ext
fi
python3 scripts/v14a.py v13m/war3map.j v14a/war3map.j || exit 1
$PJ v14a/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14a/war3map.j' || { echo 'pJASS falló'; exit 1; }
python3 scripts/objetos_v14a.py v14a/m13 v14a/obj || exit 1
cur=TerrainDev-Titulo-v13m.w3x; n=0
add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$n.w3x"; }
add war3map.j v14a/war3map.j
for f in w3a w3b imp; do add war3map.$f v14a/obj/war3map.$f; done
TP=../tienda-prototipo-20261101/texturas
for x in ShopPanelL ShopPanelC ShopPanelR ShopWindow ShopCell ShopCatOn ShopCatOff ShopRowOn ShopRowOff ShopBtnOn ShopBtnOff ShopWide ShopGem Arma-pistola Arma-subfusil Arma-rifle Arma-francotirador Arma-escopeta Arma-melee Arma-granada; do
    add "war3mapImported\\$x.blp" "$TP/$x.blp"
done
for x in ShopGolem HudBlindaje ConoCuchillo BTNArma0 BTNArma1 BTNArma2 BTNArma3 BTNArma4 BTNArma5 BTNArma6; do
    add "war3mapImported\\$x.blp" "v14a-recursos/$x.blp"
done
for x in ShopPlano ConoCuchillo ShopHitCat ShopHitRow ShopHitWide ShopHitBtn; do
    add "war3mapImported\\$x.mdx" "v14a-recursos/$x.mdx"
done
cp "$cur" TerrainDev-Titulo-v14a.w3x
rm -f "$P"/*.w3x
$W mpq verify TerrainDev-Titulo-v14a.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14a.w3x
ls -la TerrainDev-Titulo-v14a.w3x | cut -c24-
