//! textmacro METHOD takes NAME
method $NAME$ takes nothing returns nothing
endmethod
//! endtextmacro
module M
//! runtextmacro METHOD("go")
endmodule
struct S
implement M
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
