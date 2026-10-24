globals
integer array values


//JASSHelper struct globals:
constant integer si__S=1

endglobals


function s__S_tick takes integer this returns nothing
endfunction
function s__S_make takes nothing returns integer
return 0
endfunction
function Run takes nothing returns nothing
call s__S_tick(s__S_make())
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing



endfunction

