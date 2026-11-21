#!/usr/bin/env python3
"""v19k (19/11/2026), Leon: "apliquemosles mejor hotkeys a los DON tomando de referencia la original y tambien ordenando
del mas fuerte al mas ligero, apliquemos al menu de mejoras tambien que permitira aprender esas habilidad
individualmente segun la seleccion". (Teclas y orden de los botones: objetos_v19k.py.)
- Técnicas por carta: cada técnica de Goku, Freezer, Trunks y Naruto es una carta (40-62, en el orden del más fuerte
  al más ligero) que sólo sale para el personaje elegido. Elegirla la aprende a nivel 1; volver a elegirla la sube
  un nivel hasta el máximo que tenía (Kamehameha 4, Dragon Fist 3, Spirit Bomb 1…).
- Al empezar sólo se sabe la técnica más ligera de ataque (Kamehameha, You Will Die By My Hand!, Burning Attack,
  Rasenrengan); las demás están ocultas en el libro V (SetPlayerAbilityAvailable) hasta aprenderlas.
- Mejora del héroe: en cada tanda de 4 cartas, las posiciones 2 y 3 pasan a ser técnicas que aún se pueden aprender o
  subir (la 1 sigue siendo la garantizada y la 4 puede ser Pacto maldito). Color: amarillo para aprender, y según el
  nivel al que sube. No cuentan para la garantía de T4.
- El nivel de la técnica real del cuerpo es el aprendido; la copia lo toma de ahí (Dcp_Lanzar).
- Prueba: "-tec" aprende todas al máximo.
Uso: v19k.py ENTRADA.j SALIDA.j [prueba]   (normal de v19j; prueba de v19j-prueba)
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


def antes(marca, nuevo):
    cambia(marca, nuevo + marca)


# x: (puente, real, máximo, tecla, nombre, icono, inicial), del más fuerte al más ligero (igual que objetos_v19k.py).
TEC = [
    ('AGk3', 'A0BZ', 3, 'R', 'Super Dragon Fist', 'DK00', 0),
    ('AGk5', 'A01G', 1, 'T', 'Spirit Bomb', 'DK01', 0),
    ('AGk2', 'A0IA', 4, 'W', 'Warp Kamehameha', 'DK02', 0),
    ('AGk1', 'A00P', 4, 'Q', 'Kamehameha', 'DK03', 1),
    ('AGk4', 'A0G2', 1, 'X', 'Super Saiyan', 'DK04', 0),
    ('AFz4', 'A0IW', 3, 'R', 'Death Ball', 'DK05', 0),
    ('AFz1', 'A0IY', 1, 'X', 'Destructo Disc', 'DK06', 0),
    ('AFz2', 'A0J1', 4, 'E', 'Death Break', 'DK07', 0),
    ('AFz5', 'A0IV', 4, 'W', 'Imprisonment Ball', 'DK08', 0),
    ('AFz3', 'A0IX', 4, 'Q', 'Die By My Hand!', 'DK09', 1),
    ('AFz6', 'A0IZ', 1, 'T', 'Power Up', 'DK0A', 0),
    ('ATr5', 'A03W', 3, 'R', 'Burning Slash', 'DK0B', 0),
    ('ATr6', 'A0I5', 1, 'T', 'Finish Sign', 'DK0C', 0),
    ('ATr3', 'A086', 4, 'E', 'Heat Dome', 'DK0D', 0),
    ('ATr2', 'A0GV', 4, 'W', 'Finish Buster', 'DK0E', 0),
    ('ATr4', 'A05B', 4, 'Q', 'Burning Attack', 'DK0F', 1),
    ('ATr1', 'A0H5', 1, 'X', 'Power Up', 'DK0G', 0),
    ('ANa3', 'A00U', 3, 'R', 'Modo Kyuubi', 'DK0H', 0),
    ('ANa6', 'A0HW', 1, 'D', 'Chakra Blast', 'DK0I', 0),
    ('ANa2', 'A0AI', 1, 'T', 'Odama Rasengan', 'DK0J', 0),
    ('ANa5', 'A0F3', 4, 'Q', 'RasenShuriken', 'DK0K', 0),
    ('ANa4', 'A0F5', 4, 'E', 'Rasenrengan', 'DK0L', 1),
    ('ANa1', 'A00T', 1, 'X', 'Kage Bunshin', 'DK0M', 0),
]
assert len(TEC) == 23
for t in TEC:
    assert ("'%s'" % t[0]) in src and ("'%s'" % t[1]) in src, t

cambia('integer Dcp_N = 0\n', 'integer Dcp_N = 0\n'
       'integer array Tec_Puente\ninteger array Tec_Real\ninteger array Tec_Max\nstring array Tec_Tecla\n'
       'integer array Tec_Ini\ninteger array Tec_Niv\nboolean array Tec_Listo\ninteger Tec_A = 0\ninteger Tec_N = 0\n')

datos = ''
for k, (pu, re, mx, te, no, ic, ini) in enumerate(TEC):
    x = 40 + k
    datos += (f"    set Tec_Puente[{x}] = '{pu}'\n    set Tec_Real[{x}] = '{re}'\n    set Tec_Max[{x}] = {mx}\n"
              f"    set Tec_Tecla[{x}] = \"{te}\"\n    set Tec_Ini[{x}] = {ini}\n    set Cua_Nom[{x}] = \"{no}\"\n"
              f"    set Cua_Des[{x}] = \"Técnica de D.O.N.\"\n    set Cua_Tex[{x}] = '{ic}'\n")
tec_cmd = ''
tec_reg = ''
if prueba:
    tec_cmd = '''
// v19k-prueba: "-tec" aprende todas las técnicas del personaje al máximo.
function Tec_Todas takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    local integer x
    call Tec_Rango(p)
    set x = Tec_A
    loop
        exitwhen x >= Tec_A + Tec_N
        set Tec_Niv[p * 64 + x] = Tec_Max[x]
        set x = x + 1
    endloop
    call Tec_Aplicar(p)
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 4., "Técnicas: todas al máximo.")
endfunction
'''
    tec_reg = '''    loop
        exitwhen i > 11
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-tec", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function Tec_Todas)
'''
antes('function Don_Init takes nothing returns nothing\n', '''// v19k: técnicas de D.O.N por carta (40-62, del más fuerte al más ligero de cada personaje).
function Tec_Rango takes integer p returns nothing
    local integer t = GetUnitTypeId(Game_Hero[p])
    set Tec_A = 0
    set Tec_N = 0
    if t == 'hGok' then
        set Tec_A = 40
        set Tec_N = 5
    elseif t == 'hFrz' then
        set Tec_A = 45
        set Tec_N = 6
    elseif t == 'hTrk' then
        set Tec_A = 51
        set Tec_N = 6
    elseif t == 'hNar' or t == 'hNaK' then
        set Tec_A = 57
        set Tec_N = 6
    endif
endfunction

// Botones del libro según lo aprendido y nivel de la técnica real del cuerpo (código común).
function Tec_Aplicar takes integer p returns nothing
    local integer x
    local integer n
    call Tec_Rango(p)
    set x = Tec_A
    loop
        exitwhen x >= Tec_A + Tec_N
        set n = Tec_Niv[p * 64 + x]
        call SetPlayerAbilityAvailable(Player(p), Tec_Puente[x], n > 0)
        if n > 0 and GetUnitAbilityLevel(Game_Hero[p], Tec_Real[x]) > 0 then
            call SetUnitAbilityLevel(Game_Hero[p], Tec_Real[x], n)
        endif
        set x = x + 1
    endloop
endfunction

// Al crear el cuerpo: la primera vez sólo se sabe la técnica inicial.
function Tec_Empezar takes integer p returns nothing
    local integer x
    call Tec_Rango(p)
    if not Tec_Listo[p] and Tec_N > 0 then
        set Tec_Listo[p] = true
        set x = Tec_A
        loop
            exitwhen x >= Tec_A + Tec_N
            set Tec_Niv[p * 64 + x] = Tec_Ini[x]
            set x = x + 1
        endloop
    endif
    call Tec_Aplicar(p)
endfunction

function Tec_Aprender takes integer p, integer x returns nothing
    if Tec_Niv[p * 64 + x] < Tec_Max[x] then
        set Tec_Niv[p * 64 + x] = Tec_Niv[p * 64 + x] + 1
    endif
    call Tec_Aplicar(p)
endfunction

function Tec_Des takes integer p, integer x returns string
    local integer n = Tec_Niv[p * 64 + x]
    if n >= Tec_Max[x] then
        return "Ya está al máximo|n(nivel " + I2S(n) + ")."
    elseif n == 0 then
        return "Aprende la técnica.|nTecla " + Tec_Tecla[x] + " en el libro V."
    endif
    return "Sube a nivel " + I2S(n + 1) + " de " + I2S(Tec_Max[x]) + ".|nTecla " + Tec_Tecla[x] + " en el libro V."
endfunction

// Cartas 2 y 3 (k + 1, k + 2) de una tanda: técnicas que aún se pueden aprender o subir, sin repetir.
function Tec_Cartas takes integer p, integer k returns nothing
    local integer array l
    local integer n = 0
    local integer x
    local integer s = 1
    local integer r
    call Tec_Rango(p)
    set x = Tec_A
    loop
        exitwhen x >= Tec_A + Tec_N
        if Tec_Niv[p * 64 + x] < Tec_Max[x] then
            set l[n] = x
            set n = n + 1
        endif
        set x = x + 1
    endloop
    loop
        exitwhen s > 2 or n <= 0
        set r = GetRandomInt(0, n - 1)
        set x = l[r]
        set n = n - 1
        set l[r] = l[n]
        set Cua_HCand[k + s] = x
        set Her_Cal[k + s] = IMinBJ(4, Tec_Niv[p * 64 + x])
        set s = s + 1
    endloop
endfunction
''' + tec_cmd + '''
function Tec_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
''' + datos + tec_reg + '''    set t = null
endfunction

''')
cambia('''    call Dres_Init()
''', '''    call Dres_Init()
    call Tec_Init()
''')
cambia('''    call Don_Armar(p, id)
''', '''    call Don_Armar(p, id)
    call Tec_Empezar(p)
''')
# cartas del héroe
cambia('''    if GetRandomInt(1, 100) <= 8 then
        set Cua_HCand[k + 3] = 28
        set Her_Cal[k + 3] = 0
    endif
''', '''    if GetRandomInt(1, 100) <= 8 then
        set Cua_HCand[k + 3] = 28
        set Her_Cal[k + 3] = 0
    endif
    call Tec_Cartas(p, k)
''')
cambia('''        if Her_Cal[k + i] >= 3 and Cua_HCand[k + i] != 28 then
''', '''        if Her_Cal[k + i] >= 3 and Cua_HCand[k + i] != 28 and Cua_HCand[k + i] < 40 then
''')
cambia('''    set x = Cua_HCand[Her_K(p, c)]
    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
''', '''    set x = Cua_HCand[Her_K(p, c)]
    if x >= 40 then
        return Tec_Des(p, x)
    endif
    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
''')
cambia('''    endif
    set Her_Log = "heroe "''', '''    elseif x >= 40 then
        call Tec_Aprender(p, x)
    endif
    set Her_Log = "heroe "''')
if prueba:
    for viejo, nuevo in (('lat\\\\v19j-', 'lat\\\\v19k-'), ('v19j-don.txt', 'v19k-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19k', 'prueba' if prueba else 'normal')
