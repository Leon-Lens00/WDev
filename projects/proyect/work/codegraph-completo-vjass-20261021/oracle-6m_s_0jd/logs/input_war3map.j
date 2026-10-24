static if DEBUG_MODE then
function Optional takes nothing returns nothing
if true then
endif
endfunction
globals
constant boolean FLAG=true
endglobals
endif
static if FLAG then
function Yes takes nothing returns nothing
endfunction
else
function No takes nothing returns nothing
endfunction
endif

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
