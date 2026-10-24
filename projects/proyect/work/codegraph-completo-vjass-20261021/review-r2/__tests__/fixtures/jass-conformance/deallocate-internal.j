struct S
method onDestroy takes nothing returns nothing
endmethod
method release takes nothing returns nothing
call this.deallocate()
endmethod
endstruct
function Run takes S s returns nothing
call s.release()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
