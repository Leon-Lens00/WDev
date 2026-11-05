"""Dev Mission v12k (30/10/2026): the controller hides Move, Patrol and Hold with the SilenceEx method.

Same steps as SILENCE_TESTUNIT_AMOV in DevMission v0.96 and leandrotp's AbilitySilence, in plain JASS because war3map.j is the
compiled script. DioD's FCC_MAIN2/FCC_Order2 stay out, as in v0.96: 'Amov' stays as the method leaves it. Players and the
neutral extra player already share vision before Game_Enter (ConversationUI___Start).

Usage: silencio_v12k.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// AbilitySilence by leandrotp (silencio_v12k.py).
unit AbilitySilence_Dummy = null
boolean AbilitySilence_Flag = false
integer AbilitySilence_Id = 0
'''
FUNCS = '''// AbilitySilence by leandrotp: silence or unsilence one ability of a unit (silencio_v12k.py).
function AbilitySilence_Enable takes unit u, integer id returns nothing
    call IncUnitAbilityLevel(u, id)
    call IssueTargetOrderById(AbilitySilence_Dummy, 852668, u)
    call DecUnitAbilityLevel(u, id)
    call UnitRemoveAbility(u, 'BNso')
endfunction

function AbilitySilence_Disable takes unit u, integer id returns nothing
    call IssueTargetOrderById(AbilitySilence_Dummy, 852668, u)
    call IncUnitAbilityLevel(u, id)
    call UnitRemoveAbility(u, 'BNso')
    call DecUnitAbilityLevel(u, id)
endfunction

function AbilitySilence_OnSilence takes nothing returns boolean
    if GetIssuedOrderId() == 852479 and UnitRemoveAbility(GetTriggerUnit(), 'AS01') then
        // The unit is immune to silence here, so only one ability changes.
        if AbilitySilence_Flag then
            call AbilitySilence_Disable(GetTriggerUnit(), AbilitySilence_Id)
        else
            call AbilitySilence_Enable(GetTriggerUnit(), AbilitySilence_Id)
        endif
    endif
    return false
endfunction

function AbilitySilence_Prepare takes nothing returns nothing
    local trigger t
    if AbilitySilence_Dummy == null then
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER)
        call TriggerAddCondition(t, Condition(function AbilitySilence_OnSilence))
        set AbilitySilence_Dummy = CreateUnit(Player(15), 'uloc', 0., 0., 0.)
        call SetUnitScale(AbilitySilence_Dummy, 0, 0, 0)
        call UnitRemoveAbility(AbilitySilence_Dummy, 'Amov')
        call UnitRemoveAbility(AbilitySilence_Dummy, 'Aatk')
        call UnitAddAbility(AbilitySilence_Dummy, 'AS00')
        set t = null
    endif
endfunction

function SetUnitAbilitySilenced takes unit u, integer i, boolean silence returns nothing
    local boolean inventory = UnitAddAbility(u, 'AInv')
    local boolean hidden = IsUnitHidden(u)
    call AbilitySilence_Prepare()
    if hidden then
        call ShowUnit(u, true)
    endif
    call UnitAddAbility(u, 'Amdf')
    call SetUnitOwner(AbilitySilence_Dummy, GetOwningPlayer(u), false)
    // The dummy and the unit must see each other for the cast.
    call SetUnitX(AbilitySilence_Dummy, GetUnitX(u))
    call SetUnitY(AbilitySilence_Dummy, GetUnitY(u))
    set AbilitySilence_Id = i
    set AbilitySilence_Flag = silence
    call RemoveItem(UnitAddItemById(u, 'IS00'))
    if not UnitRemoveAbility(u, 'Bmfl') then
        // Mana Flare failed, so the unit is dead or already silenced.
        if silence then
            call AbilitySilence_Disable(u, i)
        else
            call AbilitySilence_Enable(u, i)
        endif
    endif
    call UnitRemoveAbility(u, 'Amdf')
    if hidden then
        call ShowUnit(u, false)
    endif
    if inventory then
        call UnitRemoveAbility(u, 'AInv')
    endif
endfunction

// Hides Move, Patrol and Hold: SILENCE_TESTUNIT_AMOV of DevMission v0.96.
function Silence_HideMove takes unit a returns nothing
    call SetUnitAbilitySilenced(a, 'Amov', false)
    call UnitAddAbility(a, 'HDHD')
    call UnitRemoveAbility(a, 'Aatk')
    call UnitMakeAbilityPermanent(a, true, 'HDHD')
    call SetUnitAbilitySilenced(a, 'HDHD', true)
    call UnitAddAbility(a, 'Aro1')
    call UnitRemoveAbility(a, 'Aro1')
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Game_Enter takes integer p returns nothing\n', FUNCS + 'function Game_Enter takes integer p returns nothing\n')
    s = base.once(s, '    call SetUnitVertexColor(Game_Ctrl[p], 255, 255, 255, 0)\n',
                  '    call SetUnitVertexColor(Game_Ctrl[p], 255, 255, 255, 0)\n    call Silence_HideMove(Game_Ctrl[p])\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
