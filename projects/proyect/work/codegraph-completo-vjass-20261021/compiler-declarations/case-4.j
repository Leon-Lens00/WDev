struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Wrapper extends array
delegate Leaf delegated
endstruct
function Run takes Wrapper w returns nothing
call w.tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
