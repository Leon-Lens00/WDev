globals


//JASSHelper struct globals:
constant integer si__Other=1
constant integer si__S=2

endglobals


function s__Other_tick takes integer this returns nothing
endfunction
function s__S__getindex takes integer this,integer i returns integer
return (i)
endfunction
function s__S_tick takes integer this returns nothing
endfunction
function Run takes nothing returns nothing
local integer scalar= 0
call s__Other_tick(s__S__getindex(scalar,0))
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4251")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init4251 takes nothing returns nothing



endfunction

