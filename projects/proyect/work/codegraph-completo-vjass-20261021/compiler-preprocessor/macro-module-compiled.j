globals


//JASSHelper struct globals:
constant integer si__S=1

endglobals


//textmacro instance: DECL("M")
//end of: DECL("M")
function Ping takes nothing returns nothing
endfunction
//Implemented from module M:
function s__S_run takes nothing returns nothing
call Ping()
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing



endfunction

