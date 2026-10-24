globals
S array values

endglobals
struct S extends array
method tick takes nothing returns nothing
endmethod
static method make takes nothing returns thistype
return 0
endmethod
endstruct
function Run takes nothing returns nothing
call (S.make()).tick()
endfunction
function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


