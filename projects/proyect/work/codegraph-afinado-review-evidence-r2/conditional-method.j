globals
 constant boolean FLAG = true
endglobals
function ping takes nothing returns nothing
endfunction
struct S
 static if FLAG then
 static method ping takes nothing returns nothing
 endmethod
 else
 static method ping takes nothing returns nothing
 endmethod
 endif
 static method run takes nothing returns nothing
 call ping()
 endmethod
endstruct
function main takes nothing returns nothing
 call S.run()
endfunction
function config takes nothing returns nothing
endfunction
