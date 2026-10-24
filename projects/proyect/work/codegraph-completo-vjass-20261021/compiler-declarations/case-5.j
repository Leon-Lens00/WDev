struct Base
stub method tick takes nothing returns nothing
endmethod
endstruct
struct Child extends Base
method tick takes nothing returns nothing
call super.tick()
endmethod
endstruct
function Run takes Child c returns nothing
call c.tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
