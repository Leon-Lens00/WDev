#!/bin/bash
# Prueba de un cliente con entradas reales. Uso: boton.sh MAPA_REL TRY_REL [SEL]; SEL=1 hace clic izquierdo sobre el personaje.
SEL=${3:-0}; S=$(dirname "$0"); M=/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026; O=$M/$2; mkdir -p $O/f
R=/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern; WC=$R/pfx/drive_c/WarcraftIII; MT=$WC/Maps/Test
vivos(){ for p in $(pgrep -f 'runtimes.*wineserver'); do grep -qa 'proton-ydwe-modern' /proc/$p/environ && echo $p; done; }
juegos(){ hyprctl clients -j | python3 -I -c "import json,sys;print(sum(c['title']=='Warcraft III' for c in json.load(sys.stdin)))"; }
[ "$(juegos)" = 0 ] || { echo "ABORT ya hay ventana"; exit 6; }
for i in $(seq 1 60); do [ -z "$(vivos)" ] && break; sleep 1; done; [ -n "$(vivos)" ] && { echo "ABORT wineserver"; exit 4; }
[ -n "$SIN_ENTRADAS$TECLAS_DASH" ] || { last=""; q=0; for i in $(seq 1 240); do c=$(hyprctl cursorpos); if [ "$c" = "$last" ]; then q=$((q+1)); else q=0; fi; last=$c; [ $q -ge 25 ] && break; sleep 1; done
echo "raton quieto $q"; [ $q -ge 25 ] || { echo "ABORT raton activo"; exit 5; }; }
ORIG=$(hyprctl cursorpos)
cp $M/$1 $MT/TituloSolo-v12i.w3x
printf '@echo off\r\ncd /d C:\\WarcraftIII\r\nstart "" war3.exe -window -loadfile Maps\\Test\\TituloSolo-v12i.w3x\r\n' > $O/lanzar.bat
mkdir -p $WC/CustomMapData/lat; find $WC/CustomMapData/lat -type f -delete
python3 -I "$S/lan-run.py" "$O/lanzar.bat" > $O/runtime.log 2>&1 &
for i in $(seq 1 90); do n=$(juegos); [ "$n" -ge 1 ] && break; sleep 1; done; echo "ventanas $n tras $i s"
abortar=0
if [ "$n" -ge 1 ]; then
 a=$(hyprctl clients -j | python3 -I -c "import json,sys;print([c['address'] for c in json.load(sys.stdin) if c['title']=='Warcraft III'][0])")
 sa=$(hyprctl clients -j | python3 -I -c "import json,sys;print([c['stableId'] for c in json.load(sys.stdin) if c['title']=='Warcraft III'][0])")
 hyprctl dispatch "hl.dsp.window.move({workspace=\"6\", window=\"address:$a\"})" >/dev/null
 hyprctl dispatch "hl.dsp.focus({workspace=\"6\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({window=\"address:$a\"})" >/dev/null; hyprctl dispatch "hl.dsp.window.fullscreen()" >/dev/null
 for i in $(seq 1 100); do [ -n "$(find $WC/CustomMapData/lat -name 'j1-1.txt*' 2>/dev/null)" ] && break; sleep 1; done; echo "primer registro tras $i s"
 sleep 2; g=$(hyprctl clients -j | python3 -I -c "import json,sys;c=[c for c in json.load(sys.stdin) if c['title']=='Warcraft III'][0];print(*c['at'],*c['size'])"); set -- $g; X=$1; Y=$2; W=$3; H=$4; echo "geo $g"
 foco(){ t=$(hyprctl activewindow -j | python3 -I -c "import json,sys;print(json.load(sys.stdin).get('title',''))"); [ "$t" = "Warcraft III" ]; }
 pos(){ hyprctl dispatch "hl.dsp.cursor.move({x = $1, y = $2})" >/dev/null; sleep 0.15; }
 cap(){ grim -s 0.5 -T "$sa" $O/f/$1.png 2>>$O/grim.err; }
 guarda(){ foco || { echo "ABORT foco en $1"; abortar=1; return 1; }; [ "$(hyprctl cursorpos)" = "$EXP" ] || { echo "ABORT cursor movido en $1"; abortar=1; return 1; }; }
 # con -loadfile solo el movimiento relativo llega al puntero del juego
 rel(){ ydotool mousemove -x $1 -y $2; sleep 0.4; EXP=$(hyprctl cursorpos); }
 EXP=$(hyprctl cursorpos); cap 00-panel
 # sin entradas: el usuario puede usar el ratón; el puente hace todo el trabajo
 if [ -n "$SIN_ENTRADAS" ]; then sleep ${ESPERA:-14}; cap 07-final; abortar=1; fi
 # solo teclado: el ratón sigue libre, cada tecla exige el foco del juego
 if [ -n "$TECLAS_DASH" ]; then
  [ -n "$JUGAR" ] && for i in $(seq 1 240); do [ -n "$(find $WC/CustomMapData/lat -name 'ya.txt*' 2>/dev/null)" ] && break; sleep 1; done
  [ -n "$JUGAR" ] && echo "en juego tras $i s" && hyprctl dispatch "hl.dsp.focus({window=\"address:$a\"})" >/dev/null
  [ -n "$JUGAR" ] || sleep ${PREVIA:-5}
  tecla(){ foco || { echo "ABORT foco en $2"; abortar=1; return 1; }; ydotool key -d 30 $1:1 $1:0; sleep 0.25; foco && ydotool key -d 30 105:1 105:0; echo "tecla $2 $(date +%T.%3N) $(hyprctl cursorpos) $(hyprctl activewindow -j | python3 -I -c "import json,sys;d=json.load(sys.stdin);print(d.get('title','')[:30],d.get('workspace',{}).get('name'),d.get('fullscreen'))")"; for n in 1 2 3 4 5 6; do cap $2-$n; done; sleep 2; }
  # JUGAR: W y clic, derecho para andar, D y S, hasta fin.txt o el límite; si se pierde el foco el ratón queda libre.
  if [ -n "$JUGAR" ]; then
   TANDAS=0; c=0; t0=$SECONDS; EXP=$(hyprctl cursorpos); juega=1; rel -200 -400
   while [ -z "$(find $WC/CustomMapData/lat -name 'fin.txt*' 2>/dev/null)" ] && [ $((SECONDS-t0)) -lt ${LIMITE:-600} ]; do
    if [ $juega = 1 ] && foco && [ "$(hyprctl cursorpos)" = "$EXP" ]; then
     case $((c%4)) in 0) dx=320; dy=0;; 1) dx=0; dy=170;; 2) dx=-320; dy=0;; 3) dx=0; dy=-170;; esac
     ydotool mousemove -x $dx -y $dy; sleep 0.1; EXP=$(hyprctl cursorpos)
     ydotool key -d 30 17:1 17:0; sleep 0.1; ydotool click -D 40 0xC0; sleep 0.25
     [ $((c%3)) = 0 ] && ydotool click -D 40 0xC1
     # D pide punto desde v12w: la tecla sola deja el puntero apuntando y el clic lanza el dash.
     if [ $((c%7)) = 5 ]; then ydotool key -d 30 32:1 32:0; sleep 0.1; ydotool click -D 40 0xC0; sleep 0.1; fi
     c=$((c+1)); sleep 0.5
    else
     [ $juega = 1 ] && echo "entradas paradas en $((SECONDS-t0)) s, vuelta $c"; juega=0; sleep 2
    fi
   done
   echo "fin de juego tras $((SECONDS-t0)) s, vueltas $c"; sleep 8; cap 08-final; abortar=1; ESPERA=0
  fi
  for r in $(seq 1 ${TANDAS:-2}); do tecla ${TECLA_A:-18} A$r && tecla ${TECLA_B:-32} B$r || break; done
  sleep ${ESPERA:-3}; cap 07-final
 fi
 while [ -z "$SIN_ENTRADAS$TECLAS_DASH" ]; do
  if [ "$SEL" = 1 ]; then
   guarda sel || break; rel -26 -596; ydotool click -D 60 0xC0; echo "izquierdo personaje $(date +%T)"; sleep 1.2; cap 00b-sel; rel 26 596
  fi
  guarda click1 || break; rel -200 -400; cap 01a-apunta; ydotool click -D 60 0xC1; echo "derecho A $(date +%T)"; sleep 3; cap 01-clic-der
  guarda teclas || break; for k in 50 31 35 25; do ydotool key -d 30 $k:1 $k:0; sleep 1; done; echo "teclas MSHP $(date +%T)"; cap 02-teclas
  guarda q || break; ydotool key -d 30 16:1 16:0; sleep 0.5; rel 450 120; cap 03-q-apunta; ydotool click -D 60 0xC0; echo "Q+clic $(date +%T)"; sleep 3; cap 04-q-rafaga
  guarda r || break; ydotool key -d 30 19:1 19:0; sleep 0.5; rel -450 -120; ydotool click -D 60 0xC0; echo "R+clic $(date +%T)"; sleep 3; cap 05-r
  guarda click2 || break; rel 450 120; ydotool click -D 60 0xC1; echo "derecho B $(date +%T)"; sleep 3; cap 06-fin
  sleep ${ESPERA:-14}; cap 07-final
  break
 done
fi
for p in $(pgrep -f 'war3.exe'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done; sleep 4
for p in $(pgrep -f 'steam.exe cmd /c'); do grep -qa proton-ydwe-modern /proc/$p/environ && kill -TERM $p; done; sleep 2
mkdir -p $O/lat; find $WC/CustomMapData/lat -type f -exec mv -t $O/lat {} +
gio trash $MT/TituloSolo-v12i.w3x
hyprctl dispatch "hl.dsp.focus({workspace=\"8\"})" >/dev/null; hyprctl dispatch "hl.dsp.focus({workspace=\"1\"})" >/dev/null
ox=$(echo "$ORIG" | tr -d ' ' | cut -d, -f1); oy=$(echo "$ORIG" | tr -d ' ' | cut -d, -f2); [ "$abortar" = 1 ] || hyprctl dispatch "hl.dsp.cursor.move({x = $ox, y = $oy})" >/dev/null
pgrep -af 'war3.exe' | grep -v pgrep | cut -c1-80; ls $O/f | wc -l; ls $O/lat | wc -l; echo fin
