globals
//globals from Demo:
constant boolean LIBRARY_Demo=true
//endglobals from Demo
constant string PREFIX= "Tar"


//JASSHelper struct globals:

endglobals


function Demo___PrivateTarget takes nothing returns nothing
endfunction
function Demo_PublicTarget takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
call ExecuteFunc(PREFIX + "get")
call ExecuteFunc("Demo___PrivateTarget")
call ExecuteFunc("Demo_PublicTarget")
endfunction

function Target takes nothing returns nothing
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4888")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init4888 takes nothing returns nothing



endfunction

