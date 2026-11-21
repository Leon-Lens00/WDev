#!/usr/bin/env python3
"""v16t-goku (13/11/2026): Goku de D.O.N 1.8c sobre v16t-ivan, como personaje de la pareja de Dev Mission.

- El jugador que elige la celda 0 (Tauren) recibe a Goku ('hGok', unidad normal con los parámetros del Tauren h005);
  hay un solo Goku (el código de D.O.N usa huecos fijos), para el primer jugador humano que lo pide.
- El cuerpo visible lleva las habilidades reales de D.O.N (sin enfriamiento ni maná). El controlador lleva cinco
  botones Canal (AGk1..AGk5, 1 de maná, sin enfriamiento, alcance infinito): al lanzarlos se corta la ráfaga o el dash
  del movimiento artificial y se ordena al cuerpo lanzar la habilidad real; el código de D.O.N corre tal cual.
- Movimiento artificial: mientras D.O.N tiene pausado el cuerpo (Kamehameha, Warp, Dragon Fist, Spirit Bomb) el
  disparo, el dash y el clic de movimiento no actúan (el controlador se aparca igual); disparar o hacer dash corta la
  carga del SSJ o de la Spirit Bomb.
- Temblor de cámara: Sacude_Mag[p] desplaza la cámara lógica en FollowCamera; la interfaz se proyecta desde esa misma
  cámara y tiembla con ella en lugar de quedarse movida.
Uso: goku_v16t.py v16t-ivan/war3map.j GLOBALES.j FUNCIONES.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
glob = crlf(Path(sys.argv[2]).read_bytes())
func = crlf(Path(sys.argv[3]).read_bytes())


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('latin-1')), crlf(despues.encode('latin-1'))
    assert j.count(antes) == 1, (antes[:80], j.count(antes))
    j = j.replace(antes, despues)


GLOB = """// v16t-goku: Goku de D.O.N 1.8c (goku_trasplante.py y goku_v16t.py).
integer Gk_Dueno = -1
integer Gk_Nivel = 10
unit Gk_Cuerpo = null
integer Gk_OrdenSSJ = 0
integer Gk_OrdenBomba = 0
real array Gk_TTFin
real array Sacude_Mag
"""

ANTES = """// ---- v16t-goku: Goku de Battle Stadium D.O.N 1.8c, atado a la pareja de Dev Mission ----
// Goku es una unidad normal: la fuerza de D.O.N (25 +3,5 por nivel) sale de Gk_Nivel (comando -gk N).
function Gk_Fuerza takes unit u returns integer
    return R2I(25. + 3.5 * I2R(Gk_Nivel - 1))
endfunction

// A quién le tiembla la cámara: los personajes de los jugadores (en D.O.N, los héroes).
function Gk_EsCuerpo takes unit u returns boolean
    local integer p = 0
    loop
        exitwhen p > 11
        if Game_On[p] and u == Game_Hero[p] then
            return true
        endif
        set p = p + 1
    endloop
    return false
endfunction

// Temblor por script, en lugar del ruido nativo de cámara: FollowCamera mueve la cámara lógica hasta Sacude_Mag y la
// interfaz, que se proyecta desde ella, se mueve con la cámara. Amplitudes como en Blizzard.j (EQ: 2 x magnitud).
function Gk_SacudeEQ takes player pl, real m returns nothing
    local integer p = GetPlayerId(pl)
    if p < 12 then
        set Sacude_Mag[p] = 2. * m
    endif
endfunction

function Gk_SacudeBlanco takes player pl, real m, real v returns nothing
    local integer p = GetPlayerId(pl)
    if p < 12 then
        set Sacude_Mag[p] = RMaxBJ(Sacude_Mag[p], m)
    endif
endfunction

function Gk_SacudeQuitar takes player pl returns nothing
    local integer p = GetPlayerId(pl)
    if p < 12 then
        set Sacude_Mag[p] = 0.
    endif
endfunction

// Textos flotantes de D.O.N con 20 huecos como máximo: el mapa entero tiene 100 y la interfaz usa los suyos.
function Gk_TT takes string s, unit u, real z, real size, real r, real g, real b, real tr, real vel, real ang, real life returns nothing
    local real now = TimerGetElapsed(s__RapidPair_clock)
    local integer i = 0
    loop
        exitwhen i >= 20
        if Gk_TTFin[i] <= now then
            set Gk_TTFin[i] = now + life + 0.5
            call CreateTextTagUnitBJ(s, u, z, size, r, g, b, tr)
            call SetTextTagVelocityBJ(bj_lastCreatedTextTag, vel, ang)
            call SetTextTagPermanentBJ(bj_lastCreatedTextTag, false)
            call SetTextTagLifespanBJ(bj_lastCreatedTextTag, life)
            return
        endif
        set i = i + 1
    endloop
endfunction

"""

DESPUES = """
// Celda 0 (Tauren) -> Goku, para un solo jugador humano: el código de D.O.N usa huecos fijos.
function Gk_Toca takes integer p returns boolean
    if Hero_Choice[p] != 0 then
        return false
    endif
    if Gk_Dueno < 0 and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
        set Gk_Dueno = p
    endif
    return Gk_Dueno == p
endfunction

// Botones del controlador (antes de Silence_HideMove, como Arp1 y Ard1).
function Gk_Botones takes integer p returns nothing
    call UnitAddAbility(Game_Ctrl[p], 'AGk1')
    call UnitAddAbility(Game_Ctrl[p], 'AGk2')
    call UnitAddAbility(Game_Ctrl[p], 'AGk3')
    call UnitAddAbility(Game_Ctrl[p], 'AGk4')
    call UnitAddAbility(Game_Ctrl[p], 'AGk5')
endfunction

// Habilidades reales en el cuerpo, al nivel máximo de D.O.N, y Goku en su forma base (también al reaparecer).
function Gk_Armar takes integer p returns nothing
    local unit b = Game_Hero[p]
    set Gk_Cuerpo = b
    call UnitAddAbility(b, 'A00P')
    call SetUnitAbilityLevel(b, 'A00P', 4)
    call UnitAddAbility(b, 'A0IA')
    call SetUnitAbilityLevel(b, 'A0IA', 4)
    call UnitAddAbility(b, 'A0BZ')
    call SetUnitAbilityLevel(b, 'A0BZ', 3)
    call UnitAddAbility(b, 'A0G2')
    call UnitAddAbility(b, 'A01G')
    call UnitAddAbility(b, 'A0IQ')
    call SetUnitAbilityLevel(b, 'A0IQ', 4)
    call UnitAddAbility(b, 'A069')
    call DisableTrigger(GkV_Ba)
    call DisableTrigger(GkV_ba)
    set GkV_s8[$B18] = b
    set GkV_n8[$B18] = 1
    set GkV_o8[$B18] = false
    set GkV_n8[$B1B] = 0
    set b = null
endfunction

// Botón del controlador -> habilidad real del cuerpo. Antes se cierran la ráfaga y el dash del movimiento artificial.
function Gk_Relevo takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local integer a = GetSpellAbilityId()
    local unit t = GetSpellTargetUnit()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local unit b
    if this != 0 and not s__RapidPair_down[this] then
        set b = s__RapidPair_actor[this]
        if b == Gk_Cuerpo and UnitAlive(b) and not IsUnitPaused(b) then
            call s__RapidPair_endDash(this, false)
            call s__RapidPair_finish(this, false)
            set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
            if a == 'AGk1' then
                // A00P es Serpent Ward (AOsw): su orden es ward (corrección del 13/11; shockwave no la lanzaba).
                call IssuePointOrder(b, "ward", x, y)
            elseif a == 'AGk2' then
                call IssueTargetOrder(b, "thunderbolt", t)
            elseif a == 'AGk3' then
                call IssuePointOrder(b, "impale", x, y)
            elseif a == 'AGk4' then
                call IssueImmediateOrder(b, "voodoo")
            else
                call IssuePointOrder(b, "rainoffire", x, y)
            endif
        endif
        set b = null
    endif
    set t = null
endfunction

function Gk_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer n = S2I(SubString(s, 4, StringLength(s)))
    if n >= 1 and n <= 100 then
        set Gk_Nivel = n
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 5., "Goku: nivel " + I2S(n) + ", fuerza " + I2S(Gk_Fuerza(null)))
    endif
endfunction

function Gk_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    call Gk_InitDON()
    set Gk_OrdenSSJ = OrderId("voodoo")
    set Gk_OrdenBomba = OrderId("rainoffire")
    call RegisterSpellEffectEvent('AGk1', function Gk_Relevo)
    call RegisterSpellEffectEvent('AGk2', function Gk_Relevo)
    call RegisterSpellEffectEvent('AGk3', function Gk_Relevo)
    call RegisterSpellEffectEvent('AGk4', function Gk_Relevo)
    call RegisterSpellEffectEvent('AGk5', function Gk_Relevo)
    loop
        exitwhen i > 11
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-gk ", false)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function Gk_Comando)
    set t = null
endfunction
// ---- fin de v16t-goku ----

"""

CORTA = """        // v16t-goku: disparar o hacer dash corta la carga del SSJ o de la Spirit Bomb.
        if s__RapidPair_actor[this] == Gk_Cuerpo and (GetUnitCurrentOrder(Gk_Cuerpo) == Gk_OrdenSSJ or GetUnitCurrentOrder(Gk_Cuerpo) == Gk_OrdenBomba) then
            call IssueImmediateOrderById(Gk_Cuerpo, 851972)
        endif
"""

assert j.count(b'\r\nendglobals\r\n') == 1
j = j.replace(b'\r\nendglobals\r\n', b'\r\n' + crlf(GLOB.encode('latin-1')) + glob + b'endglobals\r\n')
una('\nfunction Game_Cuerpo takes integer p,real x,real y returns nothing\n',
    '\n' + ANTES + func.decode('latin-1').replace('\r\n', '\n') + DESPUES + 'function Game_Cuerpo takes integer p,real x,real y returns nothing\n')
una("""    if Hero_Choice[p] == 1 then
        set id='h006'
    endif
    set Game_Hero[p]=CreateUnit(Player(p), id, x, y, 270)
""", """    if Hero_Choice[p] == 1 then
        set id='h006'
    endif
    if Gk_Toca(p) then
        set id='hGok'
    endif
    set Game_Hero[p]=CreateUnit(Player(p), id, x, y, 270)
""")
una("""    call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
    call Silence_HideMove(Game_Ctrl[p])
""", """    call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
    if id == 'hGok' then
        call Gk_Botones(p)
    endif
    call Silence_HideMove(Game_Ctrl[p])
""")
una("""    call Arm_Pareja(p)
    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)
""", """    call Arm_Pareja(p)
    if id == 'hGok' then
        call Gk_Armar(p)
    endif
    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)
""")
una("""    call Game_Cuerpo(p , GetLocationX(start) , GetLocationY(start))
""", """    call Game_Cuerpo(p , GetLocationX(start) , GetLocationY(start))
    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon='hbi3'
    endif
""")
una("""        call s__UnitHitShape_register('h006' , 2. , 48.)
""", """        call s__UnitHitShape_register('h006' , 2. , 48.)
        call s__UnitHitShape_register('hGok' , 1.6 , 48.) // v16t-goku: como h005
""")
una("""                set z=UserInterface_GetTerrainZ(x , y) + GetUnitFlyHeight(u)
                call s__Camera_setPosition(cam,x , y , z)
""", """                set z=UserInterface_GetTerrainZ(x , y) + GetUnitFlyHeight(u)
                // v16t-goku: temblor por script (Gk_Sacude*): cámara e interfaz se mueven juntas.
                if Sacude_Mag[p] > 0. then
                    set x=x + GetRandomReal(- Sacude_Mag[p], Sacude_Mag[p])
                    set y=y + GetRandomReal(- Sacude_Mag[p], Sacude_Mag[p])
                    set z=z + GetRandomReal(- Sacude_Mag[p], Sacude_Mag[p])
                endif
                call s__Camera_setPosition(cam,x , y , z)
""")
# Guardas del movimiento artificial mientras D.O.N tiene pausado el cuerpo.
una("""            if order == 851986 or order == 851971 then
                call s__GroundMotion_destination(s__RapidPair_motion[(this)],((GetOrderPointX() )*1.0) , (( GetOrderPointY())*1.0)) // INLINED!!
""", """            if order == 851986 or order == 851971 then
                // v16t-goku: con el cuerpo pausado por una habilidad, el clic no mueve (el controlador se aparca igual).
                if not IsUnitPaused(s__RapidPair_actor[this]) then
                    call s__GroundMotion_destination(s__RapidPair_motion[(this)],((GetOrderPointX() )*1.0) , (( GetOrderPointY())*1.0)) // INLINED!!
                endif
""")
una("""        local integer p= GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if this != 0 and not s__RapidPair_down[this] then
            call s__RapidPair_castFamily(""", """        local integer p= GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if this != 0 and not s__RapidPair_down[this] and not IsUnitPaused(s__RapidPair_actor[this]) then
            call s__RapidPair_castFamily(""")
una("""        if this != 0 then
            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())
""", """        if this != 0 and not IsUnitPaused(s__RapidPair_actor[this]) then
            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())
""")
una("""        set s__RapidPair_firing[this]=true
        set s__RapidPair_bursts=s__RapidPair_bursts + 1
""", CORTA + """        set s__RapidPair_firing[this]=true
        set s__RapidPair_bursts=s__RapidPair_bursts + 1
""")
una("""        call s__RapidPair_hideDash(this)
        // The dash replaces the burst and its artificial walk, and cancels a reload.
""", CORTA + """        call s__RapidPair_hideDash(this)
        // The dash replaces the burst and its artificial walk, and cancels a reload.
""")
una("""    call Ivan_Init()
""", """    call Ivan_Init()
    call ExecuteFunc("Gk_Init")
""")
Path(sys.argv[4]).write_bytes(j)
print('goku: globales, funciones, pareja, botones puente, guardas, temblor, icono, -gk')
