struct S extends array
integer feature
static if thistype.feature.exists then
method chosen takes nothing returns nothing
endmethod
endif
endstruct

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
