#!/bin/bash
# Compila aparte el conjunto minimo de WaveSys con Table y TimerUtils de TerrainDev, las que usa el mapa.
set -e
P=/home/snz/Documentos/ChatGPT/Proyect; M=$P/work/titulo-devmission-20261026; O=$M/v12m/wave; A=$P/WaveSys/src/WaveSysAnAI; S=$A/SwlsWave
F=$O/fuente.j
printf 'native UnitAlive takes unit id returns boolean\n' > $F
cat $P/TerrainDev/src/libraries/Table.j >> $F; printf '\n' >> $F
# TimerUtils del mapa no trae las etiquetas de depuracion de la de WaveSys: sustituto sin efecto.
python3 -I - $P/TerrainDev/src/libraries/TimerUtils.j >> $F <<'E1'
import sys
s = open(sys.argv[1], encoding='latin-1', newline='').read()
i = s.rindex('endlibrary')
print(s[:i] + """globals
    constant integer TIMER_DEBUG_TAG_WAVE_CORE = 6
endglobals
function SetTimerDebugTag takes timer t, integer tag returns nothing
endfunction
""" + s[i:])
E1
for f in $P/WaveSys/src/libraries/TerrainPathability.j \
  $P/WaveSys/src/Players/Config/AllianceConfig.j $S/SwlsWave.j $S/WaveSpawnFx.j $S/WaveOwnerPolicy.j $S/Config/WaveDifficulty.j \
  $A/AI/WaveAIProfiles.j $A/AI/WaveAI.j $M/scripts/oleada_v12m/DevWave.j; do cat "$f" >> $F; printf '\n' >> $F; done
cat >> $F <<'E2'
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
E2
[ ! -e $O/compilado.j ] || gio trash $O/compilado.j
python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py vjass $F $O/compilado.j
wc -l $O/compilado.j
