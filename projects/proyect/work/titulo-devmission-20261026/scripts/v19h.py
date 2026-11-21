#!/usr/bin/env python3
"""v19h (19/11/2026), tras probar v19g (Leon: "evalua bien las habilidades y verifica que no queden reciduos tanto en
la spell como con los dommy de jugador, ejemplo este dummy se quedo con el de naruto rasen shuriken"):
- Barrido de restos: cada 0,5 s mira las unidades de los jugadores 0-5. Las de los 92 tipos de pieza que crean las
  técnicas de D.O.N (GkF_/FzF_/TrF_/NaF_) se anotan la primera vez que se ven; si siguen ahí a los 15 s se quitan. La
  pieza más larga de D.O.N vive 10 s (Dragon Fist, disco). El grupo guarda la referencia hasta purgarla, así el
  número del handle no se recicla con la anotación vieja.
- Copias: al terminar de desvanecerse sueltan las diez piezas de forma (A069, A06A, A06B, A0JO, A00Y, A0G4, A07X,
  A03Z, A0AO, A0HX: cabezas y auras de Super Saiyan, espada, ojos) y, si algo las vuelve a mostrar, se ocultan de nuevo.
- Prueba: anota cada pieza que llega a 8 s y cada resto quitado (tipo, edad, posición), y muestras de la copia a
  los 5, 10 y 15 s. Registro en lat\\v19h-don.txt.
Uso: v19h.py ENTRADA.j SALIDA.j [prueba]   (normal de v19g; prueba de v19g-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


def antes(marca, nuevo):
    cambia(marca, nuevo + marca)


PIEZAS = '''h002 h00A h00E h00F h00G h00H h00J h00M h00T h00V h01B h01E h01J h01M h01N h01R h01S h01T h02G h02J h039 h03A
h03I h03L h03M h04N h052 h054 h056 h05B h05E h05F h05H h05J h05X h061 h064 h065 h06E h06F h06G h070 h07B h07D h07H h07I
h080 h087 h08L h091 h092 h09N h09P h09T h0A4 h0A5 h0A7 h0BB h0BI h0BO h0CA h0CB h0CH h0CI h0D2 h0D3 h0DH h0DI h0DL
h0DM h0DN h0E2 h0EN h0ES h0ET h0EV h0EY h0F3 h0FB h0FI h0FW h0G1 h0GB h0GE h0GF h0GG h0GH h0GY h0H0 h0H1 h0H2
h0HH'''.split()
assert len(PIEZAS) == 92 and len(set(PIEZAS)) == 92
for p in PIEZAS:
    assert ("'%s'" % p) in src, p

cambia('integer Dcp_N = 0\n', 'integer Dcp_N = 0\n'
       'hashtable Dres_H = null\ngroup Dres_G = null\ngroup Dres_E = null\ninteger Dres_T = 0\n')

# --- copias: soltar piezas y seguir ocultas ---
cambia('''function Dcp_Pieza takes unit b, unit c, integer a returns nothing
    if GetUnitAbilityLevel(b, a) > 0 then
        call UnitAddAbility(c, a)
        call SetUnitAbilityLevel(c, a, GetUnitAbilityLevel(b, a))
    endif
endfunction
''', '''function Dcp_Pieza takes unit b, unit c, integer a returns nothing
    if GetUnitAbilityLevel(b, a) > 0 then
        call UnitAddAbility(c, a)
        call SetUnitAbilityLevel(c, a, GetUnitAbilityLevel(b, a))
    endif
endfunction

// v19h: al desvanecerse, la copia suelta las piezas de forma que se le pusieron al crearla.
function Dcp_Suelta takes unit c returns nothing
    call UnitRemoveAbility(c, 'A069')
    call UnitRemoveAbility(c, 'A06A')
    call UnitRemoveAbility(c, 'A06B')
    call UnitRemoveAbility(c, 'A0JO')
    call UnitRemoveAbility(c, 'A00Y')
    call UnitRemoveAbility(c, 'A0G4')
    call UnitRemoveAbility(c, 'A07X')
    call UnitRemoveAbility(c, 'A03Z')
    call UnitRemoveAbility(c, 'A0AO')
    call UnitRemoveAbility(c, 'A0HX')
endfunction
''')
cambia('''                set Dcp_F[i] = 2
                call ShowUnit(c, false)
            endif
            call SetUnitVertexColor(c, 140, 210, 255, al)
        endif
''', '''                set Dcp_F[i] = 2
                call ShowUnit(c, false)
                call Dcp_Suelta(c)
            endif
            call SetUnitVertexColor(c, 140, 210, 255, al)
        elseif not IsUnitHidden(c) then
            call SetUnitVertexColor(c, 140, 210, 255, 0)
            call ShowUnit(c, false)
        endif
''')

# --- barrido de restos ---
if prueba:
    aviso8 = '''                    if e == 16 then
                        call Dia_Anotar("pieza larga " + Dia_Id(GetUnitTypeId(u)) + " j" + I2S(p) + " 8 s en " + I2S(R2I(GetUnitX(u))) + " " + I2S(R2I(GetUnitY(u))) + " viva " + Dia_B(UnitAlive(u)) + " oculta " + Dia_B(IsUnitHidden(u)))
                    endif
'''
    aviso15 = '''                        call Dia_Anotar("resto " + Dia_Id(GetUnitTypeId(u)) + " j" + I2S(p) + " quitado a los " + I2S(e / 2) + " s en " + I2S(R2I(GetUnitX(u))) + " " + I2S(R2I(GetUnitY(u))) + " viva " + Dia_B(UnitAlive(u)) + " oculta " + Dia_B(IsUnitHidden(u)))
'''
else:
    aviso8 = aviso15 = ''
init = ''.join("    call SaveBoolean(Dres_H, 1, '%s', true)\n" % p for p in PIEZAS)
antes('function Don_Init takes nothing returns nothing\n', '''// v19h: barrido de restos de las técnicas de D.O.N (piezas con más de 15 s; la más larga dura 10 s).
function Dres_Purga takes nothing returns nothing
    local unit u = GetEnumUnit()
    if GetUnitTypeId(u) == 0 then
        call RemoveSavedInteger(Dres_H, 0, GetHandleId(u))
        call GroupRemoveUnit(Dres_G, u)
    endif
    set u = null
endfunction

function Dres_Tick takes nothing returns nothing
    local integer p = 0
    local integer e
    local unit u
    set Dres_T = Dres_T + 1
    call ForGroup(Dres_G, function Dres_Purga)
    loop
        exitwhen p > 5
        call GroupEnumUnitsOfPlayer(Dres_E, Player(p), null)
        loop
            set u = FirstOfGroup(Dres_E)
            exitwhen u == null
            call GroupRemoveUnit(Dres_E, u)
            if HaveSavedBoolean(Dres_H, 1, GetUnitTypeId(u)) then
                if not IsUnitInGroup(u, Dres_G) then
                    call GroupAddUnit(Dres_G, u)
                    call SaveInteger(Dres_H, 0, GetHandleId(u), Dres_T)
                else
                    set e = Dres_T - LoadInteger(Dres_H, 0, GetHandleId(u))
''' + aviso8 + '''                    if e >= 30 then
''' + aviso15 + '''                        call RemoveUnit(u)
                    endif
                endif
            endif
        endloop
        set p = p + 1
    endloop
    set u = null
endfunction

function Dres_Init takes nothing returns nothing
    set Dres_H = InitHashtable()
    set Dres_G = CreateGroup()
    set Dres_E = CreateGroup()
''' + init + '''    call TimerStart(CreateTimer(), 0.5, true, function Dres_Tick)
endfunction

''')
cambia('''    call TimerStart(CreateTimer(), 0.05, true, function Dcp_Tick)
''', '''    call TimerStart(CreateTimer(), 0.05, true, function Dcp_Tick)
    call Dres_Init()
''')
if prueba:
    cambia('Dcp_K[i] == 20 or Dcp_K[i] == 60 then',
           'Dcp_K[i] == 20 or Dcp_K[i] == 60 or Dcp_K[i] == 100 or Dcp_K[i] == 200 or Dcp_K[i] == 300 then')
    for viejo, nuevo in (('lat\\\\v19g-', 'lat\\\\v19h-'), ('v19g-don.txt', 'v19h-don.txt')):
        assert viejo in src
        src = src.replace(viejo, nuevo)
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19h', 'prueba' if prueba else 'normal')
