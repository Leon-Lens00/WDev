globals


//JASSHelper struct globals:
constant integer si__Leaf=1
constant integer si__Box=2

endglobals


function s__Leaf_tick takes integer this returns nothing
endfunction
function s__Box__get_leaf takes integer this returns integer
return 0
endfunction
function s__Box__set_leaf takes integer this,integer value returns nothing
endfunction
function Run takes integer box returns nothing
call s__Leaf_tick(s__Box__get_leaf(box))
call s__Box__set_leaf(box,s__Box__get_leaf(box))
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4251")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init4251 takes nothing returns nothing



endfunction

