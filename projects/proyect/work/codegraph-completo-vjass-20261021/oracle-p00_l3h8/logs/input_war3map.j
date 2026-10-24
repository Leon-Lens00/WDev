library A
globals
constant boolean FLAG=true
endglobals
endlibrary
library B requires A
static if FLAG then
function Chosen takes nothing returns nothing
endfunction
else
function Fallback takes nothing returns nothing
endfunction
endif
endlibrary
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
