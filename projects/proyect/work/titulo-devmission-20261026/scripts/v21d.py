#!/usr/bin/env python3
"""v21d (22/11/2026): base común del rework de personajes de DON 2.1a (plan devmission-rework-habilidades-don21a.md).

1. Tabla de personajes (Pj_*): tipo, celda de la selección, copia Dcp, modelo de frente, escala del cuadro, icono
   (piel de destructible), icono de vida, nombre y rango de técnicas del libro. Sustituye las cadenas por id de
   Mvp_TipoFrente, Mvp_Escala, Dcp_Tipo, Don_Nombre, Tec_Rango y los iconos de Game_Enter y Pj_Cambiar.
2. Rachas: el icono sale del personaje que tiene el jugador (Game_Hero), no de la celda elegida (Leon vio a Freezer
   con el icono de Cairne).
3. Selección: vuelve la pantalla de selección (v20y la ignoraba y fijaba el héroe por color). El color sólo queda como
   respaldo si el jugador no eligió nada (p. ej. entrada directa). Todos los personajes D.O.N, uno por partida.
4. Choques: los misiles de Goku (Kamehameha, Warp) ya no explotan al chocar con un árbol o una pendiente; se quedan
   en ese punto y explotan cuando se acaba su tiempo de D.O.N (como al tocar el límite en D.O.N). Freezer, Trunks y
   Naruto ya lo hacían así (Don_Pon). Ninguna técnica rompe árboles.
5. -pj N: además de cambiar de personaje, desbloquea todas sus técnicas (nivel 1 como mínimo) para probarlas.
Uso: v21d.py ENTRADA.j SALIDA.j [prueba]   (normal de v21c; prueba de v21c-prueba).
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


def funcion(nombre, nuevo):
    global src
    pat = re.compile(r'^function %s takes.*?^endfunction\n' % nombre, re.S | re.M)
    assert len(pat.findall(src)) == 1, nombre
    src = pat.sub(lambda m: U(nuevo), src, count=1)


# ---- globales ----
cambia('''boolean Gk_MisChoque = false
''', '''boolean Gk_MisChoque = false
// v21d: tabla de personajes
integer Pj_N = 0
integer array Pj_T
integer array Pj_Celda
integer array Pj_Copia
integer array Pj_Frente
real array Pj_Escala
integer array Pj_Ico
integer array Pj_Vida
string array Pj_Nom
integer array Pj_TecA
integer array Pj_TecN
''')

# ---- tabla (antes de su primer consumidor, Racha_Anunciar) ----
TABLA = [  # tipo, celda, copia, frente, escala, icono, vida, nombre, técnicas (inicio, número)
    ("'h005'", 0, '0', "'hMf0'", '1.', "'DT3Q'", "'hbi0'", 'Tauren', 63, 7),
    ("'h006'", 1, '0', "'hMf1'", '175. / 202.', "'DT2R'", "'hbi1'", 'Cairne', 70, 8),
    ("'hGok'", 2, "'hCpG'", "'hMf2'", '175. / 204.', "'DT4G'", "'hbi3'", 'Goku', 40, 5),
    ("'hFrz'", 3, "'hCpF'", "'hMf3'", '1.', "'DT4F'", "'hbi4'", 'Freezer', 45, 6),
    ("'hTrk'", 4, "'hCpT'", "'hMf4'", '175. / 194.', "'DT4T'", "'hbi5'", 'Trunks', 51, 6),
    ("'hNar'", 5, "'hCpN'", "'hMf5'", '175. / 248.', "'DT4N'", "'hbi6'", 'Naruto', 57, 6),
    ("'hNaK'", 5, "'hCpK'", "'hMf6'", '1.', "'DT4N'", "'hbi6'", 'Naruto', 57, 6),
]
filas = ''.join(f'    call Pj_Fijar({t}, {c}, {cp}, {fr}, {e}, {ic}, {vi}, "{n}", {a}, {k})\n'
                for t, c, cp, fr, e, ic, vi, n, a, k in TABLA)
cambia('''// v14zq: tarjeta nueva. La que se veía pasa a salir;''', '''// ---- v21d: tabla de personajes. Una fila por tipo de cuerpo (Naruto Kyuubi comparte celda con Naruto). ----
function Pj_Fijar takes integer t, integer celda, integer copia, integer frente, real escala, integer ico, integer vida, string nom, integer tecA, integer tecN returns nothing
    set Pj_T[Pj_N] = t
    set Pj_Celda[Pj_N] = celda
    set Pj_Copia[Pj_N] = copia
    set Pj_Frente[Pj_N] = frente
    set Pj_Escala[Pj_N] = escala
    set Pj_Ico[Pj_N] = ico
    set Pj_Vida[Pj_N] = vida
    set Pj_Nom[Pj_N] = nom
    set Pj_TecA[Pj_N] = tecA
    set Pj_TecN[Pj_N] = tecN
    set Pj_N = Pj_N + 1
endfunction

function Pj_Registro takes nothing returns nothing
''' + filas + '''endfunction

// Fila del tipo t, o -1.
function Pj_Fila takes integer t returns integer
    local integer r = 0
    if Pj_N == 0 then
        call Pj_Registro()
    endif
    loop
        exitwhen r >= Pj_N
        if Pj_T[r] == t then
            return r
        endif
        set r = r + 1
    endloop
    return -1
endfunction

// Tipo del personaje del que t es la copia Dcp, o t.
function Pj_DeCopia takes integer t returns integer
    local integer r = 0
    if Pj_N == 0 then
        call Pj_Registro()
    endif
    loop
        exitwhen r >= Pj_N
        if Pj_Copia[r] == t and t != 0 then
            return Pj_T[r]
        endif
        set r = r + 1
    endloop
    return t
endfunction

function Pj_IcoDe takes integer t returns integer
    local integer r = Pj_Fila(t)
    if r < 0 then
        return 'DT3Q'
    endif
    return Pj_Ico[r]
endfunction

function Pj_VidaDe takes integer t, integer otro returns integer
    local integer r = Pj_Fila(t)
    if r < 0 then
        return otro
    endif
    return Pj_Vida[r]
endfunction

// v14zq: tarjeta nueva. La que se veía pasa a salir;''')

# ---- rachas: icono del personaje que tiene el jugador ----
cambia('''    // v20z: icono del personaje de p (piel de la selección).
    set Racha_CIco[n] = Hero_Icon[IMaxBJ(0, Hero_Choice[p])]
''', '''    // v20z: icono del personaje de p. v21d: del cuerpo que tiene (Game_Hero), no de la celda elegida.
    set Racha_CIco[n] = Pj_IcoDe(GetUnitTypeId(Game_Hero[p]))
''')

# ---- consumidores convertidos a la tabla ----
funcion('Mvp_TipoFrente', '''function Mvp_TipoFrente takes integer id returns integer
    local integer r = Pj_Fila(id)
    if r >= 0 then
        return Pj_Frente[r]
    endif
    return id
endfunction
''')
funcion('Mvp_Escala', '''function Mvp_Escala takes integer id returns real
    local integer r = Pj_Fila(id)
    if r >= 0 then
        return MVP_MOD_ESCALA * Pj_Escala[r]
    endif
    return MVP_MOD_ESCALA
endfunction
''')
funcion('Dcp_Tipo', '''function Dcp_Tipo takes unit u returns integer
    return Pj_DeCopia(GetUnitTypeId(u))
endfunction
''')
funcion('Don_Nombre', '''function Don_Nombre takes integer p returns string
    local integer r = Pj_Fila(GetUnitTypeId(Game_Hero[p]))
    if r >= 0 then
        return Pj_Nom[r]
    endif
    return "Tauren"
endfunction
''')
funcion('Tec_Rango', '''function Tec_Rango takes integer p returns nothing
    local integer r = Pj_Fila(GetUnitTypeId(Game_Hero[p]))
    set Tec_A = 0
    set Tec_N = 0
    if r >= 0 then
        set Tec_A = Pj_TecA[r]
        set Tec_N = Pj_TecN[r]
    endif
endfunction
''')

# ---- Game_Enter: vuelve la selección; el color sólo si no eligió ----
cambia('''    // v20y: sin selección de héroe, fijo por color: rojo Tauren, azul Cairne, morado Goku, amarillo Freezer,
    // naranja Trunks, verde Naruto; verde azulado Tauren y rosa Cairne (no se repiten los de D.O.N).
    if GetPlayerController(Player(p)) == MAP_CONTROL_USER then
''', '''    // v20y: sin selección de héroe, fijo por color: rojo Tauren, azul Cairne, morado Goku, amarillo Freezer,
    // naranja Trunks, verde Naruto; verde azulado Tauren y rosa Cairne (no se repiten los de D.O.N).
    // v21d: vuelve la pantalla de selección; el color queda sólo para quien no eligió (entrada directa).
    if GetPlayerController(Player(p)) == MAP_CONTROL_USER and k < 0 then
''')
cambia('''        endif
        set Hero_Choice[p] = k
        set Hero_Locked[p] = true
    endif
''', '''        endif
        // v21d: el de su color, salvo que otro jugador ya eligiera esa celda de D.O.N.
        if k >= 2 and Pj_CeldaAjena(p, k) then
            set k = 0
        endif
        set Hero_Choice[p] = k
        set Hero_Locked[p] = true
    endif
''')
cambia('''function Game_Enter takes integer p returns nothing
''', '''// v21d: otro jugador eligió la celda k.
function Pj_CeldaAjena takes integer p, integer k returns boolean
    local integer i = 0
    loop
        exitwhen i > 11
        if i != p and Hero_Choice[i] == k then
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction

function Game_Enter takes integer p returns nothing
''')
cambia('''    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon='hbi3'
    endif
    if GetUnitTypeId(Game_Hero[p]) == 'hFrz' then
        set icon='hbi4'
    endif
    if GetUnitTypeId(Game_Hero[p]) == 'hTrk' then
        set icon='hbi5'
    endif
    if GetUnitTypeId(Game_Hero[p]) == 'hNar' then
        set icon='hbi6'
    endif
''', '''    set icon = Pj_VidaDe(GetUnitTypeId(Game_Hero[p]), icon)
''')

# ---- selección: todos los personajes D.O.N, uno por partida ----
cambia('''    if k >= 2 and k <= 5 then
        loop
            exitwhen i > 7''', '''    // v21d: todos los personajes de D.O.N desde la celda 2, uno de cada por partida.
    if k >= 2 then
        loop
            exitwhen i > 7''')

# ---- choques de los misiles de Goku ----
cambia('''set Gk_MisChoque = Gk_MisBloq[m]
''', '''// v21d: chocar con un árbol, una pendiente o el límite ya no hace explotar: la pieza se queda en ese punto y la
// técnica sigue su tiempo de D.O.N (la bola de 2,2 s del Kamehameha, el contador del Warp).
set Gk_MisChoque = false
''')

# ---- -pj: técnicas completas ----
cambia('''// v16v: -pj N cambia el personaje en la partida''', '''// v21d: -pj desbloquea todas las técnicas del personaje (nivel 1 como mínimo) para probarlas.
function Pj_Completas takes integer p returns nothing
    local integer x
    call Tec_Rango(p)
    set x = Tec_A
    loop
        exitwhen x >= Tec_A + Tec_N
        if Tec_Niv[p * 100 + x] < 1 then
            set Tec_Niv[p * 100 + x] = 1
        endif
        set x = x + 1
    endloop
    call Tec_Aplicar(p)
endfunction

// v16v: -pj N cambia el personaje en la partida''')
cambia('''    call Game_Cuerpo(p, x, y)
    call SetUnitInvulnerable(Game_Hero[p], GetUnitAbilityLevel(viejo, 'Avul') > 0)
''', '''    call Game_Cuerpo(p, x, y)
    call Pj_Completas(p)
    call SetUnitInvulnerable(Game_Hero[p], GetUnitAbilityLevel(viejo, 'Avul') > 0)
''')
cambia('''    if k == 1 then
        set icon = 'hbi1'
    endif
    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon = 'hbi3'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hFrz' then
        set icon = 'hbi4'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hTrk' then
        set icon = 'hbi5'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hNar' then
        set icon = 'hbi6'
    endif
''', '''    set icon = Pj_VidaDe(GetUnitTypeId(Game_Hero[p]), icon)
''')
cambia('''"Personaje: " + Don_Nombre(p) + "  (-pj N para cambiar)"''',
       '''"Personaje: " + Don_Nombre(p) + ", con todas sus técnicas  (-pj N para cambiar)"''')

if prueba:
    for v, n in (('lat\\\\v21c-', 'lat\\\\v21d-'), ('v21c-don.txt', 'v21d-don.txt')):
        assert v in src, v
        src = src.replace(v, n)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
