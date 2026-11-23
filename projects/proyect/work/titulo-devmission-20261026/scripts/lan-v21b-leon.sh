#!/bin/bash
# LAN de la copia de Leon v21b (rojo y amarillo; azul, verde azulado y morado cerrados; héroes fijos: rojo Tauren, amarillo Freezer) para jugarla Leon: ydhost y dos clientes (A en el espacio 6, B en el 7 del HDMI-A-1),
# mapa v21b-leon-lan sin registros, sin entradas automáticas. Espera a que se cierren las dos ventanas del juego y entonces cierra ydhost,
# devuelve ydhost.cfg y map.cfg originales y manda la copia del mapa a la papelera.
S=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; L=$M/v21b-leon-lan/lan
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern
Y=$R/pfx/drive_c/Tools/YDWE/plugin/ydhost; MT=$R/pfx/drive_c/WarcraftIII/Maps/Test
mkdir -p $L; LOG=$Y/log/ydhost.log-$(date +%m-%d).log
vivos(){ for p in $(pgrep -f 'runtimes.*wineserver'); do grep -qa 'proton-ydwe-modern' /proc/$p/environ && echo $p; done; }
juegos(){ hyprctl clients -j | python3 -I -c "import json,sys;print(sum(c['title']=='Warcraft III' for c in json.load(sys.stdin)))"; }
[ "$(juegos)" = 0 ] || { echo "Ya hay una ventana de Warcraft III abierta"; exit 6; }
[ -n "$(vivos)" ] && { echo "El prefijo de YDWE sigue abierto (wineserver vivo); espera a que cierre"; exit 4; }
:
cp -p $Y/ydhost.cfg $L/ydhost.cfg.orig; cp -p $Y/map.cfg $L/map.cfg.orig
restaurar(){ cp -p $L/ydhost.cfg.orig $Y/ydhost.cfg; cp -p $L/map.cfg.orig $Y/map.cfg; [ -f $MT/DevMission-v21b-leon-lan.w3x ] && gio trash $MT/DevMission-v21b-leon-lan.w3x; }
trap restaurar EXIT
cp $M/TerrainDev-Titulo-v21b-leon-lan.w3x $MT/DevMission-v21b-leon-lan.w3x
cp $M/v21b-leon-lan/map.cfg $Y/map.cfg
sed -i 's#^bot_mappath = .*#bot_mappath = Maps\\\\Test\\\\DevMission-v21b-leon-lan.w3x#; s#^bot_defaultgamename = .*#bot_defaultgamename = DevMission-v21b-leon-lan#; s#^bot_autostart_players = .*#bot_autostart_players = 2#' $Y/ydhost.cfg
grep -q '^bot_autostart_players = 2' $Y/ydhost.cfg || { echo 'ydhost.cfg sin autostart de 2'; exit 7; }
cat > $L/lanzar.bat <<'B'
@echo off
cd /d C:\Tools\YDWE\plugin\ydhost
start "" ydhost.exe
ping -n 3 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
ping -n 9 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
B
L0=$(wc -l < $LOG 2>/dev/null || echo 0)
python3 -I "$S/lan-run.py" "$L/lanzar.bat" > $L/runtime.log 2>&1 &
for i in $(seq 1 90); do n=$(juegos); [ "$n" -ge 2 ] && break; sleep 1; done
echo "ventanas de juego: $n"
python3 -I -c "
import json,subprocess
c=[x for x in json.loads(subprocess.check_output(['hyprctl','clients','-j'])) if x['title']=='Warcraft III']
c.sort(key=lambda x:x['pid'])
for x in c: print(x['address'])" > $L/ventanas.txt
a=$(sed -n 1p $L/ventanas.txt); b=$(sed -n 2p $L/ventanas.txt)
if [ -n "$a" ] && [ -n "$b" ]; then
  hyprctl dispatch "hl.dsp.window.move({workspace=\"6\", window=\"address:$a\"})" >/dev/null
  hyprctl dispatch "hl.dsp.window.move({workspace=\"7\", window=\"address:$b\"})" >/dev/null
  hyprctl dispatch "hl.dsp.workspace.move({id=\"7\", monitor=\"HDMI-A-1\"})" >/dev/null 2>&1
  for w in $b $a; do hyprctl dispatch "hl.dsp.focus({window=\"address:$w\"})" >/dev/null; hyprctl dispatch "hl.dsp.window.fullscreen()" >/dev/null; sleep 0.5; done
fi
echo "Cliente A en el espacio 6, cliente B en el 7. Cierra las dos partidas para terminar."
# Sólo avisa cuando ydhost empieza la carga con los dos (líneas nuevas del registro de hoy).
for i in $(seq 1 180); do tail -n +$((L0+1)) $LOG 2>/dev/null | grep -q 'started loading with 2' 2>/dev/null && { echo "partida cargando con 2 jugadores"; break; }; sleep 1; done
while [ "$(juegos)" != 0 ]; do sleep 2; done
for p in $(pgrep -f 'war3.exe|ydhost.exe'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
sleep 3
for p in $(pgrep -f 'steam.exe cmd /c'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
echo "fin: ydhost cerrado y configuración original devuelta"
