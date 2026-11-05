"""Dev Mission v12s (31/10/2026): spawn points over the arena, Shots Vol. I as the only attack, and an internal bot.

The bot takes the first free slot when the game has at most Bot_HUMANOS humans. It plays with the other character through the same orders
as a player: 'smart', 'carrionswarm', 'stomp' and 'thunderclap' on its controller. Everything runs on all clients from synchronized state.

Usage: bot_v12s.py IN_J OUT_J EXTRACTED_DIR
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base
from puntos_v12s import points

GLOBAL_OLD = 'integer Ronda_Wave = 0\n'
GLOBAL_NEW = GLOBAL_OLD + '''constant integer Bot_HUMANOS = 1
constant real Bot_TICK = 0.2
constant real Bot_VISTA = 8000.
constant real Bot_TIRO = 850.
constant real Bot_PELIGRO = 240.
constant real Bot_ALEJAR = 380.
constant real Bot_CERCA = 500.
constant real Bot_ACERCAR = 700.
constant real Bot_PUESTO = 550.
constant real Bot_CORREA = 700.
constant real Bot_CAZA = 12.
constant real Bot_DEFENSA = 800.
constant real Bot_BALA = 1200.
constant real Bot_ESPERA_DASH = 3.
constant real Ronda_DISTANCIA = 900.
integer Bot_P = -1
timer Bot_Reloj = null
group Bot_Grupo = null
boolexpr Bot_Filtro = null
unit Bot_Blanco = null
real Bot_Dist = 0.
real Bot_Valor = 0.
real Bot_X = 0.
real Bot_Y = 0.
real Bot_LX = 0.
real Bot_LY = 0.
unit Bot_Previo = null
real Bot_PX = 0.
real Bot_PY = 0.
real Bot_VX = 0.
real Bot_VY = 0.
integer Bot_Paso = 0
integer Bot_Giro = 0
real Bot_Visto = 0.
real Bot_HuirX = 0.
real Bot_HuirY = 0.
real Bot_MetaX = 0.
real Bot_MetaY = 0.
real Bot_DashListo = 0.
'''
POINT_OLD = '''        call s__Wave_addPoint(w,x - DevWave__POINT_OFFSET , y)
        call s__Wave_addPoint(w,x + DevWave__POINT_OFFSET , y)
        call s__Wave_addPoint(w,x , y + DevWave__POINT_OFFSET)
        call s__Wave_addPoint(w,x , y - DevWave__POINT_OFFSET)
'''
POINT_NEW = '        call DevWave_Puntos(w)\n'
CHANCE_OLD = 's__Wave_create(WaveDifficultyOwnerCap() , 15 , 0.25 , n , Ronda_TOTAL)'
CHANCE_NEW = 's__Wave_create(WaveDifficultyOwnerCap() , 0 , 0.25 , n , Ronda_TOTAL)'
START_OLD = '    function DevWave_Start takes integer n returns nothing\n'
SHOT_OLD = """    call UnitAddAbility(Game_Ctrl[p], 'Arpf')
    call UnitAddAbility(Game_Ctrl[p], 'Arp1')
    call UnitAddAbility(Game_Ctrl[p], 'Arp3')
"""
SHOT_NEW = """    call UnitAddAbility(Game_Ctrl[p], 'Arp1')
"""
REST_OLD = 'if Game_On[p] and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then\n'
REST_NEW = 'if Game_On[p] and ( p == Bot_P or GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING ) then\n'
ENTER_OLD = '    call TimerStart(CreateTimer(), 3., false, function DevWave_Arrancar)\n'
ENTER_NEW = '    call Bot_Entrar()\n' + ENTER_OLD
ANCHOR = 'function ConversationUI___Start takes nothing returns nothing\n'
ICON = (('constant real Ronda_ICONO_Y = 84.\n', 'constant real Ronda_ICONO_Y = 106.\n'), ('constant real Ronda_TITULO_Y = 68.\n', 'constant real Ronda_TITULO_Y = 90.\n'),
        ('constant real Ronda_CIFRA_Y = 104.\n', 'constant real Ronda_CIFRA_Y = 126.\n'))
ALLY_OLD = """            if i != j then
                call SetPlayerAllianceStateBJ(Player(i), Player(j), bj_ALLIANCE_ALLIED_VISION)
"""
ALLY_NEW = """            // Only the 8 player slots: 8 to 11 own wave units, which must stay hostile.
            if i != j and i < 8 and j < 8 then
                call SetPlayerAllianceStateBJ(Player(i), Player(j), bj_ALLIANCE_ALLIED_VISION)
"""
TINT_OLD = '''        call SetUnitVertexColor(Ronda_Icono[p], 225, 28, 28, alpha)
    else
        call SetUnitVertexColor(Ronda_Icono[p], 44, 44, 48, alpha)
'''
TINT_NEW = '''        call SetUnitVertexColor(Ronda_Icono[p], 255, 255, 255, alpha)
    else
        call SetUnitVertexColor(Ronda_Icono[p], 150, 150, 160, alpha)
'''
TINT_NOTE_OLD = '// The icon is red in the rest and dark during a wave, so the red title stays readable.\n'
TINT_NOTE_NEW = '// The icon dims during a wave, so the red title stays readable.\n'

BOT = '''// Nearest enemy, but one on top of the human comes first.
function Bot_Mira takes nothing returns boolean
    local unit u = GetFilterUnit()
    local integer o = GetPlayerId(GetOwningPlayer(u))
    local real dx
    local real dy
    local real d
    local real v
    if o >= 8 and o <= 13 and UnitAlive(u) then
        set dx = GetUnitX(u) - Bot_X
        set dy = GetUnitY(u) - Bot_Y
        set d = SquareRoot(dx * dx + dy * dy)
        set v = d
        if d < Bot_CERCA and d > 1. then
            set Bot_HuirX = Bot_HuirX - dx / d
            set Bot_HuirY = Bot_HuirY - dy / d
        endif
        set dx = GetUnitX(u) - Bot_LX
        set dy = GetUnitY(u) - Bot_LY
        if dx * dx + dy * dy < Bot_DEFENSA * Bot_DEFENSA then
            set v = v - Bot_DEFENSA
        endif
        if v < Bot_Valor then
            set Bot_Valor = v
            set Bot_Dist = d
            set Bot_Blanco = u
        endif
    endif
    set u = null
    return false
endfunction

function Bot_Libre takes real x,real y returns boolean
    return not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
endfunction

function Bot_Ir takes real x,real y returns nothing
    local real dx = x - Bot_MetaX
    local real dy = y - Bot_MetaY
    local integer m = s__RapidPair_motion[Game_Pair[Bot_P]]
    if Bot_Libre(x, y) and ( dx * dx + dy * dy > 10000. or not s__GroundMotion_hasGoal[m] ) then
        set Bot_MetaX = x
        set Bot_MetaY = y
        call IssuePointOrder(Game_Ctrl[Bot_P], "smart", x, y)
    endif
endfunction

// Measured speed of the target: an order says nothing about a unit that hits in place.
function Bot_Medir takes nothing returns nothing
    local real x = GetUnitX(Bot_Blanco)
    local real y = GetUnitY(Bot_Blanco)
    set Bot_VX = 0.
    set Bot_VY = 0.
    if Bot_Blanco == Bot_Previo then
        set Bot_VX = ( x - Bot_PX ) / Bot_TICK
        set Bot_VY = ( y - Bot_PY ) / Bot_TICK
    endif
    set Bot_Previo = Bot_Blanco
    set Bot_PX = x
    set Bot_PY = y
endfunction

// The same test a bolt runs in flight: slopes and walls stop it, so there is no point in firing there.
function Bot_Linea takes nothing returns boolean
    return s__GroundCollision_trace(Bot_X , Bot_Y , GetUnitX(Bot_Blanco) , GetUnitY(Bot_Blanco) , 6. , Game_Hero[Bot_P] , Player(Bot_P) , false) == 0
endfunction

// Recasting refills the burst and turns it toward where the target will be.
function Bot_Disparar takes nothing returns nothing
    local real t = Bot_Dist / Bot_BALA
    call IssuePointOrder(Game_Ctrl[Bot_P], "carrionswarm", GetUnitX(Bot_Blanco) + Bot_VX * t, GetUnitY(Bot_Blanco) + Bot_VY * t)
endfunction

// Tries straight away from the enemies around, then to both sides.
function Bot_Alejar takes nothing returns nothing
    local real base = Atan2(Bot_HuirY, Bot_HuirX) + 0.8 * Bot_Giro
    local integer k = 0
    local real a
    loop
        exitwhen k > 4
        set a = base + 0.8 * ( ( k + 1 ) / 2 ) * ( 1 - 2 * ( k - k / 2 * 2 ) )
        if Bot_Libre(Bot_X + 420. * Cos(a), Bot_Y + 420. * Sin(a)) then
            call Bot_Ir(Bot_X + 420. * Cos(a), Bot_Y + 420. * Sin(a))
            return
        endif
        set k = k + 1
    endloop
endfunction

function Bot_Dashear takes integer par returns boolean
    local real t = TimerGetElapsed(s__RapidPair_clock)
    local real a
    local real m = GetUnitState(Game_Ctrl[Bot_P], UNIT_STATE_MANA)
    if t < Bot_DashListo or m < 1. or s__GroundMotion_dashing[s__RapidPair_motion[par]] then
        return false
    endif
    if Bot_Dist < Bot_PELIGRO and s__RapidPair_firing[par] then
        set a = Atan2(Bot_Y - s__RapidPair_aimY[par], Bot_X - s__RapidPair_aimX[par])
        if Bot_Libre(Bot_X + 450. * Cos(a), Bot_Y + 450. * Sin(a)) then
            set Bot_DashListo = t + Bot_ESPERA_DASH
            return IssueImmediateOrder(Game_Ctrl[Bot_P], "thunderclap")
        endif
    elseif Bot_Dist > Bot_ACERCAR and m >= 3. and not s__RapidPair_firing[par] then
        set a = GetUnitFacing(Game_Hero[Bot_P]) * bj_DEGTORAD
        if Cos(a - Atan2(GetUnitY(Bot_Blanco) - Bot_Y, GetUnitX(Bot_Blanco) - Bot_X)) > 0.85 and Bot_Libre(Bot_X + 450. * Cos(a), Bot_Y + 450. * Sin(a)) then
            set Bot_DashListo = t + Bot_ESPERA_DASH
            return IssueImmediateOrder(Game_Ctrl[Bot_P], "stomp")
        endif
    endif
    return false
endfunction

function Bot_Seguir takes real lx,real ly,real d returns nothing
    if d > 320. then
        call Bot_Ir(lx + 200. * ( Bot_X - lx ) / d, ly + 200. * ( Bot_Y - ly ) / d)
    endif
endfunction

function Bot_Tick takes nothing returns nothing
    local integer par = Game_Pair[Bot_P]
    local integer m
    local real d
    local boolean linea
    local boolean suelto
    if par == 0 or not Vidas_EnPartida[Bot_P] or s__RapidPair_down[par] or not UnitAlive(Game_Hero[Bot_P]) then
        return
    endif
    set m = s__RapidPair_motion[par]
    set Bot_Paso = Bot_Paso + 1
    set Bot_X = GetUnitX(Game_Hero[Bot_P])
    set Bot_Y = GetUnitY(Game_Hero[Bot_P])
    set Bot_LX = GetUnitX(Game_Hero[Game_First])
    set Bot_LY = GetUnitY(Game_Hero[Game_First])
    set d = SquareRoot(( Bot_LX - Bot_X ) * ( Bot_LX - Bot_X ) + ( Bot_LY - Bot_Y ) * ( Bot_LY - Bot_Y ))
    // A burst walks in a straight line: against a wall the goal is dropped, and the next one is tried elsewhere.
    if s__GroundMotion_blocked[m] then
        set s__GroundMotion_hasGoal[m] = false
        set s__GroundMotion_blocked[m] = false
        set Bot_Giro = Bot_Giro + 1
    endif
    set Bot_Blanco = null
    set Bot_Dist = Bot_VISTA + 1.
    set Bot_Valor = Bot_VISTA + 1.
    set Bot_HuirX = 0.
    set Bot_HuirY = 0.
    if Ronda_Activa and not Ronda_Descanso then
        call GroupEnumUnitsInRange(Bot_Grupo, Bot_X, Bot_Y, Bot_VISTA, Bot_Filtro)
    endif
    if Bot_Blanco == null then
        set Bot_Previo = null
        call Bot_Seguir(Bot_LX, Bot_LY, d)
        return
    endif
    call Bot_Medir()
    set linea = Bot_Dist <= Bot_TIRO and Bot_Linea()
    if Bot_Dist <= Bot_TIRO then
        set Bot_Visto = TimerGetElapsed(s__RapidPair_clock)
    endif
    // Enemies come to the human on their own: it only goes after them when nobody has been in range for a while.
    set suelto = TimerGetElapsed(s__RapidPair_clock) - Bot_Visto > Bot_CAZA or not Vidas_EnPartida[Game_First]
    // One order per tick: a move issued right after a cast would replace it before it starts.
    if linea and Bot_Paso - Bot_Paso / 2 * 2 == 0 then
        call Bot_Disparar()
        return
    endif
    if Bot_Dashear(par) then
        return
    endif
    if Bot_Dist < Bot_ALEJAR then
        call Bot_Alejar()
    elseif d > Bot_CORREA and Bot_Dist > Bot_ACERCAR and not suelto then
        call Bot_Seguir(Bot_LX, Bot_LY, d)
    elseif Bot_Dist > Bot_ACERCAR and suelto then
        call Bot_Ir(Bot_X + ( GetUnitX(Bot_Blanco) - Bot_X ) * ( Bot_Dist - Bot_PUESTO ) / Bot_Dist, Bot_Y + ( GetUnitY(Bot_Blanco) - Bot_Y ) * ( Bot_Dist - Bot_PUESTO ) / Bot_Dist)
    elseif not linea and Bot_Dist <= Bot_ACERCAR then
        call Bot_Ir(GetUnitX(Bot_Blanco), GetUnitY(Bot_Blanco))
    endif
endfunction

function Bot_Entrar takes nothing returns nothing
    local integer p = 0
    local integer humanos = 0
    loop
        exitwhen p > 7
        if Game_On[p] then
            set humanos = humanos + 1
        elseif Bot_P < 0 then
            set Bot_P = p
        endif
        set p = p + 1
    endloop
    if humanos > Bot_HUMANOS or Bot_P < 0 then
        set Bot_P = -1
        return
    endif
    set Hero_Choice[Bot_P] = 1 - Hero_Choice[Game_First]
    call SetPlayerName(Player(Bot_P), "Bot")
    set Vidas_Actual[Bot_P] = Vidas_INICIO
    call Game_Cuerpo(Bot_P, GetUnitX(Game_Hero[Game_First]) + 220., GetUnitY(Game_Hero[Game_First]))
    set Game_On[Bot_P] = true
    set Bot_Grupo = CreateGroup()
    set Bot_Filtro = Condition(function Bot_Mira)
    set Bot_Reloj = CreateTimer()
    call TimerStart(Bot_Reloj, Bot_TICK, true, function Bot_Tick)
endfunction

'''


def puntos(rows):
    head = '''    function DevWave_Punto takes integer w,real x,real y returns nothing
        local integer i = 0
        local real dx
        local real dy
        loop
            exitwhen i == DevWave__Count
            set dx = GetUnitX(DevWave__Targets[i]) - x
            set dy = GetUnitY(DevWave__Targets[i]) - y
            if dx * dx + dy * dy < Ronda_DISTANCIA * Ronda_DISTANCIA then
                return
            endif
            set i = i + 1
        endloop
        call s__Wave_addPoint(w,x , y)
    endfunction
    // Grid over the walkable arena from scripts/puntos_v12s.py; points close to a character are left out of this round.
    function DevWave_Puntos takes integer w returns nothing
'''
    body = ''.join(f'        call DevWave_Punto(w,{x:.0f}. , {y:.0f}.)\n' for x, y in rows)
    return head + body + '    endfunction\n'


if __name__ == '__main__':
    j_in, j_out, extracted = sys.argv[1:4]
    rows, _ = points(extracted)
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((GLOBAL_OLD, GLOBAL_NEW), (POINT_OLD, POINT_NEW), (CHANCE_OLD, CHANCE_NEW), (START_OLD, puntos(rows) + START_OLD), (SHOT_OLD, SHOT_NEW),
                     (REST_OLD, REST_NEW), (ENTER_OLD, ENTER_NEW), (ANCHOR, BOT + ANCHOR), (ALLY_OLD, ALLY_NEW), (TINT_OLD, TINT_NEW), (TINT_NOTE_OLD, TINT_NOTE_NEW)) + ICON:
        s = base.once(s, old, new)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(rows))
