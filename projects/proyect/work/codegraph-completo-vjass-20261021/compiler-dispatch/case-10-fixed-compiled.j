globals


//JASSHelper struct globals:
trigger array st___prototype1
unit f__arg_unit1

endglobals

function sc___prototype1_execute takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerEvaluate(st___prototype1[i])

endfunction
function h__RemoveUnit takes unit a0 returns nothing
    //hook: OnRemoval
    call sc___prototype1_evaluate(1,a0)
call RemoveUnit(a0)
endfunction

function OnRemoval takes unit u returns nothing
endfunction
function Run takes unit u returns nothing
call h__RemoveUnit(u)
endfunction
//processed hook: hook RemoveUnit OnRemoval
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init1573")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_OnRemoval takes nothing returns boolean
    call OnRemoval(f__arg_unit1)
    return true
endfunction

function jasshelper__init1573 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_OnRemoval)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_OnRemoval))



endfunction

