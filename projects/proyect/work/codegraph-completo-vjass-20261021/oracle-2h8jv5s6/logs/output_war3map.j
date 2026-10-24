globals

endglobals
struct A extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct B extends array
method other takes nothing returns nothing
endmethod
endstruct
function interface Callback takes A x returns A
function Target takes B x returns B
return x
endfunction
function Run takes nothing returns nothing
local Callback cb=Callback.Target
call cb.evaluate(A(0)).tick()
endfunction
function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


