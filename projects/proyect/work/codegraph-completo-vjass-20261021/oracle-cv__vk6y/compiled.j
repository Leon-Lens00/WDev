globals


//JASSHelper struct globals:
constant integer si__Leaf=1
constant integer si__Factory=2
trigger array st___prototype1
trigger array st___prototype2
integer f__result_integer

endglobals

function sc___prototype1_execute takes integer i returns nothing

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype1[i])

endfunction
function sc___prototype2_execute takes integer i returns nothing

    call TriggerExecute(st___prototype2[i])
endfunction
function sc___prototype2_evaluate takes integer i returns integer

    call TriggerEvaluate(st___prototype2[i])
 return f__result_integer
endfunction

function s__Leaf_tick takes integer this returns nothing
endfunction
function s__Factory_make takes nothing returns integer
return (1)
endfunction
function s__Factory_target takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
local string name= "s__Factory_target"
call s__Leaf_tick(s__Factory_make())
call ExecuteFunc("s__Factory_target")
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4251")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_s__Factory_target takes nothing returns boolean

    return true
endfunction
function sa___prototype2_s__Factory_make takes nothing returns boolean

    set f__result_integer= (1)
    return true
endfunction

function jasshelper__init4251 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_s__Factory_target)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_s__Factory_target))
    set st___prototype2[1]=CreateTrigger()
    call TriggerAddAction(st___prototype2[1],function sa___prototype2_s__Factory_make)
    call TriggerAddCondition(st___prototype2[1],Condition(function sa___prototype2_s__Factory_make))



endfunction

