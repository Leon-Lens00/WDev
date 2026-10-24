struct S
method onDestroy takes nothing returns nothing
endmethod
endstruct
function Run takes S s returns nothing
call s.deallocate()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
