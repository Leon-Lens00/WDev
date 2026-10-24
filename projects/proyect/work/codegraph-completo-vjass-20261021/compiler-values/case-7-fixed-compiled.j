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

//processed: function interface Callback takes nothing returns nothing
function One takes nothing returns nothing
endfunction
function Two takes nothing returns nothing
endfunction
function Invoke takes integer cb returns nothing
local integer callbackAlias= cb
call TriggerEvaluate(st___prototype1[(callbackAlias)]) // INLINED!!
endfunction
function Run takes boolean chooseTwo returns nothing
local integer cb= (1)
if chooseTwo then
set cb=(2)
endif
call Invoke(cb)
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4888")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_One takes nothing returns boolean

    return true
endfunction
function sa___prototype1_Two takes nothing returns boolean

    return true
endfunction

function jasshelper__init4888 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_One)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_One))
    set st___prototype1[2]=CreateTrigger()
    call TriggerAddAction(st___prototype1[2],function sa___prototype1_Two)
    call TriggerAddCondition(st___prototype1[2],Condition(function sa___prototype1_Two))



endfunction

