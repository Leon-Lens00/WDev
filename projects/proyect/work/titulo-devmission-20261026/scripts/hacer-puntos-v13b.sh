#!/bin/bash
# Mapa editable para colocar marcadores nPto: parte del mapa fuente y cambia solo lo que hay en puntos/datos.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
A=${1:?falta copia del mapa fuente}; S=puntos/Swamped-Puntos.w3x; o=puntos/tmp
cp "$A" $o.0
for n in war3map.w3u war3map.w3i war3map.doo war3mapUnits.doo war3map.imp war3map.w3r; do
 $W mpq add $o.0 $n --file puntos/datos/$n -o $o.1 > /dev/null || exit 2; mv $o.1 $o.0
done
$W mpq remove $o.0 'war3mapImported\KoboldDigger.mdx' -o $o.1 | tail -1 | cut -c1-90
mv $o.1 $S; gio trash $o.0
$W mpq verify $S | tail -1 | cut -c1-90; $W mpq listfile $S | tail -3 | cut -c1-90; sha256sum $S
