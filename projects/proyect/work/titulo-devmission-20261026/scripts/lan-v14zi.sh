#!/bin/bash
# Prueba LAN v14zi: cuatro clientes, dos por pantalla; las entradas salen del puente (puente_lan_v14zi.py).
S=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts; N=${1:-1}
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; L=$M/v14zi-lan/lan
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern
Y=$R/pfx/drive_c/Tools/YDWE/plugin/ydhost; MT=$R/pfx/drive_c/WarcraftIII/Maps/Test
A=alsa_output.usb-NXP_SEMICONDUCTORS_Razer_Kraken_V3_Pro-00.analog-stereo.monitor
mkdir -p $L/try$N; O=$L/try$N
LOG=$Y/log/ydhost.log-$(date +%m-%d).log; WC=$R/pfx/drive_c/WarcraftIII
vivos(){ for p in $(pgrep -f 'runtimes.*wineserver'); do grep -qa 'proton-ydwe-modern' /proc/$p/environ && echo $p; done; }
juegos(){ hyprctl clients -j | python3 -I -c "import json,sys;print(sum(c['title']=='Warcraft III' for c in json.load(sys.stdin)))"; }
[ "$(juegos)" = 0 ] || { echo "ABORT ya hay una ventana de juego"; exit 6; }
for i in $(seq 1 60); do [ -z "$(vivos)" ] && break; sleep 1; done
[ -n "$(vivos)" ] && { echo "ABORT wineserver vivo"; exit 4; }
[ -f $L/ydhost.cfg.orig ] || cp -p $Y/ydhost.cfg $L/ydhost.cfg.orig
[ -f $L/map.cfg.orig ] || cp -p $Y/map.cfg $L/map.cfg.orig
cp $M/TerrainDev-Titulo-v14zi-lan.w3x $MT/DevMission-v14zi-lan.w3x
cp $M/v14zi-lan/map.cfg $Y/map.cfg
sed -i 's#^bot_mappath = .*#bot_mappath = Maps\\\\Test\\\\DevMission-v14zi-lan.w3x#; s#^bot_defaultgamename = .*#bot_defaultgamename = DevMission-v14zi-lan#; s#^bot_autostart_players = .*#bot_autostart_players = 4#' $Y/ydhost.cfg
grep -q '^bot_autostart_players = 4' $Y/ydhost.cfg || { echo 'ABORT ydhost.cfg sin 4'; exit 7; }
cat > $L/lanzar.bat <<'B'
@echo off
cd /d C:\Tools\YDWE\plugin\ydhost
start "" ydhost.exe
ping -n 3 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
ping -n 9 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
ping -n 9 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
ping -n 9 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
B
L0=$(wc -l < $LOG 2>/dev/null || echo 0); mkdir -p $WC/CustomMapData/lat; ls $WC/CustomMapData/lat/* > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/*
python3 -I "$S/lan-run.py" "$L/lanzar.bat" > $O/runtime.log 2>&1 &
RUN=$!; echo $RUN > $O/run.pid
# esperar cuatro ventanas de juego
for i in $(seq 1 150); do n=$(juegos); [ "$n" -ge 4 ] && break; sleep 1; done
echo "ventanas $n tras $i s"
[ "$n" -ge 4 ] || echo "ABORT sin cuatro ventanas" | tee -a $O/abort.txt
hyprctl clients -j > $O/clientes.json
python3 -I - $O/clientes.json > $O/orden.txt <<'P'
import json,sys
c=[x for x in json.load(open(sys.argv[1])) if x['title']=='Warcraft III']
c.sort(key=lambda x:x['pid'])
for k,x in zip('ABCD',c): print(k,x['pid'],x['address'])
P
cat $O/orden.txt
for k in A B C D; do eval w$k=$(awk -v k=$k '$1==k{print $3}' $O/orden.txt); done
[ -n "$wA" ] && [ -n "$wB" ] && [ -n "$wC" ] && [ -n "$wD" ] || n=0
for w in $wA $wB; do hyprctl dispatch "hl.dsp.window.move({workspace=\"6\", window=\"address:$w\"})" >/dev/null; done
for w in $wC $wD; do hyprctl dispatch "hl.dsp.window.move({workspace=\"7\", window=\"address:$w\"})" >/dev/null; done
hyprctl dispatch "hl.dsp.workspace.move({id=\"7\", monitor=\"HDMI-A-1\"})" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.workspace.move({id=\"6\", monitor=\"eDP-1\"})" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.focus({workspace=\"7\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({workspace=\"6\"})" >/dev/null
hyprctl workspaces -j | python3 -I -c "import json,sys;[print(w['id'],w['monitor'],w['lastwindowtitle'][:30]) for w in json.load(sys.stdin)]" > $O/ws.txt
hyprctl monitors -j | python3 -I -c "import json,sys;[print(m['name'],m['activeWorkspace']['id']) for m in json.load(sys.stdin)]" >> $O/ws.txt
ok=0; for i in $(seq 1 90); do tail -n +$((L0+1)) $LOG 2>/dev/null | grep -q 'started loading with 4' && { ok=1; break; }; sleep 1; done
echo "partida $ok ventanas $n"
if [ "$ok" = 1 ] && [ "$n" -ge 4 ]; then
 mkdir -p $O/f
 sid(){ hyprctl clients -j | python3 -I -c "import json,sys;print([c['stableId'] for c in json.load(sys.stdin) if c['address']=='$1'][0])"; }
 sA=$(sid $wA); sB=$(sid $wB); sC=$(sid $wC); sD=$(sid $wD); echo "ids $sA $sB $sC $sD"
 for i in $(seq 1 150); do [ -n "$(find $WC/CustomMapData/lat -name 'j1-1.txt*' 2>/dev/null)" ] && break; sleep 1; done; echo "primer registro tras $i s"
 # Cuatro capturas cada ~2 s hasta FIN en los cuatro clientes (como mucho 200 rondas).
 for i in $(seq 1 200); do k=$(printf %03d $i); g=""; for c in A B C D; do eval id=\$s$c; grim -s 0.5 -T "$id" $O/f/$c$k.png 2>>$O/grim.err & g="$g $!"; done; wait $g
  [ $(grep -las 'FIN t' $WC/CustomMapData/lat/j*-*.txt | wc -l) -ge 4 ] && { echo "FIN tras $i capturas"; break; }; sleep 1; done
else echo "ABORT sin partida" | tee -a $O/abort.txt; fi
cp $Y/log/ydhost.log* $O/ 2>/dev/null
pgrep -af 'war3.exe|ydhost.exe' | grep -v pgrep | cut -c1-90 > $O/procesos.txt; cat $O/procesos.txt
for p in $(pgrep -f 'war3.exe|ydhost.exe'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
sleep 4
for p in $(pgrep -f 'steam.exe cmd /c'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
sleep 2
mkdir -p $O/lat; find $WC/CustomMapData/lat -type f -exec mv -t $O/lat {} +
pgrep -af 'war3.exe|ydhost.exe' | grep -v pgrep | cut -c1-90
cp $Y/log/ydhost.log* $O/ 2>/dev/null
cp -p $L/ydhost.cfg.orig $Y/ydhost.cfg; cp -p $L/map.cfg.orig $Y/map.cfg
gio trash $MT/DevMission-v14zi-lan.w3x
hyprctl dispatch "hl.dsp.focus({workspace=\"8\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({workspace=\"1\"})" >/dev/null
ls -la $O | cut -c20-; echo fin
