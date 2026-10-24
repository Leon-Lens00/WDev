function interface Callback takes nothing returns nothing
struct S extends array
static method target takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local Callback cb=Callback.S.target
call cb.evaluate()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
