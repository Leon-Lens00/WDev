globals
//globals from Demo:
constant boolean LIBRARY_Demo=true
//endglobals from Demo


//JASSHelper struct globals:

endglobals


function Ping takes nothing returns nothing
endfunction
function Init takes nothing returns nothing
call Ping()
endfunction

function Original takes nothing returns nothing
endfunction
function main takes nothing returns nothing
call Ping()


    call ExecuteFunc("jasshelper__init5762")


endfunction //injected main function (! inject command)??
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init5762 takes nothing returns nothing


call ExecuteFunc("Init")
//------------------------------------

endfunction

