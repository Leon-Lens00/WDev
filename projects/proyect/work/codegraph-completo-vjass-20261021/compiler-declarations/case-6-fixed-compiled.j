globals
constant integer Demo___SLOT=22


//JASSHelper struct globals:
constant integer si__Demo___Later=1
trigger st__Demo___Later_tick
integer f__arg_this

endglobals


//Generated method caller for Demo___Later.tick
function sc__Demo___Later_tick takes integer this returns nothing
endfunction

function Demo___Run takes integer value returns nothing
call sc__Demo___Later_tick(value)
endfunction
function s__Demo___Later_tick takes integer this returns nothing
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5762")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__Demo___Later_tick takes nothing returns boolean
local integer this=f__arg_this
   return true
endfunction

function jasshelper__init5762 takes nothing returns nothing
    set st__Demo___Later_tick=CreateTrigger()
    call TriggerAddCondition(st__Demo___Later_tick,Condition( function sa__Demo___Later_tick))



endfunction

