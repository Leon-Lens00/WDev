module M
private integer value
private method helper takes nothing returns nothing
set this.value=1
endmethod
method runM takes nothing returns nothing
call this.helper()
endmethod
endmodule
module N
private integer value
private method helper takes nothing returns nothing
set this.value=2
endmethod
method runN takes nothing returns nothing
call this.helper()
endmethod
endmodule
struct S
implement M
implement N
endstruct
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
