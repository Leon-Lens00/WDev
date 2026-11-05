"""Dev Mission v12o (31/10/2026): limited lives on top of the v12n fall, driven by the undefend order.

Same rules as HeroLives of WaveSys: 10 lives, one spent on each fall, 2 s of invulnerability on return. With no lives left the character
loses 'Arei', so the next death is a real one and ends the pair. The order is the event; the pair's cycle only covers a missed order.

Usage: vidas_v12o.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

GLOBAL_OLD = 'boolean array s__RapidPair_down\n'
GLOBAL_NEW = GLOBAL_OLD + '''constant integer Vidas_INICIO = 10
constant real Vidas_INVULNERABLE = 2.
constant integer Vidas_UNDEFEND = 852056
constant string Vidas_FX = "Abilities\\\\Spells\\\\Human\\\\DivineShield\\\\DivineShieldTarget.mdl"
integer array Vidas_Actual
effect array Vidas_Escudo
trigger Vidas_Orden = null
'''
FUNCS = '''function Vidas_Fin takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer p = GetTimerData(t)
    call ReleaseTimer(t)
    call SetUnitInvulnerable(Game_Hero[p], false)
    call DestroyEffect(Vidas_Escudo[p])
    set Vidas_Escudo[p] = null
    set t = null
endfunction

function s__RapidPair_fall takes integer this returns nothing
    local integer p = GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
    set s__RapidPair_down[this] = true
    call PauseTimer(s__RapidPair_reset[this])
    call s__RapidPair_finish(this,false)
    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
    call PauseUnit(s__RapidPair_controller[this], true)
    // The controller must not die with the character: its life is only what the panel shows.
    call SetWidgetLife(s__RapidPair_controller[this], 1.)
    set Vidas_Actual[p] = Vidas_Actual[p] - 1
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 3., "Vidas: " + I2S(Vidas_Actual[p]))
endfunction

function s__RapidPair_rise takes integer this returns nothing
    local integer p = GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
    local unit u = s__RapidPair_actor[this]
    set s__RapidPair_down[this] = false
    call PauseUnit(s__RapidPair_controller[this], false)
    if Vidas_Actual[p] <= 0 then
        call UnitRemoveAbility(u, 'Arei')
    endif
    call SetUnitInvulnerable(u, true)
    set Vidas_Escudo[p] = AddSpecialEffectTarget(Vidas_FX, u, "origin")
    call TimerStart(NewTimerEx(p), Vidas_INVULNERABLE, false, function Vidas_Fin)
    set u = null
endfunction

// The character gets undefend when it falls and again when it returns.
function Vidas_AlOrdenar takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer this
    if GetIssuedOrderId() == Vidas_UNDEFEND then
        set this = LoadInteger(Table___ht, s__RapidPair_actors, GetHandleId(u))
        if this != 0 then
            if s__GroundCollision_alive(u) then
                if s__RapidPair_down[this] then
                    call s__RapidPair_rise(this)
                endif
            elseif not s__RapidPair_down[this] and GetUnitAbilityLevel(u, 'Arei') > 0 then
                call s__RapidPair_fall(this)
            endif
        endif
    endif
    set u = null
endfunction

'''
TICK_ANCHOR = '    function s__RapidPair_tick takes nothing returns nothing\n'
TICK_OLD = '''            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
                call s__RapidPair_destroy(this)
            elseif not s__GroundCollision_alive(s__RapidPair_actor[this]) then
                if not s__RapidPair_down[this] then
                    set s__RapidPair_down[this]=true
                    call PauseTimer(s__RapidPair_reset[this])
                    call s__RapidPair_finish(this,false)
                    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]]=false
                    call PauseUnit(s__RapidPair_controller[this], true)
                endif
                // The controller must not die with the character: its life is only what the panel shows.
                call SetWidgetLife(s__RapidPair_controller[this], 1.)
            else
                if s__RapidPair_down[this] then
                    set s__RapidPair_down[this]=false
                    call PauseUnit(s__RapidPair_controller[this], false)
                endif
'''
TICK_NEW = '''            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
                set s__RapidPair_down[this]=false
                call s__RapidPair_destroy(this)
            elseif not s__GroundCollision_alive(s__RapidPair_actor[this]) then
                if GetUnitAbilityLevel(s__RapidPair_actor[this], 'Arei') == 0 then
                    set s__RapidPair_down[this]=false
                    call s__RapidPair_destroy(this)
                else
                    if not s__RapidPair_down[this] then
                        call s__RapidPair_fall(this)
                    endif
                    call SetWidgetLife(s__RapidPair_controller[this], 1.)
                endif
            else
                if s__RapidPair_down[this] then
                    call s__RapidPair_rise(this)
                endif
'''
PAIR_OLD = "    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])\n"
PAIR_NEW = PAIR_OLD + '''    set Vidas_Actual[p] = Vidas_INICIO
    if Vidas_Orden == null then
        set Vidas_Orden = CreateTrigger()
        call TriggerAddAction(Vidas_Orden, function Vidas_AlOrdenar)
    endif
    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)
'''


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((GLOBAL_OLD, GLOBAL_NEW), (TICK_OLD, TICK_NEW), (TICK_ANCHOR, FUNCS + TICK_ANCHOR), (PAIR_OLD, PAIR_NEW)):
        s = base.once(s, old, new)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok')
