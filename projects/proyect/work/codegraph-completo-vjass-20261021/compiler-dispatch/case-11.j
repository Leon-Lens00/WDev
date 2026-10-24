interface I
method tick takes nothing returns nothing defaults nothing
endinterface
struct A extends I
method tick takes nothing returns nothing
endmethod
endstruct
struct B extends I
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes I value returns nothing
call value.tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
