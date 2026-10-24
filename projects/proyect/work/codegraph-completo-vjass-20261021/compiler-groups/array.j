struct S extends array
method tick takes nothing returns nothing
endmethod
static method make takes nothing returns thistype
return 0
endmethod
endstruct
globals
S array values
endglobals
function Run takes nothing returns nothing
call (values[0]).tick()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
