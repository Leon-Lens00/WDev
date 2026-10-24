library Defs
private function Hidden takes nothing returns nothing
endfunction
module M
static method run takes nothing returns nothing
call ExecuteFunc(SCOPE_PRIVATE+"Hidden")
endmethod
endmodule
endlibrary
library Use
private function Hidden takes nothing returns nothing
endfunction
struct S extends array
implement M
endstruct
endlibrary
function main takes nothing returns nothing
call S.run()
endfunction
function config takes nothing returns nothing
endfunction
