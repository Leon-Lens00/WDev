struct Other extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct S extends array
method operator [] takes integer i returns Other
return Other(i)
endmethod
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local S scalar = 0 // array
call scalar[0].tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
