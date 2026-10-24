globals


//JASSHelper struct globals:
constant integer si__Leaf=1
constant integer si__Box=2
constant integer si__Factory=3
integer array s__Factory_box

endglobals


function s__Leaf_tick takes integer this returns nothing
endfunction
function s__Box__getindex takes integer this,integer i returns integer
return (i)
endfunction
function s__Factory_make takes nothing returns integer
return 0
endfunction
function Run takes nothing returns nothing
call s__Leaf_tick(s__Box__getindex(s__Factory_box[(0)],0)) // INLINED!!
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init7614")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init7614 takes nothing returns nothing



endfunction

