struct S extends array
method tick takes nothing returns nothing
endmethod
endstruct
globals
S array /* note */ values
endglobals
function main takes nothing returns nothing
call values[0].tick()
endfunction
function config takes nothing returns nothing
endfunction
