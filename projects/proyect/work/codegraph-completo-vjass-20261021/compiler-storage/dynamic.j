struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
type Row extends Leaf array[5]
type Grid extends Row array[3]
function Run takes nothing returns nothing
local Row r=Row.create()
local Grid g=Grid.create()
call r[0].tick()
call g[0][0].tick()
call r.destroy()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
