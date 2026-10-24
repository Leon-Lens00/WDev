module Begin
static method run takes nothing returns nothing
endmodule
module Finish
endmethod
endmodule
function Ping takes nothing returns nothing
endfunction
struct S
implement Begin
call Ping()
implement Finish
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
