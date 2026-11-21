#!/bin/bash
# Graba cuadros de la ventana del juego sin tocar la entrada. Uso: filmar.sh CARPETA SEGUNDOS
O=$1; N=$(( ${2:-60} * 5 )); mkdir -p $O
sid(){ hyprctl clients -j | python3 -I -c "import json,sys;print(next((c['stableId'] for c in json.load(sys.stdin) if c['title']=='Warcraft III'),''))"; }
for i in $(seq 1 200); do s=$(sid); [ -n "$s" ] && break; sleep 1; done
[ -n "$s" ] || exit 1
sleep 14
for i in $(seq 1 $N); do
 [ -n "$(sid)" ] || break
 grim -s 0.5 -t jpeg -q 70 -T "$s" $O/$(printf %05d $i).jpg 2>/dev/null
 sleep 0.12
done
ffmpeg -y -loglevel error -framerate 5 -i $O/%05d.jpg -c:v libx264 -crf 30 -pix_fmt yuv420p $O.mp4
