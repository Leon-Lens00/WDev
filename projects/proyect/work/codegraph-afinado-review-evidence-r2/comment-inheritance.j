struct WrongBase
 method tick takes nothing returns nothing
 endmethod
endstruct
struct CorrectBase
 method tick takes nothing returns nothing
 endmethod
endstruct
struct Child /* extends WrongBase */ extends CorrectBase
endstruct
function Probe takes Child c returns nothing
 call c.tick()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
