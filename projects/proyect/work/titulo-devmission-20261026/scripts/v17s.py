#!/usr/bin/env python3
"""v17s (14/11/2026): fase 1 del plan devmission-mejoras-darkmoon.md, el marco de cuadros común.

Leon: "eso mismo, entonces adelante con la implementacion". Primero el marco (fase 1): la ventana de cuadros que
usarán Mutación Evo y las mejoras del héroe. Las elecciones aún no cambian nada: sólo se ven, se eligen y se anotan.

- Escena propia en (4800, 8700), con su ancla Menu_Ancla[2]: los trackables no se pueden quitar, así que los de los
  cuadros no pueden estar en la escena de la tienda (2400, 8700). Misma cámara cenital (Shop_Camara elige el ancla).
- Al abrir la tienda con Esc en el descanso, primero salen los cuadros: 3 pasos de Mutación Evo (jefe, élite, comunes;
  cuadro carmesí) y 2 de mejora del héroe (verde). Al elegir el último se abre la tienda de siempre. Esc cierra la
  ventana y conserva el avance. Al empezar la oleada lo no elegido se pierde (el sorteo nuevo lo reinicia).
- Candidatos sorteados en Ronda_AlTerminar (código común): Mutación Evo igual para todos; del héroe, por jugador.
  Cuadros de Mutación Evo según jugadores: 1-2 -> 3, 3-5 -> 4, 6 o más -> 5 (tope del grupo: jefe y élite tienen 4).
  Del héroe siempre 4. Sin votación, sin refresco ni calidades todavía (fases 8 y 9).
- Cada cuadro: fondo 'DS01' teñido en el cliente, icono del juego (destructables DC00-DC0G, objetos_v17s.py), nombre,
  descripción y botón "Elegir" con su trackable (CuaHitBtn.mdx, 170 x 56 px). 9 posiciones fijas cada 180 px; n
  cuadros usan las posiciones 5 - n + 2j, así 3, 4 y 5 quedan centrados sin que los botones se pisen.
- Iconos por jugador (cambian de textura en código común, al sortear y al elegir); fondos y botones comunes con alfa
  sólo en el cliente de quien mira. 18 texttags locales con la ventana abierta (la tienda no está abierta a la vez).
- Variante de prueba (tercer argumento "prueba"): sorteo y elecciones en CustomMapData\\lat\\v17s-cuadros.txt, escrito
  1 s después de cada evento.
Uso: v17s.py v17r/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')   # el j guarda las cadenas en UTF-8


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


# Catálogo provisional (fase 1): nombre, descripción (|n = salto) y textura. 0-3 jefe, 4-7 élite, 8-17 comunes,
# 20-28 héroe. Las recomendaciones de la sexta tanda; los efectos se deciden al final.
EVO = [
    ('Coloso', 'El jefe tiene|n+30 % de vida.', 'DC05'),
    ('Escolta', 'El jefe llega con|n2 élites a su lado.', 'DC0A'),
    ('Furia', 'Con media vida, el jefe|nataca y corre más.', 'DC0D'),
    ('Corona', 'El jefe gana 2 mejoras|nde súper élite.', 'DC0E'),
    ('Ascenso', 'Aparecen más élites|nen la oleada.', 'DC0A'),
    ('Promoción', 'El 10 % de los comunes|nse vuelve élite.', 'DC02'),
    ('Élite feroz', 'Las élites ganan una|npasiva de súper élite.', 'DC0B'),
    ('Último aliento', 'Al morir, la élite|nsuelta una explosión.', 'DC0C'),
    ('Piel gruesa', 'Los comunes tienen|n+25 % de vida.', 'DC00'),
    ('Marea rápida', 'Los comunes corren|nun 20 % más.', 'DC01'),
    ('Veteranos', 'Un tipo viejo llega con|nfuerza de 3 rondas más.', 'DC02'),
    ('Horda', 'La oleada trae|nun 20 % más de unidades.', 'DC03'),
    ('Pocos pero fuertes', 'Mitad de unidades, con|ndoble vida y daño.', 'DC04'),
    ('Caparazón', 'Las tortugas ganan|n+3 de armadura.', 'DC05'),
    ('Lluvia de flechas', 'Los de distancia ganan|n+150 de alcance.', 'DC06'),
    ('Red de pesca', 'Los tramperos lanzan|nredes más seguido.', 'DC07'),
    ('Asalto inicial', 'Los primeros 10 s llegan|nmás rápido.', 'DC08'),
    ('Regeneración', 'Los comunes recuperan|nvida con el tiempo.', 'DC09'),
]
HEROE = [
    ('Filo', 'Más daño de|ntus armas.', 'DC04'),
    ('Vitalidad', 'Más vida|nmáxima.', 'DC09'),
    ('Zancada', 'Más velocidad|nde movimiento.', 'DC01'),
    ('Golpe de suerte', 'Probabilidad de|ngolpe crítico.', 'DC0B'),
    ('Pisotón', 'Habilidad de Cairne:|naturde alrededor.', 'DC0D'),
    ('Onda de choque', 'Habilidad de Cairne:|nonda en línea.', 'DC0F'),
    ('Botín', 'Más oro de|nlas bolsas.', 'DC0G'),
    ('Evasión', 'Probabilidad de|nesquivar golpes.', 'DC0E'),
    ('Pacto maldito', 'Mucho daño, pero|npierdes vida máxima.', 'DC0C'),
]
GRUPO = [(0, 4), (4, 4), (8, 10)]   # inicio y tamaño de jefe, élite y comunes en EVO
PASO_NOMBRE = ['Mutación Evo · jefe (1/3)', 'Mutación Evo · élite (2/3)', 'Mutación Evo · comunes (3/3)',
               'Mejora del héroe (1/2)', 'Mejora del héroe (2/2)']

catalogo = ''
for i, e in enumerate(EVO + [None, None] + HEROE):
    if e is None:
        continue
    nom, des, tex = e
    catalogo += f'''    set Cua_Nom[{i}] = "{nom}"
    set Cua_Des[{i}] = "{des}"
    set Cua_Tex[{i}] = '{tex}'
'''
for k, s in enumerate(PASO_NOMBRE):
    catalogo += f'    set Cua_PasoNom[{k}] = "{s}"\n'

globales = '''// v17s: marco de cuadros (Mutación Evo y mejoras del héroe).
boolean Cua_Listo = false
boolean array Cua_Open
integer array Cua_Paso
integer array Cua_Cand
integer array Cua_Cnt
integer array Cua_HCand
integer array Cua_Elegido
integer Cua_NE = 3
boolean array Cua_SlotUsa
unit array Cua_Bg
unit array Cua_Bt
unit array Cua_Ico
effect array Cua_Fondo
string array Cua_Nom
string array Cua_Des
integer array Cua_Tex
string array Cua_PasoNom
texttag array Cua_TN
texttag array Cua_TD
texttag array Cua_TB
texttag Cua_TCab = null
texttag Cua_TPie = null
texttag Cua_RelojT = null
string Cua_RelojVisto = ""
'''
if prueba:
    globales += '''integer Cua_LN = 0
string array Cua_L
timer Cua_LT = null
timer Cua_Tiempo = null
'''

registro = ''
if prueba:
    registro = '''// v17s-prueba: sorteo y elecciones en CustomMapData\\\\lat\\\\v17s-cuadros.txt, 1 s después del último evento.
function Cua_Escribir takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    loop
        exitwhen i >= Cua_LN
        call Preload(Cua_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\\\v17s-cuadros.txt")
endfunction

function Cua_Anotar takes string s returns nothing
    if Cua_Tiempo == null then
        set Cua_Tiempo = CreateTimer()
        call TimerStart(Cua_Tiempo, 100000., false, null)
        set Cua_LT = CreateTimer()
    endif
    if Cua_LN >= 150 then
        return
    endif
    set Cua_L[Cua_LN] = R2S(TimerGetElapsed(Cua_Tiempo)) + " " + s
    set Cua_LN = Cua_LN + 1
    call TimerStart(Cua_LT, 1., false, function Cua_Escribir)
endfunction

'''

anotar_sorteo = '''    set i = 0
    loop
        exitwhen i > 2
        set s = "sorteo r" + I2S(Ronda_Numero) + " paso " + I2S(i) + ":"
        set j = 0
        loop
            exitwhen j >= Cua_Cnt[i]
            set s = s + " " + Cua_Nom[Cua_Cand[i * 5 + j]]
            set j = j + 1
        endloop
        call Cua_Anotar(s)
        set i = i + 1
    endloop
''' if prueba else ''

cuerpo = registro + '''// v17s: escena de los cuadros en (4800, 8700). Las piezas y textos se colocan con Title_CX en 4800 y se restaura.
function Cua_At takes texttag t, real px, real py, real size, real w returns nothing
    set Title_CX = 4800.
    call Shop_At(t, px, py, size, w)
    set Title_CX = 2400.
endfunction

function Cua_Centro takes integer p, texttag t, string s, real px, real py, real size returns nothing
    local real w = StringLength(s) * size * 470.
    if GetLocalPlayer() == Player(p) then
        call SetTextTagText(t, s, size)
        call Cua_At(t, px, py, size, w)
    endif
endfunction

function Cua_Izq takes integer p, texttag t, string s, real px, real py, real size returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetTextTagText(t, s, size)
        call Cua_At(t, px, py, size, 0)
    endif
endfunction

function Cua_Tag takes nothing returns texttag
    local texttag t = CreateTextTag()
    call SetTextTagPermanent(t, true)
    call SetTextTagVisibility(t, true)
    call SetTextTagText(t, "", 0.02)
    call SetTextTagColor(t, 235, 240, 245, 255)
    set bj_lastCreatedTextTag = t
    set t = null
    return bj_lastCreatedTextTag
endfunction

// Sólo en el cliente de quien abre la ventana: 18 texttags que se quitan al cerrarla.
function Cua_Textos takes nothing returns nothing
    local integer i = 0
    if Cua_TCab != null then
        return
    endif
    set Cua_TCab = Cua_Tag()
    set Cua_TPie = Cua_Tag()
    set Cua_RelojT = Cua_Tag()
    set Cua_RelojVisto = ""
    loop
        exitwhen i > 4
        set Cua_TN[i] = Cua_Tag()
        set Cua_TD[i] = Cua_Tag()
        set Cua_TB[i] = Cua_Tag()
        set i = i + 1
    endloop
endfunction

function Cua_TextosFuera takes nothing returns nothing
    local integer i = 0
    call DestroyTextTag(Cua_TCab)
    call DestroyTextTag(Cua_TPie)
    call DestroyTextTag(Cua_RelojT)
    set Cua_TCab = null
    set Cua_TPie = null
    set Cua_RelojT = null
    loop
        exitwhen i > 4
        call DestroyTextTag(Cua_TN[i])
        call DestroyTextTag(Cua_TD[i])
        call DestroyTextTag(Cua_TB[i])
        set Cua_TN[i] = null
        set Cua_TD[i] = null
        set Cua_TB[i] = null
        set i = i + 1
    endloop
endfunction

function Cua_Cuantos takes integer p returns integer
    if Cua_Paso[p] < 3 then
        return Cua_Cnt[Cua_Paso[p]]
    endif
    return 4
endfunction

function Cua_Item takes integer p, integer c returns integer
    if Cua_Paso[p] < 3 then
        return Cua_Cand[Cua_Paso[p] * 5 + c]
    endif
    return Cua_HCand[p * 10 + (Cua_Paso[p] - 3) * 5 + c]
endfunction

// Posición fija (0-8, cada 180 px) del cuadro c de n.
function Cua_Slot takes integer n, integer c returns integer
    return 5 - n + 2 * c
endfunction

function Cua_PX takes integer s returns real
    return 240. + 180. * s
endfunction

// Iconos del paso actual de p. Cambian de textura con un pedido de unidad: sólo en código común.
function Cua_Pintar takes integer p returns nothing
    local integer n = Cua_Cuantos(p)
    local integer c = 0
    if Cua_Paso[p] >= 5 then
        return
    endif
    loop
        exitwhen c >= n
        if Cua_Ico[p * 9 + Cua_Slot(n, c)] != null then
            call Title_Skin(Cua_Ico[p * 9 + Cua_Slot(n, c)], Cua_Tex[Cua_Item(p, c)])
        endif
        set c = c + 1
    endloop
endfunction

// Lo que ve el cliente de p: alfa y tinte de fondos, botones e iconos; textos del paso.
function Cua_Ver takes integer p returns nothing
    local integer n = Cua_Cuantos(p)
    local integer s = 0
    local integer c
    local integer a
    local integer r = 225
    local integer g = 45
    local integer b = 70
    if Cua_Paso[p] >= 3 then
        set r = 70
        set g = 205
        set b = 95
    endif
    if GetLocalPlayer() != Player(p) then
        return
    endif
    loop
        exitwhen s > 8
        if Cua_SlotUsa[s] then
            set a = 0
            set c = s - (5 - n)
            if Cua_Open[p] and Cua_Paso[p] < 5 and c >= 0 and ModuloInteger(c, 2) == 0 and c / 2 < n then
                set a = 255
            endif
            call SetUnitVertexColor(Cua_Bg[s], r, g, b, a)
            call SetUnitVertexColor(Cua_Bt[s], 255, 255, 255, a)
            call SetUnitVertexColor(Cua_Ico[p * 9 + s], 255, 255, 255, a)
        endif
        set s = s + 1
    endloop
    if Cua_TCab == null or Cua_Paso[p] >= 5 then
        return
    endif
    call Cua_Centro(p, Cua_TCab, Cua_PasoNom[Cua_Paso[p]], 960, 70, 0.03)
    if Cua_Paso[p] < 3 then
        call SetTextTagColor(Cua_TCab, 255, 80, 100, 255)
    else
        call SetTextTagColor(Cua_TCab, 120, 240, 140, 255)
    endif
    call Cua_Centro(p, Cua_TPie, "Esc: salir (lo elegido se guarda hasta que empiece la oleada)", 960, 790, 0.018)
    set c = 0
    loop
        exitwhen c > 4
        if c < n then
            set s = Cua_Slot(n, c)
            call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 380, 0.022)
            call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)], Cua_PX(s) - 140, 440, 0.016)
            call Cua_Centro(p, Cua_TB[c], "Elegir", Cua_PX(s), 690, 0.02)
            call SetTextTagVisibility(Cua_TN[c], true)
            call SetTextTagVisibility(Cua_TD[c], true)
            call SetTextTagVisibility(Cua_TB[c], true)
        else
            call SetTextTagVisibility(Cua_TN[c], false)
            call SetTextTagVisibility(Cua_TD[c], false)
            call SetTextTagVisibility(Cua_TB[c], false)
        endif
        set c = c + 1
    endloop
endfunction

function Cua_Mostrar takes integer p, boolean on returns nothing
    local string path = ""
    if GetLocalPlayer() == Player(p) then
        if on then
            set path = "war3mapImported\\\\ShopPlano.mdx"
            call Cua_Textos()
        else
            call Cua_TextosFuera()
        endif
    endif
    if on then
        set Cua_Fondo[p] = AddSpecialEffect(path, 4800., 8700.)
    else
        call DestroyEffect(Cua_Fondo[p])
        set Cua_Fondo[p] = null
    endif
    call Cua_Ver(p)
endfunction

// El tiempo del descanso en la ventana, en el cliente de quien la tiene abierta.
function Cua_Reloj takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    local string t
    if not Cua_Open[p] or Cua_RelojT == null then
        return
    endif
    set t = "Descanso " + I2S(Ronda_Resta)
    if t != Cua_RelojVisto then
        set Cua_RelojVisto = t
        call Cua_Izq(p, Cua_RelojT, t, 1650, 70, 0.022)
        if Ronda_Resta <= 10 then
            call SetTextTagColor(Cua_RelojT, 255, 48, 48, 255)
        else
            call SetTextTagColor(Cua_RelojT, 235, 240, 245, 255)
        endif
    endif
endfunction

// c candidatos distintos de [ini, ini + tam) en Cua_Cand/Cua_HCand desde la casilla k (código común).
function Cua_Elegir takes integer ini, integer tam, integer c, boolean heroe, integer k returns nothing
    local integer i = 0
    local integer j
    local integer x
    local boolean rep
    loop
        exitwhen i >= c
        loop
            set x = ini + GetRandomInt(0, tam - 1)
            set rep = false
            set j = 0
            loop
                exitwhen j >= i
                if heroe then
                    set rep = rep or Cua_HCand[k + j] == x
                else
                    set rep = rep or Cua_Cand[k + j] == x
                endif
                set j = j + 1
            endloop
            exitwhen not rep
        endloop
        if heroe then
            set Cua_HCand[k + i] = x
        else
            set Cua_Cand[k + i] = x
        endif
        set i = i + 1
    endloop
endfunction

// Al empezar el descanso (Ronda_AlTerminar, por nombre): candidatos nuevos y pasos a cero.
function Cua_Sortear takes nothing returns nothing
    local integer p = 0
    local integer i = 0
    local integer j
    local string s
    set Cua_Cnt[0] = IMinBJ(Cua_NE, 4)
    set Cua_Cnt[1] = IMinBJ(Cua_NE, 4)
    set Cua_Cnt[2] = Cua_NE
    call Cua_Elegir(0, 4, Cua_Cnt[0], false, 0)
    call Cua_Elegir(4, 4, Cua_Cnt[1], false, 5)
    call Cua_Elegir(8, 10, Cua_Cnt[2], false, 10)
''' + anotar_sorteo + '''    loop
        exitwhen p > 11
        if Game_On[p] then
            call Cua_Elegir(20, 9, 4, true, p * 10)
            call Cua_Elegir(20, 9, 4, true, p * 10 + 5)
            set Cua_Paso[p] = 0
            call Cua_Pintar(p)
        endif
        set p = p + 1
    endloop
    set Cua_Listo = true
endfunction

// Clic en el botón de la posición s (0-8). Sin efecto todavía: se avisa y se anota.
function Cua_Clic takes integer p, integer s returns nothing
    local integer n = Cua_Cuantos(p)
    local integer c = s - (5 - n)
    local integer x
    if Cua_Paso[p] >= 5 or c < 0 or ModuloInteger(c, 2) != 0 or c / 2 >= n then
        return
    endif
    set x = Cua_Item(p, c / 2)
    call UI_Click(p)
    set Cua_Elegido[p * 5 + Cua_Paso[p]] = x
    if Cua_Paso[p] < 3 then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 6, "|cffff5064Mutación Evo|r: " + Cua_Nom[x] + " (aún sin efecto)")
    else
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 6, "|cff78f08cMejora del héroe|r: " + Cua_Nom[x] + " (aún sin efecto)")
    endif
''' + ('''    call Cua_Anotar("j" + I2S(p) + " r" + I2S(Ronda_Numero) + " paso " + I2S(Cua_Paso[p]) + " elige " + Cua_Nom[x] + " (pos " + I2S(s) + ")")
''' if prueba else '') + '''    set Cua_Paso[p] = Cua_Paso[p] + 1
    if Cua_Paso[p] < 5 then
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif
    // Último paso: se cierra la ventana y se abre la tienda (Shop_Open ya está activo).
    set Cua_Open[p] = false
    call Cua_Mostrar(p, false)
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
endfunction

'''

construir = '''// v17s: piezas de la ventana de cuadros (fondos y botones comunes, iconos por jugador) y sus trackables.
function Cua_Construir takes nothing returns nothing
    local integer p = 0
    local integer s
    local integer n = 0
    local unit u
''' + catalogo + '''    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set n = n + 1
        endif
        set p = p + 1
    endloop
    set Cua_NE = 3
    if n >= 6 then
        set Cua_NE = 5
    elseif n >= 3 then
        set Cua_NE = 4
    endif
    // Posiciones de los grupos posibles: jefe y élite min(NE, 4), comunes NE, héroe 4.
    set s = 0
    loop
        exitwhen s >= IMinBJ(Cua_NE, 4)
        set Cua_SlotUsa[Cua_Slot(IMinBJ(Cua_NE, 4), s)] = true
        set s = s + 1
    endloop
    set s = 0
    loop
        exitwhen s >= Cua_NE
        set Cua_SlotUsa[Cua_Slot(Cua_NE, s)] = true
        set s = s + 1
    endloop
    set s = 0
    loop
        exitwhen s > 3
        set Cua_SlotUsa[Cua_Slot(4, s)] = true
        set s = s + 1
    endloop
    set Title_CX = 4800.
    set Menu_Ancla[2] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 4800., 8700., 0.)
    set s = 0
    loop
        exitwhen s > 8
        if Cua_SlotUsa[s] then
            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 430, 330, 560, 430, 'DS01')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 690, 170, 56, 399, 'DS0A')
            set p = 0
            loop
                exitwhen p > 11
                if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 250, 150, 150, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 690, 40 + s)
                endif
                set p = p + 1
            endloop
        endif
        set s = s + 1
    endloop
    set Title_CX = 2400.
    set u = null
endfunction

'''

pic = '''// v17s: como Shop_Pic, pero fuera de la lista de la tienda (Shop_Mostrar no la toca).
function Cua_Pic takes real px, real py, real w, real h, real depth, integer tex returns unit
    local unit u = Title_Pic('uids', px, py, w, h, depth, tex)
    local real x = Title_WX(Shop_PY(py), depth)
    local real y = Title_WY(px, depth)
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    call SetUnitFlyHeight(u, Shop_OJO - depth - UserInterface_GetTerrainZ(x, y), 0)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

'''

# Globales.
una('unit array Menu_Ancla\n', 'unit array Menu_Ancla\n' + globales)
# Cámara: la ventana de cuadros usa su ancla.
una('''        call SetCameraTargetController(Menu_Ancla[1], 0., 0., false)
''', '''        if Cua_Open[p] then
            call SetCameraTargetController(Menu_Ancla[2], 0., 0., false)
        else
            call SetCameraTargetController(Menu_Ancla[1], 0., 0., false)
        endif
''')
# Niebla: la escena nueva queda a la vista como la de la tienda.
una('''    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(800.0, 7700.0, 4000.0, 9700.0), true, true))
''', '''    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(800.0, 7700.0, 4000.0, 9700.0), true, true))
    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(4000.0, 7700.0, 5600.0, 9700.0), true, true))
''')
# Sorteo al empezar el descanso.
una('''        set Ronda_Descanso = true
        set Shop_Pausa = 0
''', '''        set Ronda_Descanso = true
        set Shop_Pausa = 0
        call ExecuteFunc("Cua_Sortear")
''')
# Funciones de la ventana antes de Shop_Cerrar (usan Shop_Textos, Shop_Mostrar, Shop_Refrescar y Shop_Camara).
una('''function Shop_Cerrar takes integer p returns nothing
    if not Shop_Open[p] then
        return
    endif
''', pic + cuerpo + '''function Shop_Cerrar takes integer p returns nothing
    if not Shop_Open[p] then
        return
    endif
    if Cua_Open[p] then
        set Cua_Open[p] = false
        call Cua_Mostrar(p, false)
    endif
''')
# Abrir: primero los cuadros mientras queden pasos.
una('''    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
    call Shop_Refrescar(p)
endfunction
''', '''    if Cua_Listo and Cua_Paso[p] < 5 then
        set Cua_Open[p] = true
        call Shop_Camara(p)
        if GetLocalPlayer() == Player(p) then
            call ClearSelection()
        endif
        call Cua_Mostrar(p, true)
        return
    endif
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
    call Shop_Refrescar(p)
endfunction
''')
# Clics: los botones de los cuadros (40-48) antes que los de la tienda.
una('''    local integer k = LoadInteger(Shop_HT, h, 1)
    if not Shop_Open[p] then
        return
    endif
''', '''    local integer k = LoadInteger(Shop_HT, h, 1)
    if k >= 40 then
        if Cua_Open[p] then
            call Cua_Clic(p, k - 40)
        endif
        return
    endif
    if not Shop_Open[p] or Cua_Open[p] then
        return
    endif
''')
# Reloj del descanso en la ventana.
una('''    call Shop_Reloj()
endfunction
''', '''    call Shop_Reloj()
    call Cua_Reloj()
endfunction
''')
# Construcción al final de Shop_Construir (Shop_Hit ya existe).
una('''function Shop_Construir takes nothing returns nothing
''', construir + '''function Shop_Construir takes nothing returns nothing
''')
una('''    call TriggerAddAction(t, function Shop_Esc)
''', '''    call Cua_Construir()
    call TriggerAddAction(t, function Shop_Esc)
''')
# Cua_Pic va antes que Cua_Construir: está en el bloque de antes de Shop_Cerrar.

Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17s: marco de cuadros' + (' + registro' if prueba else ''))
