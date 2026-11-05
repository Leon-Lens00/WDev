#!/bin/bash
# Fotografía la ventana del juego cada 2 s. Uso: vista.sh MAPA.w3x NOMBRE SEGUNDOS
# Termina con FIN en lat\vista-*.txt o a los SEGUNDOS desde que aparece la ventana; cierra sólo su war3.exe.
M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII
pgrep -x war3.exe > /dev/null && { echo 'Warcraft III ya está abierto'; exit 1; }
vivos(){ for p in $(pgrep -f 'runtimes.*wineserver'); do grep -qa 'proton-ydwe-modern' /proc/$p/environ && echo $p; done; }
for i in $(seq 1 60); do [ -z "$(vivos)" ] && break; sleep 1; done
[ -n "$(vivos)" ] && { echo 'wineserver vivo'; exit 4; }
O=$M/evidencia/vista-$2; mkdir -p $O/f
mkdir -p $WC/CustomMapData/lat; ls $WC/CustomMapData/lat/vista-*.txt > /dev/null 2>&1 && gio trash $WC/CustomMapData/lat/vista-*.txt
cp $M/$1 $WC/Maps/Test/DevMission-$2.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\DevMission-%s.w3x\r\n' $2 > $O/lanzar.bat
python3 -I $M/scripts/lan-run.py $O/lanzar.bat > $O/runtime.log 2>&1 &
sid(){ hyprctl clients -j | python3 -I -c "import json,sys;print(next((c['stableId'] for c in json.load(sys.stdin) if c['title']=='Warcraft III'),''))"; }
for i in $(seq 1 120); do s=$(sid); [ -n "$s" ] && break; sleep 1; done
[ -n "$s" ] || { echo 'sin ventana'; exit 1; }
for i in $(seq 1 $(( $3 / 2 ))); do
  grim -s 0.5 -T "$s" $O/f/$(printf %03d $i).png 2>>$O/grim.err
  ls $WC/CustomMapData/lat/vista-*.txt 2>/dev/null | xargs -r grep -l 'FIN t' | grep -q . && { echo "FIN tras $i capturas"; break; }
  # Con la cámara fijada (registro "bloqueo"), flechas derecha y arriba 1,5 s cada una en la ventana del juego.
  if [ -z "$flechas" ] && ls $WC/CustomMapData/lat/vista-*.txt 2>/dev/null | xargs -r grep -l 'bloqueo' | grep -q .; then
    flechas=1; ad=$(hyprctl clients -j | python3 -I -c "import json,sys;print(next((c['address'] for c in json.load(sys.stdin) if c['title']=='Warcraft III'),''))")
    hyprctl dispatch "hl.dsp.focus({window=\"address:$ad\"})" >/dev/null; sleep 0.4
    hyprctl activewindow -j | grep -q '"title": "Warcraft III"' && { ydotool key 106:1; sleep 1.5; ydotool key 106:0; ydotool key 103:1; sleep 1.5; ydotool key 103:0; echo "flechas enviadas"; } || echo "sin foco: flechas no enviadas"
  fi
  sleep 2
done
pgrep -ax war3.exe > $O/procesos.txt
for p in $(pgrep -x war3.exe); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
sleep 4
for p in $(pgrep -f 'steam.exe cmd /c'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done
mkdir -p $O/lat; find $WC/CustomMapData/lat -name 'vista-*.txt' -exec mv -t $O/lat {} +
gio trash $WC/Maps/Test/DevMission-$2.w3x
pgrep -ax war3.exe; echo listo
