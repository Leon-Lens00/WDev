struct Base
private static method create takes nothing returns thistype
return thistype.allocate()
endmethod
endstruct
struct Child extends Base
endstruct
function Run takes nothing returns nothing
local Child c=Child.create()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
