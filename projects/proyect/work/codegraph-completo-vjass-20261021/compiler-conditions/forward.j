struct S extends array
static if thistype.later.exists then
method early takes nothing returns nothing
endmethod
endif
method later takes nothing returns nothing
endmethod
endstruct

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
