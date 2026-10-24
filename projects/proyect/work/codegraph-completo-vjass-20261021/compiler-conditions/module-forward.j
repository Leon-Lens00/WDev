module M
static if thistype.later.exists then
method early takes nothing returns nothing
endmethod
endif
endmodule
struct S extends array
implement M
method later takes nothing returns nothing
endmethod
endstruct

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
