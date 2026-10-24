function BaseCleanup takes nothing returns nothing
endfunction
function ChildCleanup takes nothing returns nothing
endfunction
struct Base
method onDestroy takes nothing returns nothing
call BaseCleanup()
endmethod
endstruct
struct Child extends Base
method onDestroy takes nothing returns nothing
call ChildCleanup()
endmethod
endstruct
function Run takes Child value returns nothing
call value.destroy()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
