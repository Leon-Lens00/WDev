function Ping takes nothing returns nothing
endfunction
struct Counter
 static method Ping takes nothing returns nothing
 endmethod
 static method Run takes nothing returns nothing
 call Ping()
 endmethod
endstruct
function main takes nothing returns nothing
 call Counter.Run()
endfunction
function config takes nothing returns nothing
endfunction
