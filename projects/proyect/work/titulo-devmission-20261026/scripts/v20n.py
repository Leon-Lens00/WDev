#!/usr/bin/env python3
"""v20n (20/11/2026): escala del modelo del cuadro MVP / menos puntos según la altura de cada personaje.
Leon pidió revisar los demás modelos tras v20m. Vistos de frente en Stand (con sus piezas), las alturas en unidades son:
Tauren 165 (con tótem), Cairne 202, Goku 197-204 (con cabeza; SS3 la más alta), Freezer 144, Trunks 194 (con cabeza),
Naruto 248, Kyuubi 127. Con la escala 0,27 calibrada con el Tauren caben unas 180 entre los pies (y 358) y el título
"MVP" (captura de v20k): Naruto pasaba el borde y Goku, Trunks y Cairne tapaban el título.
Ahora cada uno usa 0,27 × 175 / altura, sin pasar de 0,27: los bajos quedan igual que antes.
Uso: v20n.py ENTRADA.j SALIDA.j [prueba]   (normal de v20m; prueba de v20m-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


ALTO = {'h006': 202, 'hGok': 204, 'hTrk': 194, 'hNar': 248}
ramas = ''.join(f"    {'if' if i == 0 else 'elseif'} id == '{r}' then\n        return MVP_MOD_ESCALA * 175. / {a}.\n"
                for i, (r, a) in enumerate(ALTO.items()))
cambia('''// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''', f'''// v20n: escala del modelo según su altura de frente (unidades), para que quepa bajo el título del cuadro.
function Mvp_Escala takes integer id returns real
{ramas}    endif
    return MVP_MOD_ESCALA
endfunction

// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''')
cambia('''    local integer alfa = 0
    if h == null or GetUnitTypeId(h) == 0 then''', '''    local integer alfa = 0
    local real e
    if h == null or GetUnitTypeId(h) == 0 then''')
cambia('    call SetUnitScale(u, MVP_MOD_ESCALA, MVP_MOD_ESCALA, MVP_MOD_ESCALA)\n',
       '    set e = Mvp_Escala(GetUnitTypeId(h))\n    call SetUnitScale(u, e, e, e)\n')
if prueba:
    for viejo, nuevo in (('lat\\\\v20m-', 'lat\\\\v20n-'), ('v20m-don.txt', 'v20n-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20n', 'prueba' if prueba else 'normal')
