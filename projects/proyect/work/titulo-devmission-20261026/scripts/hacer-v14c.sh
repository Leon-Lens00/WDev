#!/bin/bash
# v14c: v14b con la interfaz de la tienda en su sitio y los cambios de armas, oro y balas.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v14c-pack
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
R=v14c-recursos
mkdir -p v14c $R "$P"
python3 scripts/v14c.py v14b/war3map.j v14c/war3map.j || exit 1
$PJ v14c/war3map.j | tail -8 | tee /dev/stderr | grep -q 'Parse successful.*v14c/war3map.j' || { echo 'pJASS falló'; exit 1; }
python3 scripts/objetos_v14c.py v14a/obj/war3map.w3a v14c/war3map.w3a || exit 1
# Tamaños a la altura real: 1642 bajo el ojo.
python3 scripts/zona_clic.py v14a-recursos/ShopHitCat.mdx $R/ShopHitCat.mdx 38.5 211.5 14
python3 scripts/zona_clic.py v14a-recursos/ShopHitRow.mdx $R/ShopHitRow.mdx 34.8 383 14
python3 scripts/zona_clic.py v14a-recursos/ShopHitWide.mdx $R/ShopHitWide.mdx 38.5 424 14
python3 scripts/zona_clic.py v14a-recursos/ShopHitBtn.mdx $R/ShopHitBtn.mdx 38.5 227.6 14
python3 scripts/muerte_rapida.py v14a-recursos/ConoCuchillo.mdx $R/ConoCuchillo.mdx || exit 1
python3 scripts/muerte_rapida.py v14a-recursos/ShopPlano.mdx $R/ShopPlano.mdx || exit 1
cur=TerrainDev-Titulo-v14b.w3x; n=0
add() { n=$((n+1)); $W mpq add "$cur" "$1" --file "$2" -o "$P/$n.w3x" | tail -1 | grep -v round-trips; cur="$P/$n.w3x"; }
add war3map.j v14c/war3map.j
add war3map.w3a v14c/war3map.w3a
for x in ShopPlano ConoCuchillo ShopHitCat ShopHitRow ShopHitWide ShopHitBtn; do
    add "war3mapImported\\$x.mdx" "$R/$x.mdx"
done
cp "$cur" TerrainDev-Titulo-v14c.w3x
rm -f "$P"/*.w3x
$W mpq verify TerrainDev-Titulo-v14c.w3x | tail -1 | cut -c1-90
sha256sum TerrainDev-Titulo-v14c.w3x
