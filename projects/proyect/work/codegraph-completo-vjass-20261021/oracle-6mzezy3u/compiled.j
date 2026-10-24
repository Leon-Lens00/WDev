globals


//JASSHelper struct globals:
constant integer si__A=1
constant integer si__B=2
trigger array st___prototype1
integer f__result_integer
integer f__arg_integer1

endglobals

function sc___prototype1_execute takes integer i,integer a1 returns nothing
    set f__arg_integer1=a1

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i,integer a1 returns integer
    set f__arg_integer1=a1

    call TriggerEvaluate(st___prototype1[i])
 return f__result_integer
endfunction

function s__A_tick takes integer this returns nothing
endfunction
function s__B_other takes integer this returns nothing
endfunction
//processed: function interface Callback takes A x returns A
function Target takes integer x returns integer
return x
endfunction
function Run takes nothing returns nothing
local integer cb=(1)
local integer a=sc___prototype1_evaluate(cb,(0))
call s__A_tick(a)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4888")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_Target takes nothing returns boolean
 local integer x=f__arg_integer1

    set f__result_integer= x
    return true
endfunction

function jasshelper__init4888 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_Target)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_Target))



endfunction

