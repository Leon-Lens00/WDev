struct Base
method onDestroy takes nothing returns nothing
endmethod
endstruct
struct Child extends Base
method onDestroy takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local Base b=Child.create()
call b.destroy()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
