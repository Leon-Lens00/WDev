#!/bin/bash
# Prueba LAN v14zo: dos clientes, uno por pantalla; las entradas salen del puente (puente_lan_v14zo.py).
S=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts; N=${1:-1}
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; L=$M/v14zo-lan/lan
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
cp $M/TerrainDev-Titulo-v14zo-lan.w3x $MT/DevMission-v14zo-lan.w3x
cp $M/v14zo-lan/map.cfg $Y/map.cfg
sed -i 's#^bot_mappath = .*#bot_mappath = Maps\\\\Test\\\\DevMission-v14zo-lan.w3x#; s#^bot_defaultgamename = .*#bot_defaultgamename = DevMission-v14zo-lan#; s#^bot_autostart_players = .*#bot_autostart_players = 2#' $Y/ydhost.cfg
grep -q '^bot_autostart_players = 2' $Y/ydhost.cfg || { echo 'ABORT ydhost.cfg sin 2'; exit 7; }
cat > $L/lanzar.bat <<'B'
@echo off
cd /d C:\Tools\YDWE\plugin\ydhost
start "" ydhost.exe
ping -n 3 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
ping -n 9 127.0.0.1 >nul
start "" C:\Tools\YDWE\YDWE.exe -war3 -auto -closew2l
B
L0=$(wc -l < $LOG 2>/dev/null || echo 0); mkdir -p $WC/CustomMapData/lat; ls $WC/CustomMapData/lat/* > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/*
python3 -I "$S/lan-run.py" "$L/lanzar.bat" > $O/runtime.log 2>&1 &
RUN=$!; echo $RUN > $O/run.pid
# esperar dos ventanas de juego
for i in $(seq 1 90); do n=$(juegos); [ "$n" -ge 2 ] && break; sleep 1; done
echo "ventanas $n tras $i s"
[ "$n" -ge 2 ] || echo "ABORT sin dos ventanas" | tee -a $O/abort.txt
hyprctl clients -j > $O/clientes.json
python3 -I - $O/clientes.json > $O/orden.txt <<'P'
import json,sys
c=[x for x in json.load(open(sys.argv[1])) if x['title']=='Warcraft III']
c.sort(key=lambda x:x['pid'])
for k,x in zip('AB',c): print(k,x['pid'],x['address'])
P
cat $O/orden.txt
a=$(awk '$1=="A"{print $3}' $O/orden.txt); b=$(awk '$1=="B"{print $3}' $O/orden.txt)
[ -n "$a" ] && [ -n "$b" ] || n=0
hyprctl dispatch "hl.dsp.window.move({workspace=\"6\", window=\"address:$a\"})" >/dev/null
hyprctl dispatch "hl.dsp.window.move({workspace=\"7\", window=\"address:$b\"})" >/dev/null
hyprctl dispatch "hl.dsp.workspace.move({id=\"7\", monitor=\"HDMI-A-1\"})" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.focus({workspace=\"7\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({window=\"address:$b\"})" >/dev/null; hyprctl dispatch "hl.dsp.window.fullscreen()" >/dev/null
hyprctl dispatch "hl.dsp.focus({workspace=\"6\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({window=\"address:$a\"})" >/dev/null; hyprctl dispatch "hl.dsp.window.fullscreen()" >/dev/null
for w in $a $b; do for i in 1 2 3 4; do f=$(hyprctl clients -j | python3 -I -c "import json,sys;print([c['fullscreen'] for c in json.load(sys.stdin) if c['address']=='$w'][0])"); [ "$f" != 0 ] && break; hyprctl dispatch "hl.dsp.focus({window=\"address:$w\"})" >/dev/null; hyprctl dispatch "hl.dsp.window.fullscreen()" >/dev/null; sleep 0.5; done; echo "fs $w $f"; done
hyprctl workspaces -j | python3 -I -c "import json,sys;[print(w['id'],w['monitor'],w['lastwindowtitle'][:30]) for w in json.load(sys.stdin)]" > $O/ws.txt
hyprctl monitors -j | python3 -I -c "import json,sys;[print(m['name'],m['activeWorkspace']['id']) for m in json.load(sys.stdin)]" >> $O/ws.txt
ok=0; for i in $(seq 1 90); do tail -n +$((L0+1)) $LOG 2>/dev/null | grep -q 'started loading with 2' && { ok=1; break; }; sleep 1; done
echo "partida $ok ventanas $n"
if [ "$ok" = 1 ] && [ "$n" -ge 2 ]; then
 mkdir -p $O/f
 sa=$(hyprctl clients -j | python3 -I -c "import json,sys;print([c['stableId'] for c in json.load(sys.stdin) if c['address']=='$a'][0])"); sb=$(hyprctl clients -j | python3 -I -c "import json,sys;print([c['stableId'] for c in json.load(sys.stdin) if c['address']=='$b'][0])"); echo "ids $sa $sb"
 for i in $(seq 1 120); do [ -n "$(find $WC/CustomMapData/lat -name 'j1-1.txt*' 2>/dev/null)" ] && break; sleep 1; done; echo "primer registro tras $i s"
 # Una pareja de capturas cada ~2 s hasta FIN en los dos clientes (como mucho 300 s).
 for i in $(seq 1 150); do k=$(printf %03d $i); grim -s 0.5 -T "$sa" $O/f/a$k.png 2>>$O/grim.err & g1=$!; grim -s 0.5 -T "$sb" $O/f/b$k.png 2>>$O/grim.err & g2=$!; wait $g1 $g2
  [ $(grep -las 'FIN t' $WC/CustomMapData/lat/j*-*.txt | wc -l) -ge 2 ] && { echo "FIN tras $i capturas"; break; }; sleep 1.5; done
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
gio trash $MT/DevMission-v14zo-lan.w3x
hyprctl dispatch "hl.dsp.focus({workspace=\"8\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({workspace=\"1\"})" >/dev/null
ls -la $O | cut -c20-; echo fin
