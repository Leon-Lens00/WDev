function Compute takes nothing returns integer
return 1
endfunction
globals
constant integer VALUE=Compute()
endglobals
struct S
static constant integer FIELD=Compute()
endstruct

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
