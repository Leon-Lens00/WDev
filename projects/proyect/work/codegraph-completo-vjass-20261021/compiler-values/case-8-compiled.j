globals


//JASSHelper struct globals:
trigger array st___prototype1

endglobals

function sc___prototype1_execute takes integer i returns nothing

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype1[i])

endfunction

function Target takes nothing returns nothing
endfunction
function Run takes string unknown returns nothing
call ExecuteFunc("Target")
call ExecuteFunc(unknown)
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init7882")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_Target takes nothing returns boolean

    return true
endfunction

function jasshelper__init7882 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_Target)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_Target))



endfunction

