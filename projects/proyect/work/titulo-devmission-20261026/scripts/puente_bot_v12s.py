"""Puente de prueba del bot (Dev Mission v12s, 31/10/2026). NO integrar.

3 rondas con 8 s de descanso y combate real, sin limpiar la oleada. Registra cada aparición, cada dash del jugador, la flecha de control
y cada 0,5 s el estado del bot.
Uso: puente_bot_v12s.py IN_J OUT_J CELDA VIDAS
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_bot_v12s.py).
function Bt_Sale takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer o = GetPlayerId(GetOwningPlayer(u))
    if o >= 8 and o <= 13 then
        call Sonda_Log("sale " + GetUnitName(u) + " ronda " + I2S(Ronda_Numero) + " x " + I2S(R2I(GetUnitX(u))) + " y " + I2S(R2I(GetUnitY(u))) + " pasable " + I2S(IntegerTertiaryOp(IsTerrainPathable(GetUnitX(u), GetUnitY(u), PATHING_TYPE_WALKABILITY), 0, 1)) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)))
    endif
    set u = null
endfunction

function Bt_Flecha takes nothing returns nothing
    set Bt_Flechas = Bt_Flechas + 1
    call Sonda_Log("flecha " + I2S(Bt_Flechas) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " caido " + I2S(IntegerTertiaryOp(s__RapidPair_down[Game_Pair[0]], 1, 0)))
endfunction

function Bt_Z takes real x,real y returns real
    call MoveLocation(Bt_Punto, x, y)
    return GetLocationZ(Bt_Punto)
endfunction

function Bt_Nombre takes nothing returns string
    if Bot_Blanco == null then
        return "nadie"
    endif
    return GetUnitName(Bot_Blanco) + " vida " + I2S(R2I(GetWidgetLife(Bot_Blanco))) + "/" + I2S(R2I(GetUnitState(Bot_Blanco, UNIT_STATE_MAX_LIFE))) + " x " + I2S(R2I(GetUnitX(Bot_Blanco))) + " y " + I2S(R2I(GetUnitY(Bot_Blanco))) + " z " + I2S(R2I(Bt_Z(GetUnitX(Bot_Blanco), GetUnitY(Bot_Blanco)))) + " ord " + I2S(GetUnitCurrentOrder(Bot_Blanco))
endfunction

function Bt_Censo takes nothing returns boolean
    local unit u = GetFilterUnit()
    local integer o = GetPlayerId(GetOwningPlayer(u))
    if o >= 8 and o <= 13 and UnitAlive(u) then
        call Sonda_Log("censo " + R2S(Bt_ProxCenso) + " id " + I2S(GetHandleId(u)) + " x " + I2S(R2I(GetUnitX(u))) + " y " + I2S(R2I(GetUnitY(u))) + " ord " + I2S(GetUnitCurrentOrder(u)) + " " + GetUnitName(u) + " dueno " + I2S(o) + " enemigo " + I2S(IntegerTertiaryOp(IsPlayerEnemy(Player(o), Player(0)), 1, 0)) + " ia " + I2S(IntegerTertiaryOp(WaveAIIsManaged(u), 1, 0)) + " blanco " + I2S(GetHandleId(WaveAIGetTarget(u))) + " pausa " + I2S(IntegerTertiaryOp(IsUnitPaused(u), 1, 0)) + " vel " + I2S(R2I(GetUnitMoveSpeed(u))))
    endif
    set u = null
    return false
endfunction

function Bt_Reg takes nothing returns nothing
    local integer b = Bot_P
    local integer m = s__RapidPair_motion[Game_Pair[0]]
    local string e = I2S(s__RapidPair_dashes) + " " + I2S(IntegerTertiaryOp(s__GroundMotion_dashing[m], 1, 0))
    local real t = TimerGetElapsed(s__RapidPair_clock)
    if t >= Bt_ProxCenso then
        set Bt_ProxCenso = t + 5.
        call GroupEnumUnitsInRect(Bt_Todo, GetWorldBounds(), Condition(function Bt_Censo))
    endif
    if e != Bt_Antes and Game_Hero[0] != null then
        set Bt_Antes = e
        call Sonda_Log("dash " + e + " t " + R2S(t) + " J0 x " + I2S(R2I(GetUnitX(Game_Hero[0]))) + " y " + I2S(R2I(GetUnitY(Game_Hero[0]))) + " cara " + I2S(R2I(GetUnitFacing(Game_Hero[0]))) + " mana " + I2S(R2I(GetUnitState(Game_Ctrl[0], UNIT_STATE_MANA))) + " Bx " + I2S(R2I(GetUnitX(Game_Hero[b]))) + " By " + I2S(R2I(GetUnitY(Game_Hero[b]))))
    endif
    if t >= Bt_Prox and b >= 0 and Game_Hero[b] != null then
        set Bt_Prox = t + 0.5
        call Sonda_Log("bot t " + R2S(t) + " r " + I2S(Ronda_Numero) + " desc " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " falta " + I2S(s__Wave_toKillRemaining[Ronda_Wave]) + " x " + I2S(R2I(GetUnitX(Game_Hero[b]))) + " y " + I2S(R2I(GetUnitY(Game_Hero[b]))) + " vida " + I2S(R2I(GetWidgetLife(Game_Hero[b]))) + " mana " + I2S(R2I(GetUnitState(Game_Ctrl[b], UNIT_STATE_MANA))) + " vidas " + I2S(Vidas_Actual[b]) + " enp " + I2S(IntegerTertiaryOp(Vidas_EnPartida[b], 1, 0)) + " dist " + I2S(R2I(Bot_Dist)) + " fuego " + I2S(IntegerTertiaryOp(s__RapidPair_firing[Game_Pair[b]], 1, 0)) + " tiros " + I2S(s__RapidPair_emitted) + " dashes " + I2S(s__RapidPair_dashes) + " J0v " + I2S(R2I(GetWidgetLife(Game_Hero[0]))) + " J0vidas " + I2S(Vidas_Actual[0]) + " aliado " + I2S(IntegerTertiaryOp(IsUnitAlly(Game_Hero[b], Player(0)), 1, 0)) + " habs " + I2S(GetUnitAbilityLevel(Game_Ctrl[0], 'Arpf') + GetUnitAbilityLevel(Game_Ctrl[0], 'Arp3')) + I2S(GetUnitAbilityLevel(Game_Ctrl[0], 'Arp1')))
        set m = s__RapidPair_motion[Game_Pair[b]]
        call Sonda_Log("mira t " + R2S(t) + " tiros " + I2S(s__RapidPair_emitted) + " golpes " + I2S(s__RapidBolt_hits) + " suelo " + I2S(s__RapidBolt_walls) + " blanco " + Bt_Nombre() + " meta " + I2S(R2I(Bot_MetaX)) + " " + I2S(R2I(Bot_MetaY)) + " hasGoal " + I2S(IntegerTertiaryOp(s__GroundMotion_hasGoal[m], 1, 0)) + " tope " + I2S(IntegerTertiaryOp(s__GroundMotion_blocked[m], 1, 0)) + " artif " + I2S(IntegerTertiaryOp(s__GroundMotion_artificial[m], 1, 0)) + " ordC " + I2S(GetUnitCurrentOrder(Game_Ctrl[b])) + " ordH " + I2S(GetUnitCurrentOrder(Game_Hero[b])) + " pend " + I2S(s__RapidPair_pending[Game_Pair[b]]) + " zH " + I2S(R2I(Bt_Z(GetUnitX(Game_Hero[b]), GetUnitY(Game_Hero[b])))))
    endif
endfunction

function Rev_Timer takes nothing returns nothing
'''
START = '    call TimerStart(GetExpiredTimer(), 0.05, true, function Rev_Timer)\n'
ARRANQUE = '''    set Bt_Punto = Location(0., 0.)
    set Bt_Tecla = CreateTrigger()
    call TriggerRegisterPlayerEvent(Bt_Tecla, Player(0), EVENT_PLAYER_ARROW_LEFT_DOWN)
    call TriggerAddAction(Bt_Tecla, function Bt_Flecha)
    set Bt_Mundo = CreateTrigger()
    call TriggerRegisterEnterRectSimple(Bt_Mundo, GetWorldBounds())
    call TriggerAddAction(Bt_Mundo, function Bt_Sale)
    call TimerStart(CreateTimer(), 0.05, true, function Bt_Reg)
'''

if __name__ == '__main__':
    j_in, j_out, celda, vidas = sys.argv[1:5]
    subprocess.run([sys.executable, str(S / 'puente_vidas_v12o.py'), j_in, j_out, celda, vidas], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'constant integer Ronda_TOTAL = 10\n', 'constant integer Ronda_TOTAL = 3\n')
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n', '''constant integer Ronda_DESCANSO = 8
string Bt_Antes = ""
integer Bt_Flechas = 0
real Bt_Prox = 0.
trigger Bt_Tecla = null
trigger Bt_Mundo = null
location Bt_Punto = null
group Bt_Todo = CreateGroup()
real Bt_ProxCenso = 0.
''')
    s = base.once(s, 'function Rev_Timer takes nothing returns nothing\n', FUNCS)
    s = base.once(s, START, ARRANQUE + START)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
