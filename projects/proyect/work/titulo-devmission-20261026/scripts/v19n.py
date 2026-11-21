#!/usr/bin/env python3
"""v19n (19/11/2026), tras la prueba de v19m (grabación 20261119_181550):
- Mejoras del héroe (5 cartas: 4 y el refresco, desde v18y): las casillas 0 y 8 nunca se marcaban en Cua_SlotUsa, así
  que la 1.ª carta y Refrescar salían sin fondo, icono, botón ni pista de clic (sólo el texto). Se marcan las 5.
- Cabecera: los títulos de v19m ("MEJORA DEL JEFE · …", "TU HÉROE · …") partían en dos renglones y el rojo/dorado del
  texto se perdía sobre la banda del mismo color. Vuelven los títulos de v19l, en blanco; el color lo da la banda, que
  baja a la altura real del texto (py 66 → 87; en la grabación el texto va en y ≈ 58 de 720).
Uso: v19n.py ENTRADA.j SALIDA.j [prueba]   (normal de v19m; prueba de v19m-prueba)
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


cambia('''    // v18m: los 3 cuadros de la pantalla de inicio.
    set s = 0
''', '''    // v19n: las 5 casillas de las mejoras del héroe (4 cartas y el refresco).
    set s = 0
    loop
        exitwhen s > 4
        set Cua_SlotUsa[Cua_Slot(5, s)] = true
        set s = s + 1
    endloop
    // v18m: los 3 cuadros de la pantalla de inicio.
    set s = 0
''')
cambia('''        return "MEJORA DEL JEFE · Mutación Evo · oleada " + I2S(Ronda_Numero + 1)''',
       '''        return "Mutación Evo · oleada " + I2S(Ronda_Numero + 1)''')
cambia('''        return "TU HÉROE · " + Cua_PasoNom[Cua_Paso[p]] + " · suerte " + I2S(Her_Suerte[p])''',
       '''        return Cua_PasoNom[Cua_Paso[p]] + " · suerte " + I2S(Her_Suerte[p])''')
cambia('''    if Cua_Paso[p] < 3 then
        return "MEJORA DEL JEFE · " + Cua_PasoNom[Cua_Paso[p]]
    endif
''', '')
cambia("    set Cua_CabP = Cua_Pic(960, 66, 1000, 64, 420, 'DS1R')\n",
       "    set Cua_CabP = Cua_Pic(960, 87, 1000, 64, 420, 'DS1R')\n")
cambia('''        call Cua_Centro(p, Cua_TCab, Cua_InicioCab(p), 960, 70, 0.03)
        call SetTextTagColor(Cua_TCab, Her_R, Her_G, Her_B, 255)''', '''        call Cua_Centro(p, Cua_TCab, Cua_InicioCab(p), 960, 70, 0.03)
        call SetTextTagColor(Cua_TCab, 250, 246, 238, 255)''')
cambia('''        if Cua_Paso[p] < 3 or Cua_Modo[p] == 2 then
            call SetTextTagColor(Cua_TCab, 255, 80, 100, 255)
        else
            call SetTextTagColor(Cua_TCab, 120, 240, 140, 255)
        endif''', '''        call SetTextTagColor(Cua_TCab, 250, 246, 238, 255)''')
if prueba:
    for viejo, nuevo in (('lat\\\\v19m-', 'lat\\\\v19n-'), ('v19m-don.txt', 'v19n-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19n', 'prueba' if prueba else 'normal')
