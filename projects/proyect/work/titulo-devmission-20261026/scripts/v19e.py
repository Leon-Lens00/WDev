#!/usr/bin/env python3
"""v19e-prueba (19/11/2026), diagnóstico de las copias de D.O.N. Leon: "prepara una evaluacion de registros con cada
habilidad, asi tomas un mejor diagnostico de porque no se ejecuta, y que inicie en la wave 6", "varias habilidades no
se estan casteando con el dummy", "sobretodo en las DON".
Sólo variante de prueba (base v19d-prueba); el juego no cambia salvo que la partida empieza en la oleada 6.
Registro propio en lat\\v19e-don.txt (hasta 3000 líneas; se escribe 2 s después de la última o con "-reg"):
- "pulsa": cada botón de Goku/Freezer/Trunks/Naruto con la técnica real, orden, tipo de blanco, y el estado que decide
  si se lanza (down del par, héroe vivo/pausado, técnica en curso, copia ocupada, nivel en el héroe, distancia).
- "copia cN": la copia creada (tipo, nivel y maná de la técnica en la copia, distancia desde el héroe y al blanco,
  alcance usado) o "NO ACEPTA" si la orden se rechaza.
- "cN kK": muestras de la copia a 0,05 / 0,2 / 0,5 / 1 / 3 s (orden actual, pausada, oculta, cuánto se movió, curso).
- "ev": CHANNEL, CAST, EFFECT, ENDCAST y FINISH de copias y héroes de D.O.N, con la técnica y el tiempo de la copia.
- "cN libre" y "don fin cN": cuándo deja de estar ocupada y cuándo se quita.
Los registros de Tauren y Cairne (Cop_Anotar) también van a este archivo.
Uso: v19e.py ENTRADA.j (de v19d-prueba) SALIDA.j
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
U = lambda s: s.encode('utf-8').decode('latin-1')
CRLF = '\r\n' in src


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


cambia('integer Dcp_N = 0\n', 'integer Dcp_N = 0\n'
       'string array Dia_L\ninteger Dia_LN = 0\ntimer Dia_LT = null\ninteger Dia_Serie = 0\n'
       'integer array Dcp_Id\nreal array Dcp_X0\nreal array Dcp_Y0\n')

# --- registro propio ---
antes('function Dcp_Tipo takes unit u returns integer\n', r'''// v19e-prueba: diagnóstico de las copias de D.O.N en lat\v19e-don.txt.
function Dia_Escribir takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    loop
        exitwhen i >= Dia_LN
        call Preload(Dia_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\v19e-don.txt")
endfunction

function Dia_Anotar takes string s returns nothing
    if Sup_Tiempo == null then
        set Sup_Tiempo = CreateTimer()
        call TimerStart(Sup_Tiempo, 100000., false, null)
        set Sup_LT = CreateTimer()
    endif
    if Dia_LT == null then
        set Dia_LT = CreateTimer()
    endif
    if Dia_LN >= 3000 then
        return
    endif
    set Dia_L[Dia_LN] = R2S(TimerGetElapsed(Sup_Tiempo)) + " " + s
    set Dia_LN = Dia_LN + 1
    call TimerStart(Dia_LT, 2., false, function Dia_Escribir)
endfunction

function Dia_Id takes integer i returns string
    local string c = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    local string s = ""
    local integer k = 0
    local integer b
    if i <= 0 then
        return I2S(i)
    endif
    loop
        exitwhen k > 3
        set b = ModuloInteger(i, 256)
        if b >= 32 and b <= 126 then
            set s = SubString(c, b - 32, b - 31) + s
        else
            set s = "?" + s
        endif
        set i = i / 256
        set k = k + 1
    endloop
    return s
endfunction

function Dia_B takes boolean b returns string
    if b then
        return "1"
    endif
    return "0"
endfunction

function Dia_Orden takes unit u returns string
    local integer o = GetUnitCurrentOrder(u)
    local string s
    if o == 0 then
        return "-"
    endif
    set s = OrderId2String(o)
    if s == null then
        return I2S(o)
    endif
    return s
endfunction

function Dia_D takes real ax, real ay, real bx, real by returns string
    return I2S(R2I(SquareRoot((ax - bx) * (ax - bx) + (ay - by) * (ay - by))))
endfunction

''')

# --- Dcp_Lanzar: copia creada / rechazada ---
cambia('''    local integer i = Dcp_N
    if i >= 60 then
        return false
    endif
''', '''    local integer i = Dcp_N
    if i >= 60 then
        call Dia_Anotar("copia SIN SITIO: 60 copias vivas")
        return false
    endif
''')
cambia('''    if not ok then
        call RemoveUnit(c)
        set c = null
        return false
    endif
    set Dcp_N = i + 1
''', '''    if not ok then
        call Dia_Anotar("copia NO ACEPTA j" + I2S(p) + " " + Dia_Id(tc) + " " + Dia_Id(a) + " " + orden + " niv " + I2S(GetUnitAbilityLevel(c, a)) + " mana " + I2S(R2I(GetUnitState(c, UNIT_STATE_MANA))) + " desde heroe " + Dia_D(cx, cy, hx, hy) + " al blanco " + Dia_D(cx, cy, px, py) + " rango " + I2S(R2I(r)))
        call RemoveUnit(c)
        set c = null
        return false
    endif
    set Dia_Serie = Dia_Serie + 1
    set Dcp_Id[i] = Dia_Serie
    set Dcp_X0[i] = cx
    set Dcp_Y0[i] = cy
    set Dcp_N = i + 1
''')
cambia('''    set Cop_Log = "don copia j" + I2S(p) + " " + orden + " a " + I2S(R2I(SquareRoot((cx - hx) * (cx - hx) + (cy - hy) * (cy - hy))))
    call ExecuteFunc("Cop_Anotar")
''', '''    call Dia_Anotar("copia c" + I2S(Dia_Serie) + " j" + I2S(p) + " " + Dia_Id(tc) + " " + Dia_Id(a) + " " + orden + " niv " + I2S(GetUnitAbilityLevel(c, a)) + " mana " + I2S(R2I(GetUnitState(c, UNIT_STATE_MANA))) + " orden ya " + Dia_Orden(c) + " desde heroe " + Dia_D(cx, cy, hx, hy) + " al blanco " + Dia_D(cx, cy, px, py) + " rango " + I2S(R2I(r)))
''')

# --- eventos de hechizo de copias y héroes ---
viejo_ev = '''// v19d: registro de prueba cuando una copia lanza de verdad (evento de efecto).
function Dcp_Efecto takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local integer t = GetUnitTypeId(c)
    if t == 'hCpG' or t == 'hCpF' or t == 'hCpT' or t == 'hCpN' or t == 'hCpK' then
        set Cop_Log = "don efecto j" + I2S(GetPlayerId(GetOwningPlayer(c))) + " " + OrderId2String(GetUnitCurrentOrder(c))
        call ExecuteFunc("Cop_Anotar")
    endif
    set c = null
endfunction

function Dcp_EfectoInit takes nothing returns nothing
    local trigger g = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(g, function Dcp_Efecto)
    set g = null
endfunction
'''
nuevo_ev = '''// v19e-prueba: CHANNEL, CAST, EFFECT, ENDCAST y FINISH de las copias y de los héroes de D.O.N.
function Dcp_Efecto takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local integer t = GetUnitTypeId(c)
    local eventid e = GetTriggerEventId()
    local string s = "ev "
    local integer i = 0
    if t == 'hCpG' or t == 'hCpF' or t == 'hCpT' or t == 'hCpN' or t == 'hCpK' or t == 'hGok' or t == 'hFrz' or t == 'hTrk' or t == 'hNar' or t == 'hNaK' then
        if e == EVENT_PLAYER_UNIT_SPELL_CHANNEL then
            set s = s + "CHANNEL"
        elseif e == EVENT_PLAYER_UNIT_SPELL_CAST then
            set s = s + "CAST"
        elseif e == EVENT_PLAYER_UNIT_SPELL_EFFECT then
            set s = s + "EFFECT"
        elseif e == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
            set s = s + "ENDCAST"
        else
            set s = s + "FINISH"
        endif
        set s = s + " " + Dia_Id(t) + " " + Dia_Id(GetSpellAbilityId()) + " orden " + Dia_Orden(c)
        loop
            exitwhen i >= Dcp_N
            if Dcp_U[i] == c then
                set s = s + " c" + I2S(Dcp_Id[i]) + " k" + I2S(Dcp_K[i])
            endif
            set i = i + 1
        endloop
        call Dia_Anotar(s)
    endif
    set c = null
    set e = null
endfunction

function Dia_Reg takes nothing returns nothing
    call Dia_Escribir()
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 4., "Registro escrito: " + I2S(Dia_LN) + " líneas en CustomMapData\\\\lat\\\\v19e-don.txt")
endfunction

function Dcp_EfectoInit takes nothing returns nothing
    local trigger g = CreateTrigger()
    local integer p = 0
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_CAST)
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_FINISH)
    call TriggerAddAction(g, function Dcp_Efecto)
    set g = CreateTrigger()
    loop
        exitwhen p > 7
        call TriggerRegisterPlayerChatEvent(g, Player(p), "-reg", true)
        set p = p + 1
    endloop
    call TriggerAddAction(g, function Dia_Reg)
    set g = null
endfunction

// v19e-prueba: estado al pulsar un botón de D.O.N (antes de decidir si se lanza).
function Dia_Pulsa takes player pl, integer a, integer r, string orden, integer obj, boolean curso, integer this, unit t, real x, real y returns nothing
    local unit b
    local integer p = GetPlayerId(pl)
    local string s = "pulsa j" + I2S(p) + " " + Dia_Id(a) + " -> " + Dia_Id(r) + " " + orden + " obj " + I2S(obj)
    if this == 0 then
        set s = s + " SIN PAR"
    else
        set b = s__RapidPair_actor[this]
        set s = s + " down " + Dia_B(s__RapidPair_down[this]) + " heroe " + Dia_Id(GetUnitTypeId(b)) + " vivo " + Dia_B(UnitAlive(b)) + " pausa " + Dia_B(IsUnitPaused(b)) + " curso " + Dia_B(curso) + " ocupada " + Dia_B(Dcp_Ocupada(p)) + " niv " + I2S(GetUnitAbilityLevel(b, r))
        if GetUnitTypeId(b) == 'hGok' then
            set s = s + " cuerpo " + Dia_B(b == Gk_Cuerpo)
        endif
        if obj == 1 then
            if t == null then
                set s = s + " blanco NULO"
            else
                set s = s + " blanco " + Dia_Id(GetUnitTypeId(t)) + " a " + Dia_D(GetUnitX(b), GetUnitY(b), GetUnitX(t), GetUnitY(t))
            endif
        elseif obj == 2 then
            set s = s + " punto a " + Dia_D(GetUnitX(b), GetUnitY(b), x, y)
        endif
    endif
    call Dia_Anotar(s)
    set b = null
endfunction
'''
cambia(viejo_ev, nuevo_ev)

# --- Gk_Relevo ---
cambia('''    local unit b
    if this != 0 and not s__RapidPair_down[this] then
        set b = s__RapidPair_actor[this]
        if b == Gk_Cuerpo and UnitAlive(b) and not IsUnitPaused(b) then
''', '''    local unit b
    if a == 'AGk1' then
        call Dia_Pulsa(GetTriggerPlayer(), a, 'A00P', "ward", 2, false, this, t, x, y)
    elseif a == 'AGk2' then
        call Dia_Pulsa(GetTriggerPlayer(), a, 'A0IA', "thunderbolt", 1, false, this, t, x, y)
    elseif a == 'AGk3' then
        call Dia_Pulsa(GetTriggerPlayer(), a, 'A0BZ', "impale", 2, false, this, t, x, y)
    elseif a == 'AGk4' then
        call Dia_Pulsa(GetTriggerPlayer(), a, 'A0G2', "voodoo", 0, false, this, t, x, y)
    else
        call Dia_Pulsa(GetTriggerPlayer(), a, 'A01G', "rainoffire", 2, false, this, t, x, y)
    endif
    if this != 0 and not s__RapidPair_down[this] then
        set b = s__RapidPair_actor[this]
        if b == Gk_Cuerpo and UnitAlive(b) and not IsUnitPaused(b) then
''')

# --- Don_Relevo ---
cambia('''    if n < Don_Bots and this != 0 and not s__RapidPair_down[this] then
''', '''    if n < Don_Bots then
        call Dia_Pulsa(GetTriggerPlayer(), a, Don_BotReal[n], Don_BotOrden[n], Don_BotObj[n], Don_EnCurso(Don_BotReal[n]), this, t, x, y)
    else
        call Dia_Pulsa(GetTriggerPlayer(), a, 0, "?", 0, false, this, t, x, y)
    endif
    if n < Don_Bots and this != 0 and not s__RapidPair_down[this] then
''')

# --- Dcp_Tick: muestras, libre, fin ---
antes('function Dcp_Tick takes nothing returns nothing\n', '''// v19e-prueba: muestra del estado de la copia i.
function Dia_Muestra takes integer i returns nothing
    local unit c = Dcp_U[i]
    call Dia_Anotar("c" + I2S(Dcp_Id[i]) + " k" + I2S(Dcp_K[i]) + " " + Dia_Id(Dcp_A[i]) + " orden " + Dia_Orden(c) + " pausa " + Dia_B(IsUnitPaused(c)) + " oculta " + Dia_B(IsUnitHidden(c)) + " viva " + Dia_B(UnitAlive(c)) + " movio " + Dia_D(GetUnitX(c), GetUnitY(c), Dcp_X0[i], Dcp_Y0[i]) + " niv " + I2S(GetUnitAbilityLevel(c, Dcp_A[i])) + " curso " + Dia_B(Don_EnCurso(Dcp_A[i])) + " fase " + I2S(Dcp_F[i]))
    set c = null
endfunction

''')
cambia('''        set Dcp_K[i] = Dcp_K[i] + 1
        if Dcp_F[i] == 0 then
            if Dcp_K[i] >= 300 or (Dcp_K[i] >= 20 and not IsUnitPaused(c) and GetUnitCurrentOrder(c) == 0 and not IsUnitHidden(c)) then
                set Dcp_F[i] = 1
                set Dcp_S[i] = Dcp_K[i]
''', '''        set Dcp_K[i] = Dcp_K[i] + 1
        if Dcp_K[i] == 1 or Dcp_K[i] == 4 or Dcp_K[i] == 10 or Dcp_K[i] == 20 or Dcp_K[i] == 60 then
            call Dia_Muestra(i)
        endif
        if Dcp_F[i] == 0 then
            if Dcp_K[i] >= 300 or (Dcp_K[i] >= 20 and not IsUnitPaused(c) and GetUnitCurrentOrder(c) == 0 and not IsUnitHidden(c)) then
                call Dia_Anotar("c" + I2S(Dcp_Id[i]) + " libre k" + I2S(Dcp_K[i]) + " orden " + Dia_Orden(c) + " pausa " + Dia_B(IsUnitPaused(c)) + " oculta " + Dia_B(IsUnitHidden(c)))
                set Dcp_F[i] = 1
                set Dcp_S[i] = Dcp_K[i]
''')
cambia('''            set Cop_Log = "don fin j" + I2S(Dcp_P[i]) + " " + Dcp_O[i] + " t" + I2S(Dcp_S[i]) + " eco " + I2S(Dcp_EN[i]) + " dano " + I2S(R2I(Dcp_ED[i]))
            call ExecuteFunc("Cop_Anotar")
''', '''            call Dia_Anotar("don fin c" + I2S(Dcp_Id[i]) + " j" + I2S(Dcp_P[i]) + " " + Dcp_O[i] + " libre en k" + I2S(Dcp_S[i]) + " quitada en k" + I2S(Dcp_K[i]) + " eco " + I2S(Dcp_EN[i]) + " dano " + I2S(R2I(Dcp_ED[i])))
''')
cambia('''            set Dcp_ED[i] = Dcp_ED[j]
            set Dcp_U[j] = null
''', '''            set Dcp_ED[i] = Dcp_ED[j]
            set Dcp_Id[i] = Dcp_Id[j]
            set Dcp_X0[i] = Dcp_X0[j]
            set Dcp_Y0[i] = Dcp_Y0[j]
            set Dcp_U[j] = null
''')

# --- Tauren y Cairne al mismo archivo ---
cambia('''function Cop_Anotar takes nothing returns nothing
    call Bolsa_Anotar(Cop_Log)
endfunction
''', '''function Cop_Anotar takes nothing returns nothing
    call Dia_Anotar(Cop_Log)
endfunction
''')

# --- empezar en la oleada 6 ---
cambia('''    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
    call Ronda_Lanzar()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Prueba: -mut N suma la Mutación Evo N (0-17) desde la oleada siguiente; -punt sigue.")
''', '''    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
    set Ronda_Numero = 6
    call Dia_Anotar("empieza en la oleada 6")
    call Ronda_Lanzar()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Diagnóstico D.O.N: empieza en la oleada 6; usa cada técnica y escribe -reg para guardar lat\\\\v19e-don.txt.")
''')

n = src.count('lat\\\\v19d-')
assert n > 0, n
src = src.replace('lat\\\\v19d-', 'lat\\\\v19e-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19e prueba')
