globals
constant boolean FLAG=true


//JASSHelper struct globals:

endglobals


//# static if true then
    function Optional takes nothing returns nothing
    if true then
    endif
    endfunction
//# endif
//# static if FLAG then
    function Yes takes nothing returns nothing
    endfunction
//# else
//# function No takes nothing returns nothing
//# endfunction
//# endif

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init4888")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init4888 takes nothing returns nothing



endfunction

