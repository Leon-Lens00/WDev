struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Factory extends array
static method make takes nothing returns Leaf
return Leaf(1)
endmethod
static method target takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local string name = Factory.target.name
call Factory.make.evaluate().tick()
call ExecuteFunc(Factory.target.name)
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
