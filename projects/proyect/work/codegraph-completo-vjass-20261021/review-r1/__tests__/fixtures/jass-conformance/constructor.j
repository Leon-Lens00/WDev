struct Base
static method create takes integer n returns thistype
return thistype.allocate()
endmethod
endstruct
struct Child extends Base
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local Child c=Child.create(1)
call Child.create(2).tick()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
