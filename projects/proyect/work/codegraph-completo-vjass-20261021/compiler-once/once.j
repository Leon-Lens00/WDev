library_once Once
function First takes nothing returns nothing
endfunction
module M
static method target takes nothing returns nothing
endmethod
endmodule
endlibrary
library_once Once
function Ignored takes nothing returns nothing
endfunction
module M
static method wrong takes nothing returns nothing
endmethod
endmodule
endlibrary
struct S
implement M
endstruct
function main takes nothing returns nothing
call First()
endfunction
function config takes nothing returns nothing
endfunction
