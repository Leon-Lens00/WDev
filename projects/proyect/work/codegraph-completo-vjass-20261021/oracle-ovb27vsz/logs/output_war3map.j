globals
integer array leaves


//JASSHelper struct globals:
constant integer si__Leaf=1

endglobals


function s__Leaf_tick takes integer this returns nothing
endfunction
function Run takes integer index returns nothing
call s__Leaf_tick((leaves[index]))
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5510")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init5510 takes nothing returns nothing



endfunction

