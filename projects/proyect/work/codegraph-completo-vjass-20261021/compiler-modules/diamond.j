module M
static method ping takes nothing returns nothing
endmethod
endmodule
module N
implement M
endmodule
struct S
implement M
implement N
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
