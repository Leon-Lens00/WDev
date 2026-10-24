globals

endglobals
struct Base extends array
method feature takes nothing returns nothing
endmethod
endstruct
struct S extends Base
static if thistype.feature.exists then
method chosen takes nothing returns nothing
endmethod
endif
endstruct

function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


