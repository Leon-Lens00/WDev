module M
static method ping takes nothing returns nothing
endmethod
endmodule
struct S
static if false then
implement M
else
implement M
endif
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
