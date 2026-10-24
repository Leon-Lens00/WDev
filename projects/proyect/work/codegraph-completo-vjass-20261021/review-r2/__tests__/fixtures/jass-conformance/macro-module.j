//! textmacro DECL takes NAME
module $NAME$
static method run takes nothing returns nothing
call Ping()
endmethod
endmodule
//! endtextmacro
//! runtextmacro DECL("M")
function Ping takes nothing returns nothing
endfunction
struct S extends array
implement M
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
