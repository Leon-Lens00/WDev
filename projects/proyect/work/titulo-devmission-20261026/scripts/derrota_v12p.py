"""Dev Mission v12p (31/10/2026): general defeat when nobody is left standing.

A player leaves the count on their real death or when they quit. At zero every human gets the defeat, so one player loses alone and a
group waits for the last one. WaveSys has no defeat of its own: HeroLives only leaves the hero dead.

Usage: derrota_v12p.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

GLOBAL_OLD = 'trigger Vidas_Orden = null\n'
GLOBAL_NEW = GLOBAL_OLD + '''constant real Vidas_ESPERA_DERROTA = 2.
boolean array Vidas_EnPartida
integer Vidas_EnPie = 0
boolean Vidas_Perdida = false
trigger Vidas_Salida = null
'''
FUNCS = '''function Vidas_Derrota takes nothing returns nothing
    local integer p = 0
    call DestroyTimer(GetExpiredTimer())
    set Vidas_Perdida = true
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            call CustomDefeatBJ(Player(p), "Derrota")
        endif
        set p = p + 1
    endloop
endfunction

// The delay lets the last death play before the defeat dialog covers it.
function Vidas_Retirar takes integer p returns nothing
    if Vidas_EnPartida[p] then
        set Vidas_EnPartida[p] = false
        set Vidas_EnPie = Vidas_EnPie - 1
        if Vidas_EnPie == 0 then
            call TimerStart(CreateTimer(), Vidas_ESPERA_DERROTA, false, function Vidas_Derrota)
        endif
    endif
endfunction

function Vidas_AlSalir takes nothing returns nothing
    call Vidas_Retirar(GetPlayerId(GetTriggerPlayer()))
endfunction

'''
TICK_ANCHOR = '    function s__RapidPair_tick takes nothing returns nothing\n'
DEATH_OLD = '''                if GetUnitAbilityLevel(s__RapidPair_actor[this], 'Arei') == 0 then
                    set s__RapidPair_down[this]=false
'''
DEATH_NEW = DEATH_OLD + '''                    call Vidas_Retirar(GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this])))
'''
ENTER_OLD = "    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)\n"
ENTER_NEW = ENTER_OLD + '''    set Vidas_EnPartida[p] = true
    set Vidas_EnPie = Vidas_EnPie + 1
    if Vidas_Salida == null then
        set Vidas_Salida = CreateTrigger()
        call TriggerAddAction(Vidas_Salida, function Vidas_AlSalir)
    endif
    call TriggerRegisterPlayerEvent(Vidas_Salida, Player(p), EVENT_PLAYER_LEAVE)
'''


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((GLOBAL_OLD, GLOBAL_NEW), (TICK_ANCHOR, FUNCS + TICK_ANCHOR), (DEATH_OLD, DEATH_NEW), (ENTER_OLD, ENTER_NEW)):
        s = base.once(s, old, new)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok')
