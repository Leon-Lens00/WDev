#!/usr/bin/env python3
"""v19s (19/11/2026): textos de los paneles, paneles sin burbuja, 75 s de compra e indicadores de borde (Leon, tras
jugar v19r: "seria ajustar su texto, adicional quitales el contorno de brillo de los dos cuadros de la izquierda como
derecha, aumentemos 15 segundo al tiempo de compra, adicional algo con el indicador de tienda y posiblemente de boss
tambien, en esa zona cerca al minimapa que es a la izquierda y parte baja el icono se sube, debe ser una regla que este
ahi ... ahora esta libre y puede ir sin esa regla, otro tambien en los bordes de izquierda y derecha se corta el icono
de la tienda como boss").
- En la captura de v19r las piezas y textos lejos del centro salen ~3 % más afuera de su px (1,03 en X): la
  descripción del detalle izquierdo (px 60) caía a 35, fuera del marco interior (~55); la derecha (1560) a 1583.
  Ahora 95 y 1586 (≈ 68 y 1605 en pantalla).
- Pestañas: 92 × 34 en px 110 / 210 / 310 (la de Jefe tocaba el marco), a profundidad 396 (la de Jefe a 412 quedaba
  detrás de la ventana: el orden de lo translúcido va por distancia real al ojo y lejos del centro la ventana a 430
  quedaba más cerca). Textos a 0,016 alineados a la izquierda con su ancho medido ("Comunes" se salía a 0,019).
- Iconos del panel y del detalle a 393, marco del detalle a 392 (antes 405/404), por la misma razón.
- Fuera las burbujas de los paneles y detalles ('ubjP', 'ubjD'; objetos_v19s.py quita objetos e imports).
- Ronda_DESCANSO 60 → 75.
- DevJefe_Poner, DevTienda_Poner y Tut_Marca (la marca del jefe del tutorial): sin la regla del minimapa (con x < 375 el icono no bajaba de py 780); límites
  laterales 25 / 1895 → 58 / 1863: con el 1,02-1,03 de los bordes la esfera (~33 px de radio) se cortaba.
Uso: v19s.py ENTRADA.j SALIDA.j [prueba]   (normal de v19r; prueba de v19r-prueba)
"""
import re
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


# --- descanso ---
cambia('constant integer Ronda_DESCANSO = 60\n', 'constant integer Ronda_DESCANSO = 75\n')

# --- indicadores de borde (jefe, tienda y la marca del tutorial; el bloque de la tienda arrastra un CR suelto, \r\r\n
# en el original, que se conserva) ---
n = len(re.findall(r'\( 1895\. - 961\. \)', src)) + len(re.findall(r'\( 25\. - 961\. \)', src))
assert n == 6, n
src = src.replace('( 1895. - 961. )', '( 1863. - 961. )').replace('( 25. - 961. )', '( 58. - 961. )')
src, n = re.subn(r'\n( +)// Encima del minimapa, que sube m\xc3\xa1s que la consola\.\r?\n +if 961\. \+ dx \* t < 375\. then\r?\n'
                 r' +set t=RMinBJ\(t, \( 780\. - 432\.323669 \) / dy\)\r?\n +endif\r?(?=\n)', '', src)
assert n == 2, n
assert '375. then' not in src

# --- paneles: sin burbujas ---
cambia('''    set Pan_Aro[0] = Cua_Aro(210, 325, 428, 'ubjP')
    set Pan_Aro[1] = Cua_Aro(1710, 325, 428, 'ubjP')
    set Pan_Aro[2] = Cua_Aro(210, 656, 428, 'ubjD')
    set Pan_Aro[3] = Cua_Aro(1710, 656, 428, 'ubjD')
''', '')
cambia('''    call Cua_AroVer(Pan_Aro[0], on, 255, 225, 45, 70)
    call Cua_AroVer(Pan_Aro[1], on, 255, 70, 205, 95)
    call Cua_AroVer(Pan_Aro[2], on, 255, 225, 45, 70)
    call Cua_AroVer(Pan_Aro[3], on, 255, 70, 205, 95)
''', '')
cambia('unit array Pan_Aro\n', '')
assert 'Pan_Aro' not in src and "'ubjP'" not in src and "'ubjD'" not in src

# --- profundidades: pestañas, placa, iconos y detalle delante de la ventana ---
cambia("""    set Pan_Pz[4] = Cua_Pic(210, 586, 132, 132, 404, 'DS03')
    set Pan_Pz[5] = Cua_Pic(1710, 586, 132, 132, 404, 'DS03')
    set Pan_Pz[6] = Cua_Pic(1710, 205, 316, 34, 412, 'DS06')""",
       """    set Pan_Pz[4] = Cua_Pic(210, 586, 132, 132, 392, 'DS03')
    set Pan_Pz[5] = Cua_Pic(1710, 586, 132, 132, 392, 'DS03')
    set Pan_Pz[6] = Cua_Pic(1710, 205, 316, 34, 396, 'DS06')""")
cambia("""        set Pan_TabOff[i] = Cua_Pic(Pan_TabX(i), 205, 100, 34, 412, 'DS06')
        set Pan_TabOn[i] = Cua_Pic(Pan_TabX(i), 205, 100, 34, 411.5, 'DS05')""",
       """        set Pan_TabOff[i] = Cua_Pic(Pan_TabX(i), 205, 92, 34, 396, 'DS06')
        set Pan_TabOn[i] = Cua_Pic(Pan_TabX(i), 205, 92, 34, 395.5, 'DS05')""")
cambia("Pan_IcoY(0), 52, 52, 405, Pan_Tex(i))", "Pan_IcoY(0), 52, 52, 393, Pan_Tex(i))")
cambia("Pan_IcoY(Pan_Cnt[g]), 405)", "Pan_IcoY(Pan_Cnt[g]), 393)")
cambia("Pan_IcoY(i), 52, 52, 405, Pan_Tex(x))", "Pan_IcoY(i), 52, 52, 393, Pan_Tex(x))")
cambia("Cua_Pic(Pan_CX(k), 586, 120, 120, 405, tex)", "Cua_Pic(Pan_CX(k), 586, 120, 120, 393, tex)")
cambia('''function Pan_TabX takes integer i returns real
    return 210. + (i - 1) * 108.
endfunction''', '''function Pan_TabX takes integer i returns real
    return 210. + (i - 1) * 100.
endfunction

// v19s: borde izquierdo del texto de la pestaña i a 0,016 (ancho medido en la captura de v19r a 0,019, × 0,84).
function Pan_TabTxtX takes integer i returns real
    if i == 0 then
        return 95.
    elseif i == 1 then
        return 195.
    endif
    return 274.
endfunction''')

# --- textos ---
cambia('''        call Cua_Centro(p, Pan_TT[i], s, Pan_TabX(i), 193, 0.019)''',
       '''        call Cua_Izq(p, Pan_TT[i], s, Pan_TabTxtX(i), 195, 0.016)''')
cambia('''s + Cua_Des[x], 60, 722, 0.021)''', '''s + Cua_Des[x], 95, 722, 0.021)''')
cambia('''Pan_HDes(p, Pan_HX[i], Pan_HQ[i]), 1560, 722, 0.021)''', '''Pan_HDes(p, Pan_HX[i], Pan_HQ[i]), 1586, 722, 0.021)''')

if prueba:
    for viejo, nuevo in (('lat\\\\v19r-', 'lat\\\\v19s-'), ('v19r-don.txt', 'v19s-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19s', 'prueba' if prueba else 'normal')
