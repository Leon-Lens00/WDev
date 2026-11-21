#!/bin/bash
# v17q (14/11/2026): v17p con la cabecera HM3W corregida (nombre "Proyect Dev Us" en la lista de mapas y marcas de
# fuerzas fijas): scripts/cabecera_v17q.py. El MPQ (byte 512 en adelante) es idéntico al de v17p.
# Salidas: TerrainDev-Titulo-v17q.w3x (normal) y TerrainDev-Titulo-v17q-prueba.w3x (con "-pres N").
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
for v in v17p v17p-prueba; do
  case $v in v17p) H=7d080a499dd031e3bd71adfbb26552102a7da087ff7e9f35ef114d42b4f2f52d;; *) H=7dac601fa2b4568a5f1c90dba3b9d40bee301fddfbd84079b5c89fa32962361e;; esac
  B=TerrainDev-Titulo-$v.w3x; N=${v/v17p/v17q}; O=TerrainDev-Titulo-$N.w3x
  echo "$H  $B" | sha256sum -c --quiet || exit 1
  python3 -I scripts/cabecera_v17q.py $B $O > /dev/null || exit 1
  cmp -s <(tail -c +513 $B) <(tail -c +513 $O) || { echo "$N: el MPQ cambió"; exit 1; }
  [ "$(head -c 22 $O | tail -c 14)" = "Proyect Dev Us" ] || { echo "$N: nombre"; exit 1; }
  echo "$N: cabecera nueva; MPQ idéntico a $v"
  $W mpq verify $O | tail -1 | cut -c1-90
  sha256sum $O
done
