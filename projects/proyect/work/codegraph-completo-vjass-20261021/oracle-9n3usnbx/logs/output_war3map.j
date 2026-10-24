globals
//globals from Defs:
constant boolean LIBRARY_Defs=true
//endglobals from Defs
//globals from Use:
constant boolean LIBRARY_Use=true
//endglobals from Use


//JASSHelper struct globals:
constant integer si__S=1

endglobals


function Defs__Hidden takes nothing returns nothing
endfunction

function Use___Hidden takes nothing returns nothing
endfunction
//Implemented from module M:
function s__S_run takes nothing returns nothing
call ExecuteFunc("Defs__Hidden")
endfunction

function main takes nothing returns nothing
call s__S_run()

    call ExecuteFunc("jasshelper__init7614")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init7614 takes nothing returns nothing



endfunction

