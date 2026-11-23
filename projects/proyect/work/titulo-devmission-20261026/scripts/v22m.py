#!/usr/bin/env python3
"""v22m (23/11/2026): modelos del MVP inclinados hacia la cámara como el jefe; nombres largos que caben; lado del MVP
con columnas centradas.

Leon tras v22l-prueba (-tabla 8, captura): los modelos salían tumbados (vistos desde arriba): "segun el apartado de
presentacion de boss antes de aparecer creo usa otro modelo inclinado para que cuadre con la vista".
- Modelos: mvp_giro_camara.cjs (en hacer-v22m.sh) da al hueso MvpFrente el giro fijo de PresJefe (arriba = arriba de la
  pantalla, frente hacia la cámara y -20°: tres cuartos hacia la cifra). La unidad sigue a facing 0 (v22l); el j no cambia aquí.
- Tabla: "MMMMMMMMMMMMMMM" pisaba BAJAS. Punt_Corto recorta el nombre (sin contar |c..|r) a 214 de ancho estimado
  (Punt_Ancho: anchos de Friz a 0,019 medidos en la captura: M/W 20,5, mayúsculas 13,5, cifras y minúsculas 10...) y le
  pone "..". El texttag de los nombres es uno solo de varias líneas: no se puede achicar sólo una.
- Lado: el nombre (MVP y menos puntos) va centrado en el cuadro (1325) y, si mide más de 250, se achica
  (Mvp_PonNom: Mvp_Tam y Mvp_Ancho); la cifra de puntos va centrada en la columna derecha (1395), con la etiqueta
  PUNTOS centrada debajo (PuntLado de puntos_v22m.py); la recompensa en 3 renglones centrada en esa columna, por encima
  de los pies del modelo (antes se salía del cuadro por la derecha y tapaba el modelo).
Uso: v22m.py ENTRADA.j SALIDA.j [prueba]   (normal de v22l; prueba de v22l-prueba).
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


# 1) Global: ancho en pantalla de los nombres del lado.
cambia('real array Mvp_Tam\n', 'real array Mvp_Tam\n// v22m: ancho estimado de los textos 8 y 11 (nombres del lado) a su tamaño.\nreal array Mvp_Ancho\n')

# 2) Anchos, recorte y nombre del lado (antes de Mvp_Pon, que las usa Mvp_PonNom).
cambia('function Mvp_Pon takes integer k, string s returns nothing\n', '''// v22m: ancho de un carácter de Friz a 0,019 (unidades de pantalla del HUD), medido en la captura de v22l-prueba.
function Punt_AnchoC takes string c returns real
    if c == "M" or c == "W" then
        return 20.5
    elseif c == "m" or c == "w" then
        return 14.5
    elseif c == "i" or c == "l" or c == "j" or c == "I" or c == "!" or c == "." or c == "," or c == "'" or c == ":" then
        return 5.5
    elseif c == "f" or c == "t" or c == "r" or c == " " then
        return 7.5
    elseif StringCase(c, false) != c then
        return 13.5
    endif
    return 10.
endfunction

// v22m: ancho visible a 0,019 (sin |cAARRGGBB ni |r).
function Punt_Ancho takes string s returns real
    local integer i = 0
    local integer l = StringLength(s)
    local real w = 0.
    loop
        exitwhen i >= l
        if SubString(s, i, i + 2) == "|c" then
            set i = i + 10
        elseif SubString(s, i, i + 2) == "|r" then
            set i = i + 2
        else
            set w = w + Punt_AnchoC(SubString(s, i, i + 1))
            set i = i + 1
        endif
    endloop
    return w
endfunction

// v22m: nombre de la tabla recortado a maxw (con ".." al final si no cabe); conserva el color.
function Punt_Corto takes string s, real maxw returns string
    local integer i = 0
    local integer l = StringLength(s)
    local real w = 0.
    local string pre = ""
    local string r = ""
    local string c
    if Punt_Ancho(s) <= maxw then
        return s
    endif
    if SubString(s, 0, 2) == "|c" then
        set pre = SubString(s, 0, 10)
        set i = 10
    endif
    loop
        exitwhen i >= l
        set c = SubString(s, i, i + 1)
        exitwhen SubString(s, i, i + 2) == "|r"
        exitwhen w + Punt_AnchoC(c) > maxw - 11.
        set w = w + Punt_AnchoC(c)
        set r = r + c
        set i = i + 1
    endloop
    return pre + r + "..|r"
endfunction

function Mvp_Pon takes integer k, string s returns nothing
''')
cambia('''// Número "al azar" del recuento''', '''// v22m: nombre del lado: tamaño 0,019 o menor si mide más de 250; Punt_Hud lo centra con Mvp_Ancho.
function Mvp_PonNom takes integer k, string s returns nothing
    local real w = Punt_Ancho(s)
    local real z = 0.019
    if w > 250. then
        set z = 0.019 * 250. / w
    endif
    if z != Mvp_Tam[k] and s == Mvp_Txt[k] then
        set Mvp_TxtV[k] = Mvp_TxtV[k] + 1
    endif
    set Mvp_Tam[k] = z
    set Mvp_Ancho[k] = w * z / 0.019
    call Mvp_Pon(k, s)
endfunction

// Número "al azar" del recuento''')

# 3) Nombres de la tabla recortados (Mvp_Preparar; en prueba también -tabla).
cambia('set nom = nom + Mvp_Nom[f]\n', 'set nom = nom + Punt_Corto(Mvp_Nom[f], 214.)\n', 2 if prueba else 1)

# 4) Nombres del lado con Mvp_PonNom.
cambia('call Mvp_Pon(8, Mvp_Nom[ModuloInteger(b / 2, Mvp_N)])', 'call Mvp_PonNom(8, Mvp_Nom[ModuloInteger(b / 2, Mvp_N)])')
cambia('call Mvp_Pon(11, Mvp_Nom[ModuloInteger(b / 2 + 1, Mvp_N)])', 'call Mvp_PonNom(11, Mvp_Nom[ModuloInteger(b / 2 + 1, Mvp_N)])')
cambia('call Mvp_Pon(8, Mvp_Nom[Mvp_Gana])', 'call Mvp_PonNom(8, Mvp_Nom[Mvp_Gana])')
cambia('call Mvp_Pon(11, Mvp_Nom[Mvp_Pierde])', 'call Mvp_PonNom(11, Mvp_Nom[Mvp_Pierde])')

# 5) Recompensa en 3 renglones para la columna derecha.
cambia('"|cffffcc00Recompensa: carta extra|nT3+ en el descanso.|r"', '"|cffffcc00Recompensa:|ncarta extra T3+|nen el descanso.|r"')
cambia('"|cff909090Sin recompensa con|nun solo jugador.|r"', '"|cff909090Sin recompensa|ncon un solo|njugador.|r"')

# 6) Posiciones del lado.
cambia('''    // v22l: nombre arriba a lo ancho; cifra de puntos y recompensa a la derecha del modelo (etiqueta PUNTOS en PuntLado).
    call Punt_Pos(Punt_TT[p * 16 + 11], 1195.0, 205.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 10], 1320.0, 257.0 + dy, 0.032)
    call Punt_Pos(Punt_TT[p * 16 + 12], 1320.0, 334.0 + dy, 0.014)
    call Punt_Pos(Punt_TT[p * 16 + 14], 1195.0, 437.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 13], 1320.0, 489.0 + dy, 0.032)
''', '''    // v22m: nombre centrado en el cuadro (1325); cifra centrada en la columna derecha (1395) sobre la etiqueta PUNTOS;
    // recompensa (3 renglones, crece hacia arriba desde el último) centrada en esa columna, sobre los pies del modelo.
    call Punt_Pos(Punt_TT[p * 16 + 11], 1325.0 - Mvp_Ancho[8] / 2., 205.0 + dy, Mvp_Tam[8])
    call Punt_Pos(Punt_TT[p * 16 + 10], 1395.0 - I2R(Racha_Largo(Mvp_Txt[7])) * 271. * 0.032, 257.0 + dy, 0.032)
    call Punt_Pos(Punt_TT[p * 16 + 12], 1341.0, 334.0 + dy, 0.014)
    call Punt_Pos(Punt_TT[p * 16 + 14], 1325.0 - Mvp_Ancho[11] / 2., 437.0 + dy, Mvp_Tam[11])
    call Punt_Pos(Punt_TT[p * 16 + 13], 1395.0 - I2R(Racha_Largo(Mvp_Txt[10])) * 271. * 0.032, 489.0 + dy, 0.032)
''')
assert src.index('function Racha_Largo') < src.index('function Punt_Hud')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22l-', 'lat\\\\v22m-', src.count('lat\\\\v22l-'))
    cambia('v22l-don.txt', 'v22m-don.txt', src.count('v22l-don.txt'))
    assert 'lat\\\\v22l-' not in src and 'v22l-don.txt' not in src, 'quedan registros v22l'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22m', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
