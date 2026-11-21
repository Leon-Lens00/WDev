#!/bin/bash
# v16z (13/11/2026): v16y (héroes de D.O.N) con las armas de v16t-rapidas. Leon: "vale, llevala al dev ahora".
# - 41 balas con Death a 0,3 s (acortar2.cjs, mismas rutas) y MissileRecycler___DEATH_TIME 0,3 (como v16t-corto).
# - rpm_v16t.py: ritmo y velocidad del tier 1, daño por bala que conserva el daño por segundo, escopeta 1/s con 5
#   perdigones en abanico (como v16t-rpm).
# - rapidas_v16t.py: fusil de asalto a 480 rpm y balas de arma de fuego al doble (como v16t-rapidas).
# Los datos de armas, Arm_Bala, el bucle de perdigones y los 41 modelos de v16y son iguales a los de v16t.
# Plan: Proyect/docs/planes/devmission-don-v16u.md. No sustituye a v16y.
T=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons; export DOTNET_ROOT=$T/wc3_agent_tools/dotnet; W=$T/wc3ctl-classic-bin/wc3ctl
PJ="$T/wc3_agent_tools/pjass/pjass $T/classic-assets/Scripts/common.j $T/classic-assets/Scripts/Blizzard.j"
P=/tmp/claude-1000/-home-snz-Documentos-ChatGPT-WDev/1c6399dc-8ba7-450e-b373-e3d4d4eef815/scratchpad/v16z-hacer; mkdir -p $P
F=/home/snz/Documentos/ChatGPT/Proyect/work/devmission-don18c-20261112
A=/home/snz/Documentos/ChatGPT/Proyect/work/bench-misiles-toy-20261110/src/modelos-cortos/acortar2.cjs
cd /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026
B=TerrainDev-Titulo-v16y.w3x; O=TerrainDev-Titulo-v16z.w3x; G="$PWD/v16z"
echo "ede162a65b2307f77bffc32ba80b00c2bb7e72ced06011cb002e9d043d9961fc  $B" | sha256sum -c --quiet || exit 1
case $P in /tmp/claude-1000/*) for d in base re; do [ -d "$P/$d" ] && rm -rf -- "$P/$d"; done;; *) exit 1;; esac
$W mpq extract-all $B -o $P/base > /dev/null || exit 1
cmp -s $P/base/war3map.j v16y/war3map.j || { echo "la base no coincide con v16y/war3map.j"; exit 1; }
mkdir -p "$G"
# --- modelos de bala: armas (Arm_Bala) y Rapid Fire (RapidBolt_modelOf), todos los colores presentes en el mapa ---
lista=()
for t in 1 2 3 4 5 6; do lista+=("war3mapImported/InterceptorShell$t.mdx"); done
for c in Yellow Green Cyan Blue Purple Red Orange; do lista+=("ShotsAjustados/Shot II $c.mdx" "ShotsAjustados/Shot $c.mdx"); done
for c in Yellow Green Cyan Blue Purple Red; do lista+=("DaemonicArrow/Daemonic Arrow $c.mdx" "ChainGrenade/Chain Grenade $c.mdx"); done
for c in Yellow Green Teal Blue Purple Red Orange Pink Silver; do lista+=("FirebrandShots/Firebrand Shot $c.mdx"); done
: > $P/cortos.txt
for n in "${lista[@]}"; do
  [ -f "$P/base/$n" ] || { echo "falta en v16y: $n"; exit 1; }
  mkdir -p "$G/$(dirname "$n")"
  node $A "$P/base/$n" "$G/$n" 0.3 > /dev/null || { echo "no se pudo recortar $n"; exit 1; }
  echo "$n" >> $P/cortos.txt
done
echo "modelos recortados: $(wc -l < $P/cortos.txt)"
# --- j: retención del reciclador igual a la Death nueva ---
python3 -I - v16y/war3map.j $P/corto.j <<'PY' || exit 1
import sys
j = open(sys.argv[1], 'rb').read()
a = b'constant real MissileRecycler___DEATH_TIME= 2.\r\n'
assert j.count(a) == 1
open(sys.argv[2], 'wb').write(j.replace(a, b'constant real MissileRecycler___DEATH_TIME= 0.3\r\n'))
PY
python3 -I scripts/rpm_v16t.py $P/corto.j $P/rpm.j > $P/tabla-rpm.txt || exit 1
python3 -I scripts/rapidas_v16t.py v16y/war3map.j $P/rpm.j "$G/war3map.j" > "$G/tabla.txt" || exit 1
$PJ "$G/war3map.j" | tail -1 | grep -q '^Parse successful' || { $PJ "$G/war3map.j" | tail -8; exit 1; }
python3 -I - $P/base $P/tabla.tsv "$G" $P/cortos.txt <<'PY' || exit 1
import sys
from pathlib import Path
b, out, g, cortos = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
cambia = {'war3map.j'} | {l.strip().replace('/', '\\') for l in open(cortos, encoding='latin-1') if l.strip()}
filas = []
for p in sorted(b.rglob('*')):
    n = str(p.relative_to(b)).replace('/', '\\')
    if p.is_file() and n.lower() not in ('(listfile)', '(attributes)'):
        filas.append((n, f"{g}/{n.replace(chr(92), '/')}" if n in cambia else str(p)))
assert cambia <= {n for n, _ in filas}, cambia - {n for n, _ in filas}
open(out, 'w', encoding='latin-1').write(''.join(f'{n}\t{f}\n' for n, f in filas))
print('entradas', len(filas), 'cambiadas', len(cambia))
PY
python3 -I $F/scripts/mpq_escribir.py $P/tabla.tsv $B $O || exit 1
$W mpq extract-all $O -o $P/re > /dev/null || exit 1
python3 -I - $P/tabla.tsv $P/re <<'PY' || exit 1
import sys, hashlib
from pathlib import Path
tsv, re_d = sys.argv[1], Path(sys.argv[2])
n = mal = 0
for l in open(tsv, encoding='latin-1'):
    nombre, src = l.rstrip('\n').split('\t')
    f = re_d / nombre.replace('\\', '/')
    if not f.is_file() or hashlib.sha256(f.read_bytes()).digest() != hashlib.sha256(open(src, 'rb').read()).digest():
        mal += 1; print('distinto:', nombre)
    n += 1
print('reextraídos', n, 'distintos', mal)
sys.exit(1 if mal else 0)
PY
$W mpq bytes-diff $B $O > $P/dif.txt; grep -m3 'only in\|differ' $P/dif.txt | cut -c1-120
$W mpq verify $O | tail -1 | cut -c1-90
sha256sum $O
