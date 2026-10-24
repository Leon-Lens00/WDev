globals
string array names


//JASSHelper struct globals:

endglobals


function Target takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
set names[0]="Target"
call ExecuteFunc(names[0])
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2737")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init2737 takes nothing returns nothing



endfunction

